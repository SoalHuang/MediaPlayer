//
//  PlayerType.swift
//  MediaPlayer
//
//  Created by SoalHunag on 2019/12/27.
//  Copyright © 2019 SoalHunag. All rights reserved.
//

import UIKit
import AVFoundation
import SDFoundation

public class PlayerItem: PlayerItemType {
    
    public let item: AVPlayerItem?
    
    public let player: AVPlayer?
    
    public internal(set) var status: Status {
        get { return lock.sd.lock(status_) }
        set { lock.sd.lock(status_ = newValue) }
    }
    
    private let lock = NSLock()
    
    private var status_: Status = .unknown
    
    deinit {
        removePlayerItemObservers(item)
        removePlayerObservers(player)
    }
    
    public weak var delegate: PlayerItemDelegate? {
        didSet {
            if delegate === oldValue { return }
            if delegate == nil {
                removePlayerItemObservers(item)
                removePlayerObservers(player)
            } else if let playerItem = item {
                if let currentLoaded = loaded {
                    delegate?.player(self, loaded: currentLoaded)
                }
                addPlayerItemObservers(playerItem)
                addPlayerObservers(player)
            } else {
                update(status: .unknown)
            }
        }
    }
    
    public init(item: AVPlayerItem? = nil, player: AVPlayer? = nil) {
        if item != nil, player == nil {
            self.item = item
            self.player = AVPlayer(playerItem: item)
        } else if item == nil, player != nil {
            self.player = player
            self.item = player?.currentItem
        } else {
            self.item = item; self.player = player
        }
    }
    
    private var playerObserver: Any?
    
    private var statusObservation:                  NSKeyValueObservation?
    private var timeControlStatusObservation:       NSKeyValueObservation?
    private var loadedTimeRangesObservation:        NSKeyValueObservation?
    private var playbackBufferEmptyObservation:     NSKeyValueObservation?
    private var playbackLikelyToKeepUpObservation:  NSKeyValueObservation?
    
    private func update(status: Status) {
        self.status = status
        delegate?.player(self, status: status)
    }
}

extension PlayerItem {
    
    // MARK: Observer KeyPaths
    private struct ObserverKeyPath {
        static let status                   = "status"
        static let timeControlStatus        = "timeControlStatus"
        static let loadedTimeRanges         = "loadedTimeRanges"
        static let playbackBufferEmpty      = "playbackBufferEmpty"
        static let playbackLikelyToKeepUp   = "playbackLikelyToKeepUp"
    }
}

extension PlayerItem {
    
    private func removePlayerObservers(_ player: AVPlayer?) {
        statusObservation?.invalidate()
        statusObservation = nil
        timeControlStatusObservation?.invalidate()
        timeControlStatusObservation = nil
        if let pobs = playerObserver {
            player?.removeTimeObserver(pobs)
            playerObserver = nil
        }
    }
    
    private func removePlayerItemObservers(_ playerItem: AVPlayerItem?) {
        loadedTimeRangesObservation?.invalidate()
        loadedTimeRangesObservation = nil
        playbackBufferEmptyObservation?.invalidate()
        playbackBufferEmptyObservation = nil
        playbackLikelyToKeepUpObservation?.invalidate()
        playbackLikelyToKeepUpObservation = nil
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    private func addPlayerObservers(_ player: AVPlayer?) {
        updatePlayerStatus(player?.status)
        statusObservation = player?.observe(\.status) { [weak self] (player, change) in
            self?.updatePlayerStatus(player.status)
        }
        if #available(iOS 10.0, *) {
            updateControlStatus(player?.timeControlStatus)
            timeControlStatusObservation = player?.observe(\.timeControlStatus) { [weak self] (player, change) in
                self?.updateControlStatus(player.timeControlStatus)
            }
        } else {
            updateControlRate(rate: player?.rate)
            timeControlStatusObservation = player?.observe(\.rate) { [weak self] (player, change) in
                self?.updateControlRate(rate: player.rate)
            }
        }
        let interval = CMTime(seconds: 1.0 / 30, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        playerObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] in
            guard case .readyToPlay? = self?.player?.status else { return }
            self?.playerLoop($0)
        }
    }
    
    private func addPlayerItemObservers(_ playerItem: AVPlayerItem?) {
        loadedTimeRangesObservation = playerItem?.observe(\.loadedTimeRanges) { [weak self] (item, change) in
            let ranges = item.loadedTimeRanges.compactMap { $0.timeRangeValue }
            self?.updateLoadedRanges(ranges)
        }
        playbackBufferEmptyObservation = playerItem?.observe(\.isPlaybackBufferEmpty) { [weak self] (item, change) in
            guard item.isPlaybackBufferEmpty else { return }
            self?.playbackBufferEmpty()
        }
        playbackLikelyToKeepUpObservation = playerItem?.observe(\.isPlaybackLikelyToKeepUp) { [weak self] (item, change) in
            guard item.isPlaybackLikelyToKeepUp else { return }
            self?.playbackLikelyToKeepUp()
        }
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                                               object: nil,
                                               queue: .main) { [weak self] in
            self?.didPlayToEndTime($0)
        }
    }
    
    private func didPlayToEndTime(_ notification: Notification) {
        guard item == notification.object as? AVPlayerItem else { return }
        update(status: .endTime)
    }
    
    private func playerLoop(_ time: CMTime) {
        update(status: .progress(current ?? 0))
    }
    
    private func updatePlayerStatus(_ status: AVPlayer.Status?) {
        guard let `status` = status else { return }
        switch status {
        case .unknown:      update(status: .unknown)
        case .readyToPlay:  update(status: .ready)
        case .failed:       update(status: .failed(player?.error))
        @unknown default:   update(status: .unknown)
        }
    }
    
    private func updateControlRate(rate: Float?) {
        guard let `rate` = rate else { return }
        switch rate {
        case ...0:  update(status: .paused)
        case 0...1: update(status: .waiting)
        case 1...:  update(status: .playing)
        default:    update(status: .unknown)
        }
    }
    
    @available(iOS 10.0, *)
    private func updateControlStatus(_ status: AVPlayer.TimeControlStatus?) {
        guard let `status` = status else { return }
        switch status {
        case .paused:                       update(status: .paused)
        case .waitingToPlayAtSpecifiedRate: update(status: .waiting)
        case .playing:                      update(status: .playing)
        @unknown default:                   update(status: .unknown)
        }
    }
    
    private func updateLoadedRanges(_ ranges: [CMTimeRange]) {
        delegate?.player(self, loaded: ranges)
    }
    
    private func playbackBufferEmpty() {
        if let rate = player?.rate, rate == 1.0 { return }
        update(status: .bufferEmpty)
    }
    
    private func playbackLikelyToKeepUp() {
        update(status: .keepUp)
    }
}
