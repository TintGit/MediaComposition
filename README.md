功能：多张图片合成视频、音视频合成、多段音频合成、多段视频合成、修改音视频音量

# 预览
![效果](https://ws3.sinaimg.cn/large/006tNc79ly1fz8jgqfif2g307k0dcmxu.gif)

![效果](https://ws2.sinaimg.cn/large/006tNc79ly1fz8jixv8a8g307k0dc783.gif)

# 使用 Cocoapods 导入
MediaComposition is available on [CocoaPods](http://cocoapods.org).  Add the following to your Podfile:

```ruby
pod 'MediaComposition'
```
# 目录
* 实现原理
* 配置
* 基本用法


## 实现原理
### 图片合成方案一
基于AVFoundation  
将图片转换CVPixelBufferRef 通过AVAssetWriter写入AVAssetWriterInput/AVAssetWriterInputPixelBufferAdaptor

### 图片合成方案二
基于AVFoundation Core Animation 
将图片添加到layer上 通过AVMutableComposition合成视频 
可以Core Animation 添加动画
### 音视频合成
基于AVFoundation


## 配置
* 视频分辨率 naturalSize
* 每张图片展示的时间 picTime
* frameNumber 帧率
* 动画效果 可修改图片 CALayerContentsGravity
* 方案一 需要自适配图片 否则 图片会被压缩 默认提供了一种方案(scaleAspectFit)
* 多段音频合成
* 音视频合成 
* 添加背景音乐
* 设置音频音量 背景音乐音量

## 基本用法
``` swift
let composition = MediaComposition()
//有动画
composition.imagesVideoAnimation(with: images, progress: { (progress) in
    print("合成进度",progress)
}, success: {[weak self] (path) in
    guard let `self` = self else {return}
    print("合成后地址",path)
}) { (errMessage) in
    print("合成失败",errMessage ?? "")
}

//音视频合成 添加背景音乐 修改音量
composition.bgMusicVideo(audioPath: audioPath, videoPath: videoPath, durationType: .audio_loopVideo, audioVolume: 0.1, musicPath: audioPath1, musicVolume: 1, progress: { (progress) in
    print("合成进度",progress)
}, success: {[weak self] (path) in
    guard let `self` = self else {return}
    print("合成后地址",path)
    self.path = path
}) { (errMessage) in
    print("合成失败",errMessage ?? "")
}

```







