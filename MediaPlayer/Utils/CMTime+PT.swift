//
//  CMTime+PT.swift
//  MediaPlayer
//
//  Created by SoalHunag on 2020/5/11.
//  Copyright © 2020 SoalHunag. All rights reserved.
//

import CoreMedia.CMTime
import CoreMedia.CMTimeRange

extension CMTime {
    
    var validSeconds: TimeInterval? {
        guard isValid, isNumeric else { return nil }
        return seconds
    }
}

extension CMTimeRange {
    
    var valid: (TimeInterval, TimeInterval)? {
        if let st = start.validSeconds, let dt = duration.validSeconds {
            return (st, dt)
        } else {
            return nil
        }
    }
}
