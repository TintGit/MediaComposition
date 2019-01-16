//
//  MediaComposition.swift
//  MediaComposition
//
//  Created by 闫明 on 2019/1/16.
//  Copyright © 2019 闫明. All rights reserved.
//

import UIKit
import AVFoundation
public class MediaComposition: NSObject {
    /// 视频合成后地址 默认 tmp/imagesComposition.mp4
    public var outputPath: String?
    /// 视频分辨率
    public var naturalSize: CGSize = CGSize(width: 720, height: 1280)
    /// 每张图片展示的时间
    public var picTime: Int = 3
    /// 视频背景 本地地址 默认black.mp4
    public var videoResource: String?
    public typealias SuccessBlock = (String)->()
    public typealias ProgressBlock = (Float)->()
    public typealias FailureBlock = (String?)->()
    private var timer: Timer?
    private var assetExport: AVAssetExportSession?
    /// 视频时长 /s
    private var duration: Int = 0
    private var progress: ProgressBlock?
    private var success: SuccessBlock?
    private var failure: FailureBlock?
    deinit {
        timerDeinit()
    }
}
extension MediaComposition {
    
    /// 图片合成视频 切换特效
    ///
    /// - Parameters:
    ///   - images: 图片数组
    ///   - progress: 进度回调
    ///   - success: 成功回调 合成视频地址
    ///   - failure: 失败回调
    public func video(with images:[UIImage?], progress: ProgressBlock?, success: SuccessBlock?, failure: FailureBlock?){
        guard let videoPath = videoResource == nil ? Bundle.main.path(forResource: "black", ofType: "mp4") : videoResource else {
            failure?("资源出错")
            return
        }
        //视频的时长 - (图片个数 * 每张图片的展示时间) 目前默认背景视频3分钟 仅支持不超过3分钟
        let tempDuration = images.count * picTime
        self.duration = tempDuration > 180 ? 180 : tempDuration
        self.progress = progress
        self.failure = failure
        self.success = success
        let videoAsset = AVURLAsset(url: URL(fileURLWithPath: videoPath))
        let mutableComposition = AVMutableComposition()
        guard let videoCompositionTrack = mutableComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid), let videoAssetTrack = videoAsset.tracks(withMediaType: .video).first else {
            failure?("视频轨道出错")
            return
        }
        //合成视频时间
        let endTime = CMTime(value: CMTimeValue(videoAsset.duration.timescale * Int32(duration)), timescale: videoAsset.duration.timescale)
        let timeR = CMTimeRangeMake(start: .zero, duration: endTime)
        do {
            try videoCompositionTrack.insertTimeRange(timeR, of: videoAssetTrack, at: .zero)
        }catch {
            failure?(error.localizedDescription)
            return
        }
        //创建合成指令
        let videoCompostionInstruction = AVMutableVideoCompositionInstruction()
        //设置时间范围
        videoCompostionInstruction.timeRange = timeR
        //创建层指令，并将其与合成视频轨道相关联
        let videoLayerInstruction = AVMutableVideoCompositionLayerInstruction.init(assetTrack: videoCompositionTrack)
        videoLayerInstruction.setTransform(videoAssetTrack.preferredTransform, at: .zero)
        videoLayerInstruction.setOpacity(0, at: endTime)
        videoCompostionInstruction.layerInstructions = [videoLayerInstruction]
        //创建视频组合
        let mutableVideoComposition = AVMutableVideoComposition()
        mutableVideoComposition.renderSize = naturalSize
        //设置帧率
        mutableVideoComposition.frameDuration = CMTime(value: 1, timescale: 25)
        mutableVideoComposition.instructions = [videoCompostionInstruction]
        addLayer(mutableVideoComposition, imgs: images)
        setupAssetExport(mutableComposition, videoCom: mutableVideoComposition)
    }
}
extension MediaComposition {
    private func setupAssetExport(_ mutableComposition: AVMutableComposition, videoCom: AVMutableVideoComposition){
        var path = NSTemporaryDirectory() + "imagesComposition.mp4"
        if let outputPath = outputPath {
            path = outputPath
        }
        self.assetExport = AVAssetExportSession(asset: mutableComposition, presetName: AVAssetExportPresetHighestQuality)
        assetExport?.outputFileType = AVFileType.mp4
        if FileManager.default.fileExists(atPath: path) {
            try? FileManager.default.removeItem(atPath: path)
        }
        assetExport?.outputURL = URL(fileURLWithPath: path)
        assetExport?.shouldOptimizeForNetworkUse = true
        assetExport?.videoComposition = videoCom
        setupTimer()
        assetExport?.exportAsynchronously(completionHandler: {[weak self] in
            guard let `self` = self, let export = self.assetExport else {return}
            self.timerDeinit()
            switch export.status {
            case .completed:
                self.success?(path)
                break
            default:
                print(export.status)
                self.failure?("合成失败")
                break
            }
        })
    }
}
// MARK: - 图片切换效果
extension MediaComposition {
    private func addLayer(_ composition: AVMutableVideoComposition, imgs: [UIImage?]){
        let bgLayer = CALayer()
        bgLayer.frame = CGRect(x: 0, y: 0, width: naturalSize.width, height: naturalSize.height)
        bgLayer.position = CGPoint(x: naturalSize.width / 2, y: naturalSize.height / 2)
        var imageLayers: [CALayer] = []
        for temp in imgs {
            let imageL = CALayer()
            imageL.contents = temp?.cgImage
            imageL.bounds = CGRect(x: 0, y: 0, width: naturalSize.width, height: naturalSize.height)
            imageL.contentsGravity = .resizeAspect
            imageL.backgroundColor = UIColor.black.cgColor
            imageL.anchorPoint = CGPoint.init(x: 0, y: 0)
            bgLayer.addSublayer(imageL)
            imageLayers.append(imageL)
        }
        positionAni(layers: imageLayers)
        let parentLayer = CALayer()
        let videoLayer = CALayer()
        parentLayer.frame = CGRect(x: 0, y: 0, width: naturalSize.width, height: naturalSize.height)
        videoLayer.frame = CGRect(x: 0, y: 0, width: naturalSize.width, height: naturalSize.height)
        parentLayer.addSublayer(videoLayer)
        parentLayer.addSublayer(bgLayer)
        parentLayer.isGeometryFlipped = true
        composition.animationTool = AVVideoCompositionCoreAnimationTool.init(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
    }
    private func positionAni(layers: [CALayer]){
        for (index, layer) in layers.enumerated() {
            let animation = CABasicAnimation()
            animation.timingFunction = CAMediaTimingFunction.init(name: .easeInEaseOut)
            animation.isRemovedOnCompletion = false
            animation.beginTime = 0.3 + Double(picTime * index)
            animation.fromValue = NSValue.init(cgPoint: CGPoint.init(x: naturalSize.width * CGFloat(index), y: 0))
            animation.toValue = NSValue.init(cgPoint: CGPoint.init(x: 0, y: 0))
            animation.duration = 0.3
            animation.fillMode = .both
            layer.add(animation, forKey: "position")
        }
    }
}
// MARK: - Timer
extension MediaComposition {
    private func setupTimer(){
        self.timer = Timer(timeInterval: 0.05, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        RunLoop.main.add(self.timer!, forMode: .common)
    }
    @objc private func timerAction(){
        guard let export = self.assetExport else { return }
        self.progress?(export.progress)
    }
    private func timerDeinit(){
        self.timer?.invalidate()
        self.timer = nil
    }
}
