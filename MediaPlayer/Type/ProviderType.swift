//
//  ProviderType.swift
//  MediaPlayer
//
//  Created by SoalHunag on 2019/12/27.
//  Copyright © 2019 SoalHunag. All rights reserved.
//

import UIKit
import AVFoundation

public protocol ProviderType: class {
    
    /// 是否允许使用蜂窝网络
    var allowsCellularAccess: Bool { get set }
    
    /// 默认初始化
    init()
    
    /// 取消
    func cancel()
    
    /// 播放资源id
    func player(for id: IDType, _ completion: @escaping (Result<AVPlayerItem, Error>) -> Void)
    
    /// 播放url
    func player(for url: URLType, _ completion: @escaping (Result<AVPlayerItem, Error>) -> Void)
    
    /// 自定义结构
    func player(for id: IDType, url: URLType, _ completion: @escaping (Result<AVPlayerItem, Error>) -> Void)
}

public extension ProviderType {
    
    /// 是否允许使用蜂窝网络, default true
    var allowsCellularAccess: Bool {
        get { return true }
        set { }
    }
    
    /// 取消
    func cancel() {
        
    }
    
    /// 播放资源id
    func player(for id: IDType, _ completion: (Result<AVPlayerItem, Error>) -> Void) {
        let error = NSError(domain: ErrorDomain,
                            code: NSURLErrorFileDoesNotExist,
                            userInfo: [NSURLErrorFailingURLErrorKey : "Not Implementation"])
        completion(.failure(error))
    }
    
    /// 播放url
    func player(for url: URLType, _ completion: (Result<AVPlayerItem, Error>) -> Void) {
        if let u = url.url {
            completion(.success(AVPlayerItem(url: u)))
        } else {
            let error = NSError(domain: ErrorDomain,
                                code: NSURLErrorBadURL,
                                userInfo: [NSURLErrorFailingURLErrorKey : "Bad URL"])
            completion(.failure(error))
        }
    }
    
    /// 自定义结构
    func player(for id: IDType, url: URLType, _ completion: @escaping (Result<AVPlayerItem, Error>) -> Void) {
        if let u = url.url {
            completion(.success(AVPlayerItem(url: u)))
        } else {
            let error = NSError(domain: ErrorDomain,
                                code: NSURLErrorBadURL,
                                userInfo: [NSURLErrorFailingURLErrorKey : "Bad URL"])
            completion(.failure(error))
        }
    }
}
