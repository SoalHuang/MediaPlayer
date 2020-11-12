//
//  PlayerContentView.swift
//  MediaPlayer
//
//  Created by SoalHunag on 2019/12/27.
//  Copyright © 2019 SoalHunag. All rights reserved.
//

import UIKit
import AVFoundation
import SnapKit
import SDFoundation
import SDUIKit

open class PlayerContentView<Overlay: OverlayViewType>: UIView, PlayerContentViewType, OverlayViewDelegate {
    
    open weak var delegate: PlayerContentViewDelegate?
    
    public var playerItem: PlayerItemType? {
        didSet {
            
            playerItem?.item?.canUseNetworkResourcesForLiveStreamingWhilePaused = false
            if #available(iOS 10.0, *) {
                playerItem?.item?.preferredForwardBufferDuration = 1
            }
            
            playerLayer.player = playerItem?.player
            
            guard var newPlayerItem = playerItem else {
                update(status: .unknown)
                return
            }
            
            newPlayerItem.delegate = self
        }
    }
    
    public var videoGravity: AVLayerVideoGravity {
        get { return playerLayer.videoGravity }
        set { playerLayer.videoGravity = newValue }
    }
    
    /// 指令缓存
    public private(set) var event: Events?
    
    /// 是否可以脱离window播放
    public var isPlayingWithoutWindow: Bool = false
    
    /// 视频上的覆盖视图
    public let overlayView: Overlay
    
    /// 开启日志
    internal var isLogEnabled: Bool = false
    
    deinit {
        player?.pause()
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        playerItem?.item?.cancelPendingSeeks()
        sd.removeNotification(name: UIApplication.didEnterBackgroundNotification)
        sd.removeNotification(name: UIApplication.didBecomeActiveNotification)
        if let clsnm = self.className {
            log(print: isLogEnabled, clsnm + " deinit")
        }
    }
    
    public required init?(coder: NSCoder) {
        overlayView = Overlay()
        super.init(coder: coder)
        setup()
    }
    
    public override init(frame: CGRect) {
        overlayView = Overlay()
        super.init(frame: frame)
        setup()
    }
    
    public init(overlay: Overlay = Overlay()) {
        overlayView = overlay
        super.init(frame: .zero)
        setup()
    }
    
    /// 必要的设置
    private func setup() {
        
        backgroundColor = .black
        clipsToBounds = true
        playerLayer.videoGravity = .resizeAspectFill
        
        addSub(overlayView)
        overlayView.delegate = self
        overlayView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        sd.addNotification(name: UIApplication.didEnterBackgroundNotification, object: nil) { [weak self] _ in
            self?.applicationEnterBackground()
        }
        sd.addNotification(name: UIApplication.didBecomeActiveNotification, object: nil) { [weak self] _ in
            self?.applicationBecomeActive()
        }
    }
    
    /// 需要的最小缓冲
    private let minumumCacheDuration: TimeInterval = 5.0
    
    /// 视频总时间长度，避免多次计算
    private var totalDuratoin: TimeInterval?
    
    /// 播放器状态
    public private(set) var status: Status = .unknown
    
    /// 播放器移出windows的时候是否暂停
    private var pauseWhenRemoveFromSuperView: Bool = true
    private var pausedWhenRemoveFromSuperView: Bool = false
    
    /// 取消 暂停操作 的句柄
    private var pausingPerform: SDFoundation.CancelablePerformBoxType?
    
    public override class var layerClass: AnyClass { AVPlayerLayer.self }
    
    public override func didMoveToWindow() {
        super.didMoveToWindow()
        if let _ = window {
            guard pausedWhenRemoveFromSuperView || event ~= .play else { return }
            cancelPausing()
            self.replay()
        } else {
            if isPlayingWithoutWindow || event ~= .pause { return }
            cancelPausing()
            guard pauseWhenRemoveFromSuperView else {
                return
            }
            pausingPerform = CancelablePerformBox(delay: 0.2) { [weak self] in
                self?.pausedWhenRemoveFromSuperView = true
                self?.send(event: .pause, override: true)
            }
        }
    }
    
    open func reset() {
        self.stop()
        overlayView.reset()
    }
    
    /// 发送指令
    open func send(event: Events, override: Bool = true) {
        
        log(print: isLogEnabled, "send event: \(event), override: \(override)")
        
        if override { self.event = event }
        
        overlayView.send(event: event)
        
        switch event {
        case .play:             self.replay()
        case .pause:            self.pause()
        case .seek(let time):   self.seek(to: time)
        case .zoom(let action, _):
            switch action {
            case .in: playerLayer.videoGravity = .resizeAspect
            case .out: playerLayer.videoGravity = .resizeAspectFill
            }
        default:                break
        }
    }
    
    /// 更新状态
    open func update(status: Status) {
        
        if case .progress = status { } else {
            log(print: isLogEnabled, "update status: \(status)")
        }
        
        self.status = status
        
        delegate?.playerContentView(self, status: status)
        
        overlayView.update(status: status)
        
        switch status {
        case .ready:        if let skt = event?.seekTime { self.seek(to: skt) }
        case .failed:       self.stop()
        case .bufferEmpty:  self.pause()
        case .endTime:      self.overlayView.show(animate: true)
        default:            break
        }
    }
    
    // MARK: - MediaOverlayViewDelegate
    open func overlayView(_ overlayView: StateViewType, event: Events) {
        switch event {
        case .play, .pause:
            delegate?.playerContentView(self, event: event)
            send(event: event, override: true)
        case .exit, .next, .singleTouched, .doubleTouched, .zoom:
            delegate?.playerContentView(self, event: event)
            send(event: event, override: false)
        case .mask:
            delegate?.playerContentView(self, event: event)
        case .seek(let p):
            guard let t = total else { return }
            let tp = t * p
            delegate?.playerContentView(self, event: .seek(tp))
            send(event: .seek(tp), override: true)
        }
    }
}

