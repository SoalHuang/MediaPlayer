//
//  PlayerContentViewType.swift
//  MediaPlayer
//
//  Created by SoalHunag on 2020/5/11.
//  Copyright © 2020 SoalHunag. All rights reserved.
//

import AVFoundation

public protocol PlayerContentViewDelegate: NSObjectProtocol {
    
    /// 是否允许播放
    func playerContentViewShouldPlay(_ playerContentView: PlayerContentViewType) -> Bool
    
    /// 事件回调
    func playerContentView(_ playerContentView: PlayerContentViewType, event: Events)
    
    /// 状态回调
    func playerContentView(_ playerContentView: PlayerContentViewType, status: Status)
}

public extension PlayerContentViewDelegate {
    
    func playerContentViewShouldPlay(_ playerContentView: PlayerContentViewType) -> Bool {
        return true
    }
    
    func playerContentView(_ playerContentView: PlayerContentViewType, event: Events) {
        
    }
    
    func playerContentView(_ playerContentView: PlayerContentViewType, status: Status) {
        
    }
}

public protocol PlayerContentViewType: StateViewType {
    
    var delegate: PlayerContentViewDelegate? { get set }
    
    var playerItem: PlayerItemType? { get set }
    
    var videoGravity: AVLayerVideoGravity { get set }
}

extension PlayerContentViewType {
    
    public var player: AVPlayer? {
        return playerItem?.player
    }
}
