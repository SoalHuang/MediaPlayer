//
//  PlayerViewType.swift
//  MediaPlayer
//
//  Created by SoalHunag on 2020/7/7.
//  Copyright © 2020 SoalHunag. All rights reserved.
//

import UIKit
import AVFoundation
import SDUIKit

public protocol PlayerViewDelegate: NSObjectProtocol {
    
    func playerViewShouldPlay(_ playerView: PlayerViewType) -> Bool
    func playerView(_ playerView: PlayerViewType, event: Events)
    func playerView(_ playerView: PlayerViewType, status: Status)
}

public extension PlayerViewDelegate {
    
    func playerViewShouldPlay(_ playerView: PlayerViewType) -> Bool {
        return true
    }
    
    func playerView(_ playerView: PlayerViewType, event: Events) {
        
    }
    
    func playerView(_ playerView: PlayerViewType, status: Status) {
        
    }
}

public protocol PlayerViewType: StateViewType {
    
    var delegate: PlayerViewDelegate? { get set }
    
    var id: IDType? { get }
    var url: URLType? { get }
    
    var total: TimeInterval? { get }
    var current: TimeInterval { get }
    var loaded: [CMTimeRange] { get }
    
    func play(id: IDType, seekTo time: TimeInterval)
    func play(url: URLType, seekTo time: TimeInterval)
    func play(id: IDType, url: URLType, seekTo time: TimeInterval)
    func play(item: PlayerItemType, seekTo time: TimeInterval)
}