extension PlayerContentView {
    
    internal var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    /// 取消暂停操作
    private func cancelPausing() {
        log(print: isLogEnabled, "cancel pausing")
        pausingPerform?.cancel()
        pausingPerform = nil
        pausedWhenRemoveFromSuperView = false
    }
    
    /// App切换到后台
    private func applicationEnterBackground() {
        log(print: isLogEnabled, "application enter background")
        self.pause()
    }
    
    /// App切换到前台激活状态
    private func applicationBecomeActive() {
        log(print: isLogEnabled, "application become active")
        guard case .play = event, status != .endTime else { return }
        self.replay()
    }
}

extension PlayerContentView {
    
    private func pause() {
        log(print: isLogEnabled, "pause")
        player?.pause()
    }
    
    /// 播放
    private func replay() {
        guard delegate?.playerContentViewShouldPlay(self) ?? true else {
            log(print: isLogEnabled, "should not play")
            return
        }
        log(print: isLogEnabled, "replay")
        guard (window != nil || isPlayingWithoutWindow) else { return }
        guard let `player` = player else { return }
        switch status {
        case .endTime: seek(to: 0)
        case .failed: if let item = playerItem { playerItem = item }
        default: break
        }
        if current == total { seek(to: 0) }
        event = .play
        if #available(iOS 10.0, *) {
            if player.timeControlStatus != .playing {
                player.playImmediately(atRate: 1.0)
            }
        } else {
            player.play()
        }
    }
    
    /// 快进
    private func seek(to time: TimeInterval) {
        
        playerItem?.item?.cancelPendingSeeks()
        
        event = .seek(time)
        
        log(print: isLogEnabled, "seek to \(time)")
        
        guard
            let currentItem = playerItem,
            case .readyToPlay? = currentItem.player?.status
            else {
            log(print: isLogEnabled, "seek failed, not ready to play")
            return
        }
        
        let toTime = CMTime(seconds: time, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        let toLerance = CMTime(seconds: 0, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        
        log(print: isLogEnabled, "start seek")
        
        playerItem?.item?.seek(to: toTime, toleranceBefore: toLerance, toleranceAfter: toLerance) { [weak self] in
            guard let `self` = self, $0 else { return }
            log(print: self.isLogEnabled, "finish seek")
            if case .seek = self.event { self.event = nil }
        }
    }
    
    /// 停止
    private func stop() {
        log(print: isLogEnabled, "stop")
        player?.pause()
        playerItem = nil
        update(status: .stoped)
        totalDuratoin = nil
    }
}

extension PlayerContentView {
    
    /// 视频总时间长度
    var total: TimeInterval? {
        if let dur = totalDuratoin, dur > 0 { return dur }
        totalDuratoin = playerItem?.total
        return totalDuratoin
    }
    
    /// 视频当前进度
    var current: TimeInterval {
        return playerItem?.player?.current ?? 0
    }
    
    /// 视频当前已加载部分
    var loaded: [CMTimeRange] {
        return playerItem?.item?.loadedTimeRanges.compactMap { $0.timeRangeValue } ?? []
    }
}

extension PlayerContentView: PlayerItemDelegate {
    
    public func player(_ item: PlayerItemType, status: Status) {
        update(status: status)
        guard case .progress = status else { return }
        guard case .seek = event else {
            delegate?.playerContentView(self, status: .progress(current))
            overlayView.progressView.update(total: total ?? 0, current: current)
            return
        }
    }
    
    public func player(_ item: PlayerItemType, loaded ranges: [CMTimeRange]) {
        
        let timeRanges = ranges.compactMap { $0.valid }
        
        if let t = total, overlayView.progressView.total <= 0.0 {
            overlayView.progressView.update(total: t, current: current)
        }
        overlayView.progressView.timeRanges = timeRanges
        
        var waitingToPlayAtSpecifiedRate = false
        if #available(iOS 10.0, *) {
            waitingToPlayAtSpecifiedRate = playerItem?.player?.timeControlStatus ~= .waitingToPlayAtSpecifiedRate
        }
        
        guard
            case .readyToPlay? = playerItem?.player?.status,
            waitingToPlayAtSpecifiedRate
            else { return }
        
        let ctime = current
        
        guard ctime > minumumCacheDuration else { return }
        
        let ranges = timeRanges.filter { $0.0 <= ctime && ($0.0 + $0.1) >= ctime + minumumCacheDuration }
        
        guard ranges.count > 0 else { return }
        
        self.replay()
    }
}
