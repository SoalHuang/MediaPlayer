# PTMediaPlayer
### 使用库
* [SnapKit](https://github.com/SnapKit/SnapKit.git)
* [Kingfisher](https://github.com/onevcat/Kingfisher.git)
* [lottie-ios](https://github.com/SoalHuang/lottie-ios.git)
* [PTFoundation](http://code.putao.io/ios_client/PTFoundation.git)
* [PTUIKit](http://code.putao.io/ios_client/PTUIKit.git)
* [KingfisherExtension](http://code.putao.io/ios_client/KingfisherExtension.git)

### 功能
* 资源委托外部传入.
* 附加层可任意定制.
* 事件和状态回调尽量精简.

### 使用
```swift
let player = PTMediaPlayer.PlayerView<CustomProvider, PTMediaPlayer.OverlayView>(delegate: self)
player.overlayView.options = .all
player.overlayView.titleView.options = .all
player.overlayView.progressView.options = .normal
player.overlayView.progressView.controls = .normal

view.addSubview(player)

mediaZoomIn(false)
mediaPlayer.send(event: .zoom(.in, false))
mediaPlayer.send(event: .mask(.hide, true))

let url = URL(string: <#Media URL#>)
mediaPlayer.overlayView.titleView.title = "Test Media Title"
mediaPlayer.overlayView.effectView.image = .name(<#Image Name#>)
mediaPlayer.play(url: url)
        
```
