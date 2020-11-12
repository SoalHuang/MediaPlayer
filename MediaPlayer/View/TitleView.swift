//
//  TitleView.swift
//  MediaPlayer
//
//  Created by SoalHunag on 2019/12/27.
//  Copyright © 2019 SoalHunag. All rights reserved.
//

import UIKit
import SnapKit
import SDFoundation
import SDUIKit

open class TitleView: UIView, TitleViewType {
    
    open var exitHandle: (() -> Void)?
    
    open var title: String? {
        get { return titleLabel.text }
        set { titleLabel.text = newValue }
    }
    
    open var attributedTitle: NSAttributedString? {
        get { return titleLabel.attributedText }
        set { titleLabel.attributedText = newValue }
    }
    
    open var titleWidthMultiplied: CGFloat = 1
    
    /// default is .none
    open var options: TitleViewOptions {
        get {
            var opt: TitleViewOptions = []
            if !titleLabel.isHidden { opt = opt.union(.title) }
            if !exitButton.isHidden { opt = opt.union(.exit) }
            return opt
        }
        set {
            titleLabel.isHidden = !newValue.contains(.title)
            exitButton.isHidden = !newValue.contains(.exit)
            gradientView.isHidden = titleLabel.isHidden && exitButton.isHidden
            if exitButton.isHidden, !titleLabel.isHidden {
                titleLabel.snp.remakeConstraints {
                    $0.top.bottom.equalToSuperview()
                    $0.left.equalTo(Constants.SafeArea.left + 6.sd.autoScaleMax)
                    $0.width.equalToSuperview().multipliedBy(titleWidthMultiplied)
                }
            } else {
                titleLabel.snp.makeConstraints {
                    $0.top.bottom.equalToSuperview()
                    $0.left.equalTo(exitButton.snp.right)
                    $0.width.equalToSuperview().multipliedBy(titleWidthMultiplied)
                }
            }
        }
    }
    
    open func reset() {
        titleLabel.attributedText = nil
    }
    
    private let animationKey = "com.soso.media.player.titleView.animation.key"
    
    open func send(event: Events) {
        guard case .zoom(let action, let animate) = event else { return }
        
        if animate {
            UIView.beginAnimations(animationKey, context: nil)
            UIView.setAnimationDuration(0.2)
        }
        
        if action ~= .in {
            exitButton.alpha = 1
            titleLabel.snp.remakeConstraints {
                $0.top.bottom.equalToSuperview()
                $0.left.equalTo(exitButton.snp.right)
                $0.width.equalToSuperview()
            }
        } else {
            exitButton.alpha = 0
            titleLabel.snp.remakeConstraints {
                $0.top.bottom.equalToSuperview()
                $0.left.equalTo(20.sd.autoScaleMax)
                $0.width.equalToSuperview().multipliedBy(titleWidthMultiplied)
            }
        }
        
        if animate {
            layoutIfNeeded()
            UIView.commitAnimations()
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
        
        addSub(gradientView)
        addSub(titleLabel)
        addSub(exitButton)
        
        gradientView.snp.makeConstraints { $0.edges.equalToSuperview() }
        exitButton.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.height.equalToSuperview()
            $0.width.equalTo(exitButton.snp.height)
        }
        titleLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.left.equalTo(exitButton.snp.right)
            $0.width.equalToSuperview().multipliedBy(titleWidthMultiplied)
        }
        
        options = .none
        
        titleLabel.isHidden = true
        exitButton.isHidden = true
        gradientView.isHidden = titleLabel.isHidden && exitButton.isHidden
    }
    
    private lazy var gradientView = GradientView()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var exitButton: UIButton = {
        var button = UIButton()
        button.setImage(UIImage.load(named: "btn_44_back_nor"), for: .normal)
        button.sd.delayInterval = 1
        button.sd.on { [weak self] _ in self?.exitHandle?() }
        return button
    }()
}

extension TitleView {
    
    class GradientView: UIView {
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setup()
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setup()
        }
        
        private func setup() {
            layer.sd.gradientApply(frame: bounds,
                                   start: CGPoint(x: 0.5, y: 0),
                                   end: CGPoint(x: 0.5, y: 1),
                                   colors: [UIColor(hex: 0x333333).withAlphaComponent(0.75),
                                            UIColor(hex: 0x333333).withAlphaComponent(0)])
        }
        
        public override func layoutSubviews() {
            super.layoutSubviews()
            layer.sd.gradientLayer?.frame = bounds
        }
    }
}
