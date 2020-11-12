//
//  MediaPlayer+Ext.swift
//  MediaPlayer
//
//  Created by SoalHunag on 2020/5/11.
//  Copyright © 2020 SoalHunag. All rights reserved.
//

import AVFoundation
import SDFoundation

extension PlayerView where Provider: ProviderType {
    
    /// 是否允许使用蜂窝网络
    var allowsCellularAccess: Bool {
        get { return provider.allowsCellularAccess }
        set { provider.allowsCellularAccess = newValue }
    }
}

extension PlayerItemType {
    
    public var total: TimeInterval? {
        return item?.total
    }
    
    public var current: TimeInterval? {
        return item?.current
    }
    
    public var loaded: [CMTimeRange]? {
        return item?.loaded
    }
    
    public var currentLoaded: CMTimeRange? {
        return item?.currentLoaded
    }
    
    public func isLoadedLess(_ second: TimeInterval) -> Bool {
        return item?.isLoadedLess(second) ?? false
    }
}

extension AVPlayerItem {
    
    var total: TimeInterval? {
        guard duration.isValid, duration.isNumeric else { return nil }
        return duration.seconds
    }
    
    var current: TimeInterval? {
        let time = currentTime()
        guard time.isValid, time.isNumeric else { return nil }
        return time.seconds
    }
    
    var loaded: [CMTimeRange]? {
        return loadedTimeRanges.compactMap { $0.timeRangeValue }
    }
    
    var currentLoaded: CMTimeRange? {
        guard let c = current else { return nil }
        return loaded?.filter({
            guard $0.start.isValid, $0.start.isNumeric, $0.duration.isValid, $0.duration.isNumeric else {
                return false
            }
            return c >= $0.start.seconds && c <= ($0.start.seconds + $0.duration.seconds)
        }).first
    }
    
    func isLoadedLess(_ second: TimeInterval) -> Bool {
        guard let c = current, let cl = currentLoaded else { return false }
        return cl.start.seconds + cl.duration.seconds - c >= second
    }
}

extension AVPlayer {
    
    var total: TimeInterval? {
        return currentItem?.total
    }
    
    var current: TimeInterval? {
        return currentItem?.current
    }
    
    var loaded: [CMTimeRange]? {
        return currentItem?.loaded
    }
    
    var currentLoaded: CMTimeRange? {
        return currentItem?.currentLoaded
    }
    
    func isLoadedLess(_ second: TimeInterval) -> Bool {
        return currentItem?.isLoadedLess(second) ?? false
    }
}
