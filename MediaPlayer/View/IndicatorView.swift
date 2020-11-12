//
//  IndicatorView.swift
//  MediaPlayer
//
//  Created by SoalHunag on 2019/12/27.
//  Copyright © 2019 SoalHunag. All rights reserved.
//

import UIKit

open class IndicatorView: UIView, IndicatorViewType {
    
    open func reset() {
        isAnimating = true
    }
    
    open func update(status: Status) {
        switch status {
        case .unknown, .waiting, .loading, .bufferEmpty:
            isAnimating = true
        case .playing, .failed:
            isAnimating = false
        default: break
        }
    }
    
    open var isAnimating: Bool {
        get { return imageView.isAnimating }
        set {
            if newValue {
                imageView.startAnimating()
                UIView.animate(withDuration: 0.2) { self.alpha = 1 }
            } else {
                imageView.stopAnimating()
                UIView.animate(withDuration: 0.2) { self.alpha = 0 }
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
        
        isUserInteractionEnabled = false
        
        addSub(textLabel)
        addSub(imageView)
        
        imageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.width.height.equalTo(48.sd.autoScaleMax)
            $0.left.greaterThanOrEqualToSuperview()
            $0.right.lessThanOrEqualToSuperview()
            $0.centerX.equalToSuperview()
        }
        textLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(16.sd.autoScaleMax)
            $0.bottom.equalToSuperview()
            $0.left.greaterThanOrEqualToSuperview()
            $0.right.lessThanOrEqualToSuperview()
            $0.centerX.equalToSuperview()
        }
        
        isAnimating = false
    }
    
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 16.sd.autoScaleMax)
        label.text = "视频加载中,请稍候..."
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.clear
        imageView.contentMode = UIView.ContentMode.scaleAspectFit
        imageView.animationImages = (0...10).compactMap {
            UIImage.load(named: String(format: "ani_bloks_loading_%0.2d", $0))
        }
        imageView.animationDuration = 1
        return imageView
    }()
}
