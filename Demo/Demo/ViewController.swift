//
//  ViewController.swift
//  Demo
//
//  Created by SoalHunag on 2019/12/27.
//  Copyright © 2019 SoalHunag. All rights reserved.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(detailButton)
        detailButton.snp.makeConstraints {
            $0.width.equalTo(160)
            $0.height.equalTo(60)
            $0.center.equalToSuperview()
        }
    }
    
    private lazy var detailButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(UIColor.red, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.setTitle("Detail", for: .normal)
        button.addTarget(self, action: #selector(detailButtonTouched(_:)), for: .touchUpInside)
        button.layer.borderColor = UIColor.red.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 6
        return button
    }()
    
    @objc
    private func detailButtonTouched(_ sender: UIButton) {
        navigationController?.pushViewController(DetailViewController(), animated: true)
    }
}
