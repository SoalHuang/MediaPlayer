//
//  ResourceType.swift
//  MediaPlayer
//
//  Created by SoalHunag on 2019/12/27.
//  Copyright © 2019 SoalHunag. All rights reserved.
//

import UIKit
import AVFoundation
import SDFoundation

public let ErrorDomain = "com.soso.media.player.error.domain"

public typealias ImageResource = SDFoundation.Resource<UIImage>

public typealias MediaResource = SDFoundation.Resource<AVPlayerItem>

/// 播放器状态
public enum Status: Equatable {
    
    /// 未知，初始状态
    case unknown
    
    /// 正在加载中
    case loading
    
    /// 准备完毕
    case ready
    
    /// 出错
    case failed(Error?)
    
    /// 暂停
    case paused
    
    /// 停止
    case stoped
    
    /// 等待
    case waiting
    
    /// 播放中
    case playing
    
    /// 播放完
    case endTime
    
    /// 缓冲区为空，等待
    case bufferEmpty
    
    /// 预测是否可以平滑的继续播放
    case keepUp
    
    /// 进度
    case progress(TimeInterval)
    
    public static func == (lhs: Status, rhs: Status) -> Bool {
        switch (lhs, rhs) {
        case (.unknown, .unknown):                  return true
        case (.loading, .loading):                  return true
        case (.ready, .ready):                      return true
        case (.failed(let lr), .failed(let rr)):    return (lr as NSError?)?.code == (rr as NSError?)?.code
        case (.paused, .paused):                    return true
        case (.stoped, .stoped):                    return true
        case (.waiting, .waiting):                  return true
        case (.playing, .playing):                  return true
        case (.endTime, .endTime):                  return true
        case (.bufferEmpty, .bufferEmpty):          return true
        case (.keepUp, .keepUp):                    return true
        case (.progress(let lp), .progress(let rp)):return lp == rp
        default: return false
        }
    }
}

public extension Status {
    
    var isVisible: Bool {
        switch self {
        case .unknown, .failed: return false
        default: return true
        }
    }
}

public enum Events: Equatable {

    public enum MaskActions: Int {
        
        /// 隐藏
        case hide
        
        /// 显示
        case show
        
        /// 显示后延迟隐藏
        case flash
    }
    
    public enum ZoomActions {
        
        /// 放大
        case `in`
        
        /// 缩小
        case `out`
    }
    
    /// 左上角返回按钮
    case exit
    
    /// 左下角播放
    case play
    
    /// 左下角暂停
    case pause
    
    /// 右下角跳过
    case next
    
    /// 点击事件
    case singleTouched(_ state: UIGestureRecognizer.State, _ point: CGPoint)
    
    /// 双击事件
    case doubleTouched(_ state: UIGestureRecognizer.State, _ point: CGPoint)
    
    /// 蒙层显示、隐藏
    case mask(_ action: MaskActions, _ animate: Bool)
    
    /// 放大、缩小
    case zoom(_ action: ZoomActions, _ animate: Bool)
    
    /// 快进
    case seek(_ time: TimeInterval)
    
    public static func == (lhs: Events, rhs: Events) -> Bool {
        switch (lhs, rhs) {
        case (.exit, .exit):                    return true
        case (.play, .play):                    return true
        case (.pause, .pause):                  return true
        case (.next, .next):                    return true
        case (.singleTouched, .singleTouched):  return true
        case (.doubleTouched, .doubleTouched):  return true
        case (.mask(let l, _), .mask(let r, _)):    return l == r
        case (.zoom(let l, _), .zoom(let r, _)):    return l == r
        case (.seek(let l), .seek(let r)):      return l == r
        default:                                return false
        }
    }
}

extension Events.ZoomActions {
    
    public var inverse: Events.ZoomActions {
        switch self {
        case .in: return .out
        case .out: return .in
        }
    }
}

extension Events {
    
    /// 蒙层是否隐藏
    var maskIsHide: Bool? {
        guard case .mask(let action, _) = self else { return nil }
        return action != .show
    }
    
    /// 是否是放大状态
    var zoomIsZoomIn: Bool? {
        guard case .zoom(let action, _) = self else { return nil }
        return action ~= .in
    }
    
    /// 快进时间点
    var seekTime: TimeInterval? {
        guard case .seek(let time) = self else { return nil }
        return time
    }
}

public protocol PlayerItemDelegate: class {
    
    func player(_ item: PlayerItemType, status: Status)
    
    func player(_ item: PlayerItemType, loaded ranges: [CMTimeRange])
}

public extension PlayerItemDelegate {
    
    func player(_ item: PlayerItemType, status: Status) { }
    
    func player(_ item: PlayerItemType, loaded ranges: [CMTimeRange]) { }
}

public protocol PlayerItemType {
    
    var item: AVPlayerItem? { get }
    
    var player: AVPlayer? { get }
    
    var status: Status { get }
    
    var delegate: PlayerItemDelegate? { get set }
}

public protocol IDType {
    
    var id: String { get }
}

extension Int: IDType {
    
    public var id: String { return "\(self)" }
}

extension String: IDType {
    
    public var id: String { return self }
}

extension URL: IDType {
    
    public var id: String { return self.absoluteString }
}


public protocol URLType {
    
    var url: URL? { get }
}

extension String: URLType {
    
    public var url: URL? { return URL(string: self) }
}

extension URL: URLType {
    
    public var url: URL? { return self }
}
