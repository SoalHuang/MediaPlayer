//
//  EffectView.swift
//  MediaPlayer
//
//  Created by SoalHunag on 2019/12/27.
//  Copyright © 2019 SoalHunag. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher
import SDFoundation
import SDUIKit
import KingfisherExtension

open class EffectView: UIView, EffectViewType {
    
    open var image: ImageResource = .target(nil) {
        didSet {
            imageView.set(image: image)
        }
    }
    
    open func reset() {
        update(status: .unknown)
    }
    
    private var isReady: Bool = false
    private var progress: TimeInterval = 0
    
    private let animationKey: String = "com.soso.media.player.effect.animation.key"
    open func show(animate: Bool) {
        if animate {
            UIView.beginAnimations(animationKey, context: nil)
            UIView.setAnimationDuration(0.2)
        }
        self.alpha = 1
        if animate { UIView.commitAnimations()}
    }
    
    open func hide(animate: Bool) {
        if animate {
            UIView.beginAnimations(animationKey, context: nil)
            UIView.setAnimationDuration(0.2)
        }
        self.alpha = 0
        if animate { UIView.commitAnimations()}
    }
    
    open func update(status: Status) {
        
        switch status {
        case .unknown, .loading, .failed, .stoped:
            isReady = false
            show(animate: true)
        case .ready:
            isReady = true
        case .playing:
            if isReady, progress > 0.0 {
                hide(animate: true)
            }
        case .progress(let time):
            progress = time
            if isReady, progress > 0.0 {
                hide(animate: true)
            }
        default: break
        }
        
        if case .failed(let msg) = status {
            statusLabel.text = msg?.localizedDescription
            statusLabel.isHidden = false
        } else {
            statusLabel.text = nil
            statusLabel.isHidden = true
        }
    }
    
    open var effect: UIVisualEffect? {
        get { return effectView.effect }
        set { effectView.effect = newValue }
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
        
        addSub(imageView)
        addSub(effectView)
        addSub(statusLabel)
        
        imageView.snp.makeConstraints { $0.edges.equalToSuperview() }
        effectView.snp.makeConstraints { $0.edges.equalToSuperview() }
        statusLabel.snp.makeConstraints { $0.center.equalToSuperview() }
    }
    
    private lazy var effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    
    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 14.sd.autoScaleMax)
        label.numberOfLines = 4
        label.textAlignment = .center
        return label
    }()
    
    private lazy var imageView: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = UIView.ContentMode.scaleAspectFill
        return imgView
    }()
}
