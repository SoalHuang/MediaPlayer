//
//  ProgressView.swift
//  MediaPlayer
//
//  Created by SoalHunag on 2019/12/27.
//  Copyright © 2019 SoalHunag. All rights reserved.
//

import UIKit
import SDFoundation
import SDUIKit

open class ProgressView: UIView, ProgressViewType {
    
    open weak var delegate: ProgressViewDelegate?
    
    /// default is .normal
    open var options: ProgressViewOptions = .normal {
        didSet {
            sliderView.isHidden = !options.contains(.progress)
            zoomButton.isHidden = !options.contains(.zoom)
            nextButton.isHidden = !options.contains(.next)
            
            switch (zoomButton.isHidden, nextButton.isHidden) {
                
            case (true, true):
                zoomButton.snp.remakeConstraints {
                    $0.right.equalToSuperview()
                    $0.height.width.equalTo(0)
                    $0.centerY.equalToSuperview()
                }
                nextButton.snp.remakeConstraints {
                    $0.right.equalToSuperview()
                    $0.height.width.equalTo(0)
                    $0.centerY.equalToSuperview()
                }
                lessLabel.snp.remakeConstraints {
                    $0.right.equalToSuperview().offset(-16.sd.autoScaleMax)
                    $0.width.equalTo(60.sd.autoScaleMax)
                    $0.centerY.equalToSuperview()
                }
                
            case (true, false):
                zoomButton.snp.remakeConstraints {
                    $0.right.equalToSuperview()
                    $0.height.width.equalTo(0)
                    $0.centerY.equalToSuperview()
                }
                nextButton.snp.remakeConstraints {
                    $0.right.equalToSuperview()
                    $0.height.width.equalTo(64.sd.autoScaleMax)
                    $0.centerY.equalToSuperview()
                }
                lessLabel.snp.remakeConstraints {
                    $0.right.equalTo(nextButton.snp.left).offset(16.sd.autoScaleMax)
                    $0.width.equalTo(60.sd.autoScaleMax)
                    $0.centerY.equalToSuperview()
                }
                
            case (false, true):
                zoomButton.snp.remakeConstraints {
                    $0.right.equalToSuperview()
                    $0.height.width.equalTo(64.sd.autoScaleMax)
                    $0.centerY.equalToSuperview()
                }
                nextButton.snp.remakeConstraints {
                    $0.right.equalToSuperview()
                    $0.height.width.equalTo(0)
                    $0.centerY.equalToSuperview()
                }
                lessLabel.snp.remakeConstraints {
                    $0.right.equalTo(zoomButton.snp.left).offset(16.sd.autoScaleMax)
                    $0.width.equalTo(60.sd.autoScaleMax)
                    $0.centerY.equalToSuperview()
                }
                
            case (false, false):
                nextButton.snp.remakeConstraints {
                    $0.right.equalToSuperview()
                    $0.height.width.equalTo(64.sd.autoScaleMax)
                    $0.centerY.equalToSuperview()
                }
                zoomButton.snp.remakeConstraints {
                    $0.right.equalTo(nextButton.snp.left).offset(16.sd.autoScaleMax)
                    $0.height.width.equalTo(64.sd.autoScaleMax)
                    $0.centerY.equalToSuperview()
                }
                lessLabel.snp.remakeConstraints {
                    $0.right.equalTo(zoomButton.snp.left).offset(16.sd.autoScaleMax)
                    $0.width.equalTo(60.sd.autoScaleMax)
                    $0.centerY.equalToSuperview()
                }
            }
        }
    }
    
    /// default is .normal
    open var controls: ProgressViewControls = .normal {
        didSet {
            playButton.isUserInteractionEnabled = controls.contains(.play)
            sliderView.isUserInteractionEnabled = controls.contains(.pan) && total > 0
            zoomButton.isUserInteractionEnabled = controls.contains(.zoom)
            nextButton.isUserInteractionEnabled = controls.contains(.next)
        }
    }
    
    open var timeRanges: [(TimeInterval, TimeInterval)] {
        get { return rangesView.timeRanges }
        set { rangesView.timeRanges = newValue }
    }
    
    public private(set) var total: TimeInterval = 0.0 {
        didSet {
            sliderView.isUserInteractionEnabled = controls.contains(.pan) && total > 0
        }
    }
    
    public private(set) var current: TimeInterval = 0.0
    
    private var isPlaying: Bool = false {
        didSet {
            playButton.setImage(UIImage.load(named: isPlaying ? "btn_32_pause_nor" : "btn_32_play_nor"), for: .normal)
            playButton.setImage(UIImage.load(named: isPlaying ? "btn_32_pause_sel" : "btn_32_play_sel"), for: .highlighted)
        }
    }
    
