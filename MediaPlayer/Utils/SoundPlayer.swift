//
//  SoundPlayer.swift
//  MediaPlayer
//
//  Created by SoalHunag on 2020/5/12.
//  Copyright © 2020 SoalHunag. All rights reserved.
//

import AudioToolbox

final class SoundPlayer {
    
    static let player = SoundPlayer()
    
    static func play(_ sound: Sounds, vibrate: Bool = false) {
        SoundPlayer.player.play(sound, vibrate: vibrate)
    }
    
    enum Sounds: String {
        
        case click = "ClickSound_Action_In"
    }
    
    private var clickID: SystemSoundID = 0
    
    init() {
        if let path = Bundle.main.url(forResource: Sounds.click.rawValue, withExtension: "caf") {
            AudioServicesCreateSystemSoundID(path as CFURL, &clickID)
        }
    }
    
    func play(_ sound: Sounds, vibrate: Bool = false) {
        switch sound {
        case .click: AudioServicesPlaySystemSound(clickID)
        }
        if vibrate {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        }
    }
}
