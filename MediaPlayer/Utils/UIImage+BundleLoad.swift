//
//  UIImage+BundleLoad.swift
//  MediaPlayer
//
//  Created by SoalHunag on 2020/5/12.
//  Copyright © 2020 SoalHunag. All rights reserved.
//

import UIKit

let MediaPlayerBundlePath = "Frameworks/MediaPlayer.framework/MediaPlayerResource.bundle/"

extension UIImage {
    
    static func load(named: String) -> UIImage? {
        return UIImage(named: MediaPlayerBundlePath + named)
    }
}
