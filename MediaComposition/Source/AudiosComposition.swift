//
//  AudiosComposition.swift
//  MediaComposition
//
//  Created by 闫明 on 2019/1/17.
//  Copyright © 2019 闫明. All rights reserved.
//

import UIKit
import AVFoundation
extension MediaComposition {
    
    /// 多段音频合成
    ///
    /// - Parameters:
    ///   - paths: 音频地址数组
    ///   - progress: 进度
    ///   - success: 成功
    ///   - failure: 失败
    public func audios(paths: [String?], progress: ProgressBlock?, success: SuccessBlock?, failure: FailureBlock?){
        self.outputPath = NSTemporaryDirectory() + "audiosComposition.mp4"
        self.progress = progress
        self.success = success
        self.failure = failure
        let composition = AVMutableComposition()
        let audioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        var time = CMTime.zero
        for path in paths {
            guard let path = path else {break}
            let audioAsset = AVURLAsset(url: URL(fileURLWithPath: path))
            let timeRange = CMTimeRange(start: .zero, duration: audioAsset.duration)
            if let audioAssetTrack = audioAsset.tracks(withMediaType: .audio).first {
                try? audioTrack?.insertTimeRange(timeRange, of: audioAssetTrack, at: time)
                time = CMTimeAdd(time, audioAsset.duration)
            }
        }
        self.setupAssetExport(composition, videoCom: nil)
    }
}
