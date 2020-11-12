//
//  Player.swift
//  MediaPlayer
//
//  Created by SoalHunag on 2020/7/7.
//  Copyright © 2020 SoalHunag. All rights reserved.
//

import AVFoundation
import SDFoundation

open class Player<Provider: ProviderType>: NSObject, PlayerType, PlayerItemDelegate {
    
    open func reset() {
        item = nil
    }
    
    open func replay() {
        send(event: .seek(0))
        send(event: .play)
    }
    
    open func send(event: Events) {
        
        log(print: isLogEnabled, "replay")
        
        guard let player = item?.player else { return }
        
        switch event {
            
        case .play:
            guard delegate?.playerShouldPlay(self) ?? true else {
                log(print: isLogEnabled, "should not play")
                return
            }
            isPaused = false
            if #available(iOS 10.0, *) {
                player.playImmediately(atRate: 1.0)
            } else {
                player.play()
            }
            
        case .pause:
            isPaused = true
            player.pause()
            
        case .seek(let time):
            let toTime = CMTime(seconds: time, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            let toLerance = CMTime(seconds: 0, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            player.seek(to: toTime, toleranceBefore: toLerance, toleranceAfter: toLerance)
            
        default: break
        }
    }
    
    /// 回调代理
    open weak var delegate: PlayerDelegate?
    
    /// 资源处理
    public let provider: Provider
    
    var item: PlayerItemType? {
        didSet {
            item?.delegate = self
        }
    }
    
    public var playerItem: AVPlayerItem? {
        return item?.item
    }
    
    public var status: Status {
        return item?.status ?? .unknown
    }
    
    /// 开启日志
    open var isLogEnabled: Bool = false
    
    public private(set) var isPaused: Bool = false
    
    deinit {
        item?.player?.pause()
        if let clsnm = self.className {
            log(print: isLogEnabled, clsnm + " deinit")
        }
    }
    
    public required override init() {
        provider = Provider()
        super.init()
    }
    
    public init(provider: Provider = Provider(), delegate: PlayerDelegate? = nil) {
        self.provider = provider
        super.init()
        self.delegate = delegate
    }
    
    /// 播放资源id
    open func play(id: IDType, seekTo time: TimeInterval = 0) {
        provider.cancel()
        isPaused = false
        delegate?.player(self, status: .loading)
        provider.player(for: id) { [weak self] in
            guard let `self` = self else { return }
            switch $0 {
            case .failure(let err):
                self.item = nil
                self.delegate?.player(self, status: .failed(err))
            case .success(let suc):
                self.delegate?.player(self, status: .waiting)
                self.item = PlayerItem(item: suc)
                if !self.isPaused {
                    self.send(event: .play)
                    if time > 0 {
                        self.send(event: .seek(time))
                    }
                }
            }
        }
    }
    
    /// 播放url
    open func play(url: URLType, seekTo time: TimeInterval = 0) {
        provider.cancel()
        isPaused = false
        delegate?.player(self, status: .loading)
        provider.player(for: url) { [weak self] in
            guard let `self` = self else { return }
            switch $0 {
            case .failure(let err):
                self.item = nil
                self.delegate?.player(self, status: .failed(err))
            case .success(let suc):
                self.delegate?.player(self, status: .waiting)
                self.item = PlayerItem(item: suc)
                if !self.isPaused {
                    self.send(event: .play)
                    if time > 0 {
                        self.send(event: .seek(time))
                    }
                }
            }
        }
    }
    
    /// 播放自定义结构
    open func play(id: IDType, url: URLType, seekTo time: TimeInterval = 0) {
        provider.cancel()
        isPaused = false
        delegate?.player(self, status: .loading)
        provider.player(for: id, url: url) { [weak self] in
            guard let `self` = self else { return }
            switch $0 {
            case .failure(let err):
                self.item = nil
                self.delegate?.player(self, status: .failed(err))
            case .success(let suc):
                self.delegate?.player(self, status: .waiting)
                self.item = PlayerItem(item: suc)
                if !self.isPaused {
                    self.send(event: .play)
                    if time > 0 {
                        self.send(event: .seek(time))
                    }
                }
            }
        }
    }
    
    open func play(item anItem: PlayerItemType, seekTo time: TimeInterval = 0) {
        provider.cancel()
        isPaused = false
        delegate?.player(self, status: .waiting)
        item = anItem
        send(event: .play)
        send(event: .seek(time))
    }
    
    // MARK: - PlayerItemDelegate
    open func player(_ item: PlayerItemType, status: Status) {
        delegate?.player(self, status: status)
    }
}
