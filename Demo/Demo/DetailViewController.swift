//
//  DetailViewController.swift
//  Demo
//
//  Created by SoalHunag on 2019/12/27.
//  Copyright © 2019 SoalHunag. All rights reserved.
//

import UIKit
import AVFoundation
import SnapKit
import VideoCache
import MediaPlayer

class CustomProvider: MediaPlayer.ProviderType {
    
    var playerItem: AVPlayerItem?
    
    required init() {
        
    }
    
    func cancel() {
        playerItem?.cacheCancel()
        playerItem = nil
    }
    
    func player(for id: MediaPlayer.IDType, _ completion: @escaping (Result<AVPlayerItem, Error>) -> Void) {
        let error = NSError(domain: ErrorDomain,
                            code: NSURLErrorFileDoesNotExist,
                            userInfo: [NSURLErrorFailingURLErrorKey : "Not Implementation"])
        completion(.failure(error))
    }
    
    func player(for url: MediaPlayer.URLType, _ completion: @escaping (Result<AVPlayerItem, Error>) -> Void) {
        guard let mediaUrl = url.url else {
            let error = NSError(domain: ErrorDomain,
                                code: NSURLErrorBadURL,
                                userInfo: [NSURLErrorFailingURLErrorKey : "bad url"])
            completion(.failure(error))
            return
        }
        let item = AVPlayerItem(url: mediaUrl)
        item.allowsCellularAccess = false
        self.playerItem = item
        completion(.success(item))
    }
}

class DetailViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSub(mediaPlayer)
        mediaPlayer.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        addSub(testButton)
        testButton.snp.makeConstraints {
            $0.width.equalTo(120)
            $0.height.equalTo(40)
            $0.center.equalToSuperview()
        }
        
        mediaZoomIn(false)
        mediaPlayer.send(event: .zoom(.in, false))
        mediaPlayer.send(event: .mask(.hide, true))
        
        let url = URL(string: "https://file-oss.putaocdn.com/static/blocks/build.mp4")!
        //let url = URL(string: "https://vod.putaocdn.com/pai_bloks_logo.mov?auth_key=1594721760-9962-0-9580856a9efebf9b1adc94a1eb186e02")!
        mediaPlayer.overlayView.titleView.title = "测试视频标题"
        mediaPlayer.overlayView.effectView.image = .name("bg")
        mediaPlayer.play(url: url)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        return .all
    }
    
    private lazy var mediaPlayer: MediaPlayer.PlayerView<CustomProvider, MediaPlayer.OverlayView> = {
        let player = MediaPlayer.PlayerView<CustomProvider, MediaPlayer.OverlayView>(delegate: self)
        player.overlayView.options = .all
        player.overlayView.titleView.options = .all
        player.overlayView.progressView.options = .normal
        player.overlayView.progressView.controls = .normal
        player.isAllowAudioPlayback = false
        return player
    }()
    
    private lazy var testButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(UIColor.red, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.setTitle("test", for: .normal)
        button.addTarget(self, action: #selector(testButtonTouched(_:)), for: .touchUpInside)
        button.layer.borderColor = UIColor.red.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 6
        return button
    }()
    
    @objc
    private func testButtonTouched(_ sender: UIButton) {
        if let _ = mediaPlayer.superview {
            mediaPlayer.removeFromSuper()
        } else {
            addSub(mediaPlayer)
            mediaPlayer.snp.makeConstraints { $0.edges.equalToSuperview() }
            testButton.bringToFront()
        }
    }
}

extension DetailViewController {
    
    private func mediaZoomIn(_ animate: Bool = true) {
        let animationClosure = {
            self.mediaPlayer.transform = .identity
            self.view.layoutIfNeeded()
        }
        if animate {
            UIView.animate(withDuration: 0.35, animations: animationClosure)
        } else {
            animationClosure()
        }
    }
    
    private func mediaZoomOut(_ animate: Bool = true) {
        let animationClosure = {
            self.mediaPlayer.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            self.view.layoutIfNeeded()
        }
        if animate {
            UIView.animate(withDuration: 0.35, animations: animationClosure)
        } else {
            animationClosure()
        }
    }
}

extension DetailViewController: MediaPlayer.PlayerViewDelegate {
    
    func playerView(_ playerView: MediaPlayer.PlayerViewType, event: MediaPlayer.Events) {
        
        print("event: \(event)")
        
        switch event {
            
        case .exit: navigationController?.popViewController(animated: true)
            
        case .play: break
            
        case .pause: break
            
        case .next: break
            
        case .singleTouched: break
            
        case .doubleTouched: break
            
        case .mask: break
            
        case .zoom(let action, let animate):
            switch action {
            case .in: mediaZoomIn(animate)
            case .out: mediaZoomOut(animate)
            }
            
        case .seek: break
        }
    }
    
    func playerView(_ playerView: MediaPlayer.PlayerViewType, status: MediaPlayer.Status) {
        
        if case .progress = status { } else {
            print("status: \(status)")
        }
        
        switch status {
            
        case .unknown: break
            
        case .loading: break
            
        case .ready: break
            
        case .failed: break
            
        case .paused: break
            
        case .stoped: break
            
        case .waiting: break
            
        case .playing: break
            
        case .endTime: break
            
        case .bufferEmpty: break
            
        case .keepUp: break
            
        case .progress: break
        }
    }
}
