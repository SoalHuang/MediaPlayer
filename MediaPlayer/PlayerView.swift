//
//  Player.swift
//  MediaPlayer
//
//  Created by SoalHunag on 2019/12/27.
//  Copyright © 2019 SoalHunag. All rights reserved.
//

import UIKit
import AVFoundation
import SDFoundation

open class PlayerView<Provider: ProviderType, Overlay: OverlayViewType>: NSObject, PlayerViewType, PlayerContentViewDelegate {
    
    open func reset() {
        isPaused = false
        contentView.reset()
    }
    
    open func replay() {
        send(event: .seek(0))
        send(event: .play)
    }
    
    open func send(event: Events) {
        switch event {
        case .pause:    isPaused = true
        case .play:     isPaused = false
        default: break
        }
        contentView.send(event: event)
    }
    
    open func update(status: Status) {
        contentView.update(status: status)
    }
    
    /// 回调代理
    open weak var delegate: PlayerViewDelegate?
    
    /// 资源处理
    public let provider: Provider
    
    /// 视频视图
    public let contentView: PlayerContentView<Overlay>
    
    public var status: Status {
        return contentView.status
    }
    
    /// 是否可以脱离window播放
    open var isPlayingWithoutWindow: Bool {
        get { return contentView.isPlayingWithoutWindow }
        set { contentView.isPlayingWithoutWindow = newValue }
    }
    
    open var isAllowAudioPlayback: Bool {
        get { return contentView.isAllowAudioPlayback }
        set { contentView.isAllowAudioPlayback = newValue }
    }
    
    /// 开启日志
    open var isLogEnabled: Bool {
        get { return contentView.isLogEnabled }
        set { contentView.isLogEnabled = newValue }
    }
    
    /// 视频蒙层
    public var overlayView: Overlay {
        return contentView.overlayView
    }
    
    deinit {
        if let clsnm = self.className {
            log(print: isLogEnabled, clsnm + " deinit")
        }
    }
    
    public required override init() {
        provider = Provider()
        contentView = PlayerContentView<Overlay>()
        super.init()
        contentView.delegate = self
    }
    
    public init(provider: Provider = Provider(), overlay: Overlay = Overlay(), delegate: PlayerViewDelegate? = nil) {
        self.provider = provider
        contentView = PlayerContentView<Overlay>(overlay: overlay)
        super.init()
        self.delegate = delegate
        contentView.delegate = self
    }
    
    // MARK: - PlayerType
    public var view: UIView! { return contentView }
    
    public fileprivate(set) var id: IDType?
    public fileprivate(set) var url: URLType?
    
    /// 视频总时间长度
    public var total: TimeInterval? {
        return contentView.total
    }
    
    /// 视频当前进度
    public var current: TimeInterval {
        return contentView.current
    }
    
    /// 视频当前已加载部分
    public var loaded: [CMTimeRange] {
        return contentView.loaded
    }
    
    public private(set) var isPaused: Bool = false
    
    /// 播放资源id
    open func play(id: IDType, seekTo time: TimeInterval = 0) {
        provider.cancel()
        self.id = id
        self.url = nil
        isPaused = false
        update(status: .loading)
        send(event: .mask(.flash, true))
        provider.player(for: id) { [weak self] in
            guard let `self` = self else { return }
            switch $0 {
            case .failure(let error):
                self.contentView.playerItem = nil
                self.contentView.update(status: .failed(error))
            case .success(let item):
                self.contentView.playerItem = PlayerItem(item: item)
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
        self.id = nil
        self.url = url
        isPaused = false
        update(status: .loading)
        send(event: .mask(.flash, true))
        provider.player(for: url) { [weak self] in
            guard let `self` = self else { return }
            switch $0 {
            case .failure(let error):
                self.contentView.playerItem = nil
                self.contentView.update(status: .failed(error))
            case .success(let item):
                self.contentView.playerItem = PlayerItem(item: item)
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
        self.id = id
        self.url = url
        isPaused = false
        update(status: .loading)
        send(event: .mask(.flash, true))
        provider.player(for: id, url: url) { [weak self] in
            guard let `self` = self else { return }
            switch $0 {
            case .failure(let error):
                self.contentView.playerItem = nil
                self.contentView.update(status: .failed(error))
            case .success(let item):
                self.contentView.playerItem = PlayerItem(item: item)
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
        update(status: .waiting)
        contentView.playerItem = anItem
        send(event: .play)
        send(event: .seek(time))
        send(event: .mask(.flash, true))
    }
    
    private func retry() {
        isPaused = false
        guard contentView.playerLayer.player?.currentItem == nil else { return }
        if let `id` = id, let `url` = url {
            play(id: id, url: url)
        } else if let `id` = id {
            play(id: id)
        } else if let `url` = url {
            play(url: url)
        }
    }
    
    open func playerContentViewShouldPlay(_ playerContentView: PlayerContentViewType) -> Bool {
        return delegate?.playerViewShouldPlay(self) ?? true
    }
    
    open func playerContentView(_ playerContentView: PlayerContentViewType, event: Events) {
        delegate?.playerView(self, event: event)
        switch event {
        case .pause:    isPaused = true
        case .play:     retry()
        default: break
        }
    }
    
    open func playerContentView(_ playerContentView: PlayerContentViewType, status: Status) {
        delegate?.playerView(self, status: status)
        if case .failed = status {
            provider.cancel()
        }
    }
}
