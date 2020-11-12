//
//  PlayerType.swift
//  MediaPlayer
//
//  Created by SoalHunag on 2019/12/27.
//  Copyright © 2019 SoalHunag. All rights reserved.
//

import UIKit
import SDUIKit

public protocol PlayerDelegate: NSObjectProtocol {
    
    func playerShouldPlay(_ player: PlayerType) -> Bool
    func player(_ player: PlayerType, status: Status)
}

public extension PlayerDelegate {
    
    func playerShouldPlay(_ player: PlayerType) -> Bool {
        return true
    }
    
    func player(_ player: PlayerType, status: Status) {
        
    }
}

public protocol PlayerType: class {
    
    var delegate: PlayerDelegate? { get set }
    
    init()
    
    /// 重置
    func reset()
    
    /// 发送事件
    func send(event: Events)
    
    func play(id: IDType, seekTo time: TimeInterval)
    func play(url: URLType, seekTo time: TimeInterval)
    func play(id: IDType, url: URLType, seekTo time: TimeInterval)
    func play(item: PlayerItemType, seekTo time: TimeInterval)
}