    private var zoomAction: Events.ZoomActions = .out {
        didSet {
            switch zoomAction {
            case .in:
                zoomButton.setImage(UIImage.load(named: "btn_32_small_nor"), for: .normal)
                zoomButton.setImage(UIImage.load(named: "btn_32_small_sel"), for: .highlighted)
            case .out:
                zoomButton.setImage(UIImage.load(named: "btn_32_full_nor"), for: .normal)
                zoomButton.setImage(UIImage.load(named: "btn_32_full_sel"), for: .highlighted)
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
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        layer.sd.gradientLayer?.frame = bounds
    }
    
    private func setup() {
        
        addSub(passLabel)
        addSub(lessLabel)
        
        addSub(rangesView)
        addSub(sliderView)
        
        addSub(playButton)
        addSub(nextButton)
        addSub(zoomButton)
        
        playButton.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.height.width.equalTo(64.sd.autoScaleMax)
            $0.centerY.equalToSuperview()
        }
        nextButton.snp.makeConstraints {
            $0.right.equalToSuperview()
            $0.height.width.equalTo(64.sd.autoScaleMax)
            $0.centerY.equalToSuperview()
        }
        zoomButton.snp.makeConstraints {
            $0.right.equalToSuperview()
            $0.height.width.equalTo(64.sd.autoScaleMax)
            $0.centerY.equalToSuperview()
        }
        
        passLabel.snp.makeConstraints {
            $0.left.equalTo(playButton.snp.right).offset(-16.sd.autoScaleMax)
            $0.width.equalTo(60.sd.autoScaleMax)
            $0.centerY.equalToSuperview()
        }
        lessLabel.snp.makeConstraints {
            $0.right.equalTo(zoomButton.snp.left).offset(16.sd.autoScaleMax)
            $0.width.equalTo(60.sd.autoScaleMax)
            $0.centerY.equalToSuperview()
        }
        
        rangesView.snp.makeConstraints {
            $0.height.equalToSuperview().multipliedBy(40.0 / 64.0)
            $0.left.equalTo(passLabel.snp.right)
            $0.right.equalTo(lessLabel.snp.left)
            $0.centerY.equalToSuperview()
        }
        sliderView.snp.makeConstraints {
            $0.edges.equalTo(rangesView)
        }
        
        layer.sd.gradientApply(frame: bounds,
                               start: CGPoint(x: 0.5, y: 1),
                               end: CGPoint(x: 0.5, y: 0),
                               colors: [UIColor(hex: 0x333333).withAlphaComponent(0.75),
                                        UIColor(hex: 0x333333).withAlphaComponent(0)])
        
        sliderView.handle = { [weak self] in guard let `self` = self else { return }
            self.delegate?.progressView(self, action: $0)
        }
        
        isPlaying = false
        update(status: .unknown)
        update(total: 0, current: 0)
        
        options = .normal
        controls = .normal
    }
    
    private lazy var passLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 14.sd.autoScaleMax)
        label.textAlignment = .center
        label.text = "-:-"
        return label
    }()
    
    private lazy var lessLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 14.sd.autoScaleMax)
        label.textAlignment = .center
        label.text = "-:-"
        return label
    }()
    
    private lazy var rangesView: RangesView = RangesView()
    
    private lazy var sliderView: SliderView = SliderView()
    
    private lazy var playButton: UIButton = {
        var button = UIButton()
        button.setImage(UIImage.load(named: "btn_32_play_nor"), for: .normal)
        button.sd.delayInterval = 0.5
        button.sd.on { [weak self] _ in guard let `self` = self else { return }
            SoundPlayer.play(.click)
            self.delegate?.progressView(self, event: self.isPlaying ? .pause : .play)
        }
        return button
    }()
    
    private lazy var zoomButton: UIButton = {
        var button = UIButton()
        button.setImage(UIImage.load(named: "btn_32_full_nor"), for: .normal)
        button.sd.delayInterval = 0.5
        button.sd.on { [weak self] _ in guard let `self` = self else { return }
            SoundPlayer.play(.click)
            self.delegate?.progressView(self, event: .zoom(self.zoomAction.inverse, true))
        }
        return button
    }()
    
    private lazy var nextButton: UIButton = {
        var button = UIButton()
        button.sd.delayInterval = 0.5
        button.sd.on { [weak self] _ in guard let `self` = self else { return }
            SoundPlayer.play(.click)
            self.delegate?.progressView(self, event: .next)
        }
        return button
    }()
    
    open func reset() {
        passLabel.text = "-:-"
        lessLabel.text = "-:-"
        rangesView.total = 0
        sliderView.progress = 0
        sliderView.isUserInteractionEnabled = false
    }
    
    open func send(event: Events) {
        switch event {
        case .zoom(let action, _): zoomAction = action
        default: break
        }
    }
    
    open func update(status: Status) {
        
        switch status {
        case .unknown, .paused, .failed, .endTime: isPlaying = false
        case .playing, .waiting, .bufferEmpty: isPlaying = true
        default: break
        }
        
        switch status {
        case .unknown, .loading, .failed: sliderView.isUserInteractionEnabled = false
        default: sliderView.isUserInteractionEnabled = true
        }
    }
    
    /// 更新进度
    open func update(total: TimeInterval, current: TimeInterval) {
        guard total > 0 else {
            reset()
            return
        }
        let pass = max(0, current).sd.round
        let less = max(0, total - current).sd.round
        
        passLabel.text = String(format: "%0.2d:%0.2d", Int(pass) / 60, Int(pass) % 60)
        lessLabel.text = String(format: "%0.2d:%0.2d", Int(less) / 60, Int(less) % 60)
        rangesView.total = total
        sliderView.isUserInteractionEnabled = true
        
        sliderView.progress = max(0, min(1, current / total))
    }
}

