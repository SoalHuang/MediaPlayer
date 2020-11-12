//
//  Loger.swift
//  MediaPlayer
//
//  Created by SoalHunag on 2019/12/27.
//  Copyright © 2019 SoalHunag. All rights reserved.
//

import UIKit

func log<T>(print enable: Bool = false,
            _ message: T,
            file: String = #file,
            line: Int = #line,
            method: String = #function) {
    guard enable else { return }
    let text = "[MediaPlayer] [\((file as NSString).lastPathComponent) line: \(line), method: \(method)]: \(message)\n"
    print(text)
}
