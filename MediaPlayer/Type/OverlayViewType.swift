//
//  OverlayType.swift
//  MediaPlayer
//
//  Created by SoalHunag on 2019/12/27.
//  Copyright © 2019 SoalHunag. All rights reserved.
//

import UIKit
import SDUIKit

/// 状态视图协议
public protocol StateViewType: SDUIKit.ViewableType {
    
    /// 默认初始化
    init()
    
    /// 重置
    func reset()
    
    /// 发送事件
    func send(event: Events)
    
    /// 发送状态
    func update(status: Status)
}

/// 状态视图协议拓展
public extension StateViewType {
    
    func reset() { }
    
    func send(event: Events) { }
    
    func update(status: Status) { }
}

/// 视频标题栏选项
public struct TitleViewOptions: OptionSet {
    
    /// 标题
    public static let title = TitleViewOptions(rawValue: 1 << 0)
    
    /// 左上角返回按钮
    public static let exit = TitleViewOptions(rawValue: 1 << 1)
    
    /// 无：[]
    public static let none: TitleViewOptions = []
    
    /// 组合：[.title, .exit]
    public static let all: TitleViewOptions = [.title, .exit]
    
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

/// 标题栏协议
public protocol TitleViewType: StateViewType {
    
    /// 控件显示选项
    var options: TitleViewOptions { get set }
    
    /// 标题
    var title: String? { get set }
    
    /// 富文本标题
    var attributedTitle: NSAttributedString? { get set }
    
    /// 标题宽度百分比
    var titleWidthMultiplied: CGFloat { get set }
    
    /// 左上角返回按钮的事件
    var exitHandle: (() -> Void)? { get set }
}


/// 特效蒙层协议
public protocol EffectViewType: StateViewType {
    
    /// 蒙层特效
    var effect: UIVisualEffect? { get set }
    
    /// 蒙层特效下的背景图片
    var image: ImageResource { get set }
}


/// 指示器协议
public protocol IndicatorViewType: StateViewType {
    
    /// 是否正在运行动画
    var isAnimating: Bool { get set }
}


/// 进度控制回调协议
public protocol ProgressViewDelegate: NSObjectProtocol {
    
    /// 事件回调
    func progressView(_ progressView: ProgressViewType, event: Events)
    
    /// 状态回调
    func progressView(_ progressView: ProgressViewType, action: ProgressView.Actions)
}

/// 进度控制回调协议拓展
public extension ProgressViewDelegate {
    
    func progressView(_ progressView: ProgressViewType, event: Events) { }
    
    func progressView(_ progressView: ProgressViewType, action: ProgressView.Actions) { }
}

/// 进度显示选项
public struct ProgressViewOptions: OptionSet {
    
    /// 播放进度条
    public static let progress = ProgressViewOptions(rawValue: 1 << 0)
    
    /// 缩放按钮
    public static let zoom     = ProgressViewOptions(rawValue: 1 << 1)
    
    /// 跳过、下一步按钮
    public static let next     = ProgressViewOptions(rawValue: 1 << 2)
    
    /// 无：[]
    public static let none:     ProgressViewOptions = []
    
    /// 组合：[.progress, .zoom]
    public static let normal:   ProgressViewOptions = [.progress, .zoom]
    
    /// 组合：[.progress, .zoom, .next]
    public static let all:      ProgressViewOptions = [.progress, .zoom, .next]
    
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

/// 进度控制选项
public struct ProgressViewControls: OptionSet {
    
    /// 播放
    public static let play = ProgressViewControls(rawValue: 1 << 0)
    
    /// 拖动进度条
    public static let pan  = ProgressViewControls(rawValue: 1 << 1)
    
    /// 缩放
    public static let zoom = ProgressViewControls(rawValue: 1 << 2)
    
    /// 跳过
    public static let next = ProgressViewControls(rawValue: 1 << 3)
    
    /// 无：[]
    public static let none:     ProgressViewControls = []
    
    /// 组合：[.play, .pan, .zoom]
    public static let normal:   ProgressViewControls = [.play, .pan, .zoom]
    
    /// 组合：[.play, .pan, .zoom, .next]
    public static let all:      ProgressViewControls = [.play, .pan, .zoom, .next]
    
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

/// 进度控制协议
public protocol ProgressViewType: StateViewType {
    
    /// 回调代理
    var delegate: ProgressViewDelegate? { get set }
    
    /// 显示选项
    var options: ProgressViewOptions { get set }
    
    /// 控制选项
    var controls: ProgressViewControls { get set }
    
    /// 已加载的分段
    var timeRanges: [(TimeInterval, TimeInterval)] { get set }
    
    /// 总时长
    var total: TimeInterval { get }
    
    /// 当前进度时长
    var current: TimeInterval { get }
    
    /// 更新总时长喝进度
    func update(total: TimeInterval, current: TimeInterval)
}

/// 蒙层选项
public struct OverlayViewOptions: OptionSet {
    
    /// 蒙层特效
    public static let effect    = OverlayViewOptions(rawValue: 1 << 0)
    
    /// 标题栏
    public static let title     = OverlayViewOptions(rawValue: 1 << 1)
    
    /// 指示器
    public static let indicator = OverlayViewOptions(rawValue: 1 << 2)
    
    /// 播放、暂停、进度条、缩放、跳过等
    public static let progress  = OverlayViewOptions(rawValue: 1 << 3)
    
    /// 无： []
    public static let none: OverlayViewOptions = []
    
    /// 组合：[.effect, .title, .indicator, .progress]
    public static let all:  OverlayViewOptions = [.effect, .title, .indicator, .progress]
    
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

/// 蒙层回调协议
public protocol OverlayViewDelegate: NSObjectProtocol {
    
    /// 事件回调
    func overlayView(_ overlayView: StateViewType, event: Events)
}

/// 蒙层回调协议拓展
public extension OverlayViewDelegate {
    
    func overlayView(_ overlayView: StateViewType, event: Events) { }
}

/// 蒙层视图协议
public protocol OverlayViewType: StateViewType {
    
    /// 回调代理
    var delegate: OverlayViewDelegate? { get set }
    
    /// 显示选项
    var options: OverlayViewOptions { get set }
    
    /// 是否自动隐藏子视图
    var subOverlaysAutoHideDelay: TimeInterval { get set }
    
    /// 子视图是否已隐藏
    var isSubOverlaysHidden: Bool { get }
    
    /// 标题栏
    var titleView: TitleViewType { get }
    
    /// 特效蒙层
    var effectView: EffectViewType { get }
    
    /// 指示器
    var indicatorView: IndicatorViewType { get }
    
    /// 进度控制栏
    var progressView: ProgressViewType { get }
    
    /// 所有状态视图
    var stateViews: [StateViewType] { get }
    
    /// 显示5s后自动隐藏
    func flash(animate: Bool)
    
    /// 显示
    func show(animate: Bool)
    
    /// 隐藏
    func hide(animate: Bool)
}

extension OverlayViewType {
    
    public func send(event: Events) {
        stateViews.forEach { $0.send(event: event) }
    }
    
    public func update(status: Status) {
        stateViews.forEach { $0.update(status: status) }
    }
}

extension OverlayViewType {
    
    public var stateViews: [StateViewType] {
        return [titleView, effectView, indicatorView, progressView]
    }
}