extension ProgressView {
    
    class RangesView: UIView {
        
        var total: TimeInterval = 0 {
            didSet { setNeedsDisplay() }
        }
        
        var timeRanges: [(start: TimeInterval, duration: TimeInterval)] = [] {
            didSet { setNeedsDisplay() }
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            setup()
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setup()
        }
        
        private func setup() {
            backgroundColor = UIColor.clear
            isUserInteractionEnabled = false
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            setNeedsDisplay()
        }
        
        override func draw(_ rect: CGRect) {
            super.draw(rect)
            
            guard let ctx = UIGraphicsGetCurrentContext() else { return }
            
            ctx.setFillColor(UIColor.clear.cgColor)
            ctx.fill(rect)
            
            ctx.setStrokeColor(UIColor.white.cgColor)
            ctx.setLineWidth(2)
            
            let x: CGFloat = 4
            let w: CGFloat = bounds.width - x * 2
            
            let srect = CGRect(x: x, y: (bounds.height - 8) / 2, width: w, height: 8)
            let path = UIBezierPath(roundedRect: srect, cornerRadius: 4)
            ctx.addPath(path.cgPath)
            ctx.strokePath()
            
            guard total > 0, timeRanges.count > 0 else { return }
            
            let y: CGFloat = bounds.height / 2
            let lx: CGFloat = 6
            let lw: CGFloat = max(0, bounds.width - lx * 2)
            
            /*
             /// 分段
             timeRanges.forEach {
             let sx = lx + lw * CGFloat($0.0 / total)
             let dx = lw * CGFloat($0.1 / total)
             linePath.move(to: CGPoint(x: sx, y: y))
             linePath.addLine(to: CGPoint(x: sx + dx, y: y))
             }
             */
            
            guard let frange = timeRanges.sorted(by: { $0.start + $0.duration > $1.start + $0.duration }).first else { return }
            
            let linePath = CGMutablePath()
            
            let p: CGFloat = max(0, min(1.0, CGFloat((frange.start + frange.duration) / total)))
            let sx = lx
            let dx = lw * p
            let ex = sx + dx
            linePath.move(to: CGPoint(x: sx, y: y))
            linePath.addLine(to: CGPoint(x: ex, y: y))
            
            ctx.addPath(linePath)
            ctx.setLineWidth(6)
            ctx.setLineJoin(.round)
            ctx.setLineCap(.round)
            ctx.strokePath()
        }
    }
}

extension ProgressView {
    
    /// 事件
    public enum Actions {
        
        /// 开始拖动
        case began
        
        /// 拖动
        case progress(Double)
        
        /// 结束拖动
        case ended
        
        /// 取消拖动
        case cancelled
    }
    
    class SliderView: UIView {
        
        typealias Actions = ProgressView.Actions
        
        var handle: ((Actions) -> Void)?
        
        var progress: Double = 0 {
            didSet {
                if isPaning { return }
                setNeedsLayout()
            }
        }
        
        var isEnabled: Bool {
            get { return isUserInteractionEnabled }
            set { isUserInteractionEnabled = newValue }
        }
        
        private var isPaning: Bool = false
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            backgroundColor = UIColor.clear
            addSubview(blockImageView)
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            let radius = blockImageView.bounds.width / 2.0
            let w = bounds.width - radius * 2
            let x = radius + w * CGFloat(progress)
            blockImageView.center = CGPoint(x: x, y: bounds.height / 2)
        }
        
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            isPaning = true
            guard let p = touches.first?.location(in: self) else { return }
            handle?(.began)
            pan(p)
        }
        
        override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
            isPaning = true
            guard let p = touches.first?.location(in: self) else { return }
            pan(p)
        }
        
        override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            isPaning = false
//            guard let p = touches.first?.location(in: self) else { return }
//            pan(p)
            handle?(.ended)
        }
        
        override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
            isPaning = false
            guard let p = touches.first?.location(in: self) else { return }
            pan(p)
            handle?(.cancelled)
        }
        
        @objc
        private func pan(_ point: CGPoint) {
            let radius = blockImageView.bounds.width / 2.0
            let w = bounds.width - radius * 2
            guard w > 0 else { return }
            let p = (point.x - radius) / w
            let x = max(radius, min(w + radius, point.x))
            blockImageView.center = CGPoint(x: x, y: bounds.height / 2)
            handle?(.progress(Double(p)))
        }
        
        private lazy var blockImageView: UIImageView = {
            let imageView = UIImageView(frame: CGRect(x: 0, y: (bounds.height - 32) / 2, width: 32, height: 32))
            imageView.backgroundColor = UIColor.clear
            imageView.image = UIImage.load(named: "btn_32_slider_nor")
            return imageView
        }()
    }
}

