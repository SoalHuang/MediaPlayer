//
//  OverlayView.swift
//  MediaPlayer
//
//  Created by SoalHunag on 2019/12/27.
//  Copyright © 2019 SoalHunag. All rights reserved.
//

import UIKit
import SDFoundation
import SDUIKit

open class OverlayView: UIView, OverlayViewType, UIGestureRecognizerDelegate, ProgressViewDelegate {
    
    /// 回调代理
    open weak var delegate: OverlayViewDelegate?
    
    /// 渲染选项, default is .none
    open var options: OverlayViewOptions = .none {
        didSet {
            effectView.isHidden = !options.contains(.effect)
            titleView.isHidden = !options.contains(.title)
            indicatorView.isHidden = !options.contains(.indicator)
            progressView.isHidden = !options.contains(.progress)
        }
    }
    
    open func reset() {
        stateViews.forEach { $0.reset() }
    }
    
    /// 发送指令
    open func send(event: Events) {
        
        stateViews.forEach { $0.send(event: event) }
        
        switch event {
        case .singleTouched:
            if isSubOverlaysHidden {
                flash(animate: true)
            } else {
                hide(animate: true)
            }
        case .doubleTouched:
            if progressView.controls.contains(.zoom) {
                flash(animate: true)
            } else if isSubOverlaysHidden {
                flash(animate: true)
            } else {
                hide(animate: true)
            }
        case .mask(let action, let animate):
            switch action {
            case .show: show(animate: animate)
            case .hide: hide(animate: animate)
            case .flash: flash(animate: animate)
            }
        default: break
        }
    }
    
    open func update(status: Status) {
        stateViews.forEach { $0.update(status: status) }
    }
    
    ///
    open var subOverlaysAutoHideDelay: TimeInterval = 5.0
    
    ///
    open private(set) var isSubOverlaysHidden: Bool = false
    
    open var titleViewHeight: CGFloat = 64.sd.autoScaleMax {
        didSet {
            titleView.snp.remakeConstraints {
                $0.top.left.width.equalToSuperview()
                $0.height.equalTo(titleViewHeight)
            }
        }
    }
    
    open var progressViewHeight: CGFloat = 64.sd.autoScaleMax {
        didSet {
            progressView.snp.remakeConstraints {
                $0.left.bottom.right.equalToSuperview()
                $0.height.equalTo(progressViewHeight)
            }
        }
    }
    
    deinit {
        if let clsnm = self.className {
            log(clsnm + " deinit")
        }
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    private func setup() {
        
        addSub(effectView)
        addSub(titleView)
        addSub(progressView)
        addSub(indicatorView)
        
        effectView.snp.makeConstraints { $0.edges.equalToSuperview() }
        titleView.snp.makeConstraints {
            $0.top.left.width.equalToSuperview()
            $0.height.equalTo(titleViewHeight)
        }
        
        indicatorView.snp.makeConstraints { $0.center.equalToSuperview() }
        progressView.snp.makeConstraints {
            $0.left.bottom.right.equalToSuperview()
            $0.height.equalTo(progressViewHeight)
        }
        
        titleView.exitHandle = { [weak self] in
            guard let `self` = self else { return }
            self.delegate?.overlayView(self, event: .exit)
        }
        progressView.delegate = self
        
        addGestureRecognizer(tapGesture)
        addGestureRecognizer(doubleTapGesture)
        tapGesture.require(toFail: doubleTapGesture)
        
        effectView.isHidden = true
        titleView.isHidden = true
        indicatorView.isHidden = true
        progressView.isHidden = true
        
        options = .none
        
        flash()
    }
    
    public lazy var titleView: TitleViewType = TitleView()
    
    public lazy var effectView: EffectViewType = EffectView()
    
    public lazy var indicatorView: IndicatorViewType = IndicatorView()
    
    public lazy var progressView: ProgressViewType = ProgressView()
    
    public lazy var tapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(OverlayView.singleTouched(_:)))
        gesture.numberOfTapsRequired = 1
        gesture.delegate = self
        return gesture
    }()
    
    public lazy var doubleTapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(OverlayView.doubleTouched(_:)))
        gesture.numberOfTapsRequired = 2
        gesture.delegate = self
        return gesture
    }()
    
    open override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if
            gestureRecognizer == tapGesture || gestureRecognizer == doubleTapGesture,
            progressView.bounds.contains(gestureRecognizer.location(in: progressView.view)) {
            return false
        }
        return super.gestureRecognizerShouldBegin(gestureRecognizer)
    }
    
    open var stateViews: [StateViewType] {
        return [titleView, effectView, indicatorView, progressView]
    }
    
    /// 显示5s后自动隐藏
    open func flash(animate: Bool = true) {
        cancelDelayHide()
        stateViews.forEach { $0.send(event: .mask(.flash, animate)) }
        delegate?.overlayView(self, event: .mask(.flash, animate))
        show(animate: animate)
        delayHide(animate: animate)
    }
    
    private let controlsAnimationKey = "com.soso.media.player.overlay.controls.animation.key"
    
    /// 显示
    open func show(animate: Bool = true) {
        cancelDelayHide()
        isSubOverlaysHidden = false
        
        if animate {
            UIView.beginAnimations(controlsAnimationKey, context: nil)
            UIView.setAnimationDuration(0.2)
        }
        
        titleView.alpha = 1
        titleView.transform = .identity
        progressView.alpha = 1
        progressView.transform = .identity
        
        if animate {
            UIView.commitAnimations()
        }
        
        stateViews.forEach { $0.send(event: .mask(.show, animate)) }
        delegate?.overlayView(self, event: .mask(.show, animate))
    }
    
    /// 隐藏
    open func hide(animate: Bool = true) {
        cancelDelayHide()
        isSubOverlaysHidden = true
        
        if animate {
            UIView.beginAnimations(controlsAnimationKey, context: nil)
            UIView.setAnimationDuration(0.2)
        }
        
        titleView.alpha = 0
        titleView.transform = CGAffineTransform(translationX: 0, y: -titleViewHeight)
        progressView.alpha = 0
        progressView.transform = CGAffineTransform(translationX: 0, y: progressViewHeight)
        
        if animate {
            UIView.commitAnimations()
        }
        
        stateViews.forEach { $0.send(event: .mask(.hide, animate)) }
        delegate?.overlayView(self, event: .mask(.hide, animate))
    }
    
    /// MediaProgressViewDelegate
    open func progressView(_ progressView: ProgressViewType, event: Events) {
        flash()
        delegate?.overlayView(self, event: event)
    }
    
    open func progressView(_ progressView: ProgressViewType, action: ProgressView.Actions) {
        switch action {
        case .began:            show()
        case .progress(let p):  show(); delegate?.overlayView(self, event: .seek(p))
        case .ended:            flash()
        case .cancelled:        flash()
        }
    }
    
    private var delayHideCancelable: CancelablePerformBoxType?
}

/// touches
extension OverlayView {
    
    @objc
    private func singleTouched(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: self)
        delegate?.overlayView(self, event: .singleTouched(gesture.state, point))
    }
    
    @objc
    private func doubleTouched(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: self)
        delegate?.overlayView(self, event: .doubleTouched(gesture.state, point))
    }
}

extension OverlayView {
    
    ///
    private func cancelDelayHide() {
        delayHideCancelable?.cancel()
        delayHideCancelable = nil
    }
    
    ///
    private func delayHide(animate: Bool = true) {
        delayHideCancelable = CancelablePerformBox(delay: subOverlaysAutoHideDelay) { [weak self] in
            self?.hide(animate: animate)
        }
    }
}
