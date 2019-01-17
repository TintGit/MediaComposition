//
//  MediaAVComposition.swift
//  MediaComposition
//
//  Created by 闫明 on 2019/1/17.
//  Copyright © 2019 闫明. All rights reserved.
//

import UIKit
import AVFoundation

/// 音视频合成时间长度
///
/// - video: 视频时间为总时间
/// - audio: 音频时间为总时间
/// - custom: 自定义时间 (单位/s)
/// - video_loopAudio: 视频时间为总时间 并循环音频
/// - audio_loopVideo: 音频时间为总时间 并循环视频

public enum MediaDurationType {
    case video
    case audio
    case custom(duration: Int)
    case video_loopAudio
    case audio_loopVideo
}
// MARK: - 音视频合成
extension MediaComposition {
    public func video(audioPath: String?, videoPath: String?, durationType: MediaDurationType, progress: ProgressBlock?, success: SuccessBlock?, failure: FailureBlock?){
        guard let audioPath = audioPath, let videoPath = videoPath else {
            failure?(nil)
            return
        }
        self.outputPath = NSTemporaryDirectory() + "avComposition.mp4"
        self.progress = progress
        self.success = success
        self.failure = failure
        let audioURL = URL(fileURLWithPath: audioPath)
        let videoURL = URL(fileURLWithPath: videoPath)
        let audioAsset = AVURLAsset(url: audioURL)
        let videoAsset = AVURLAsset(url: videoURL)
        guard let videoAssetTrack = videoAsset.tracks(withMediaType: .video).first else {return}
        guard let audioAssetTrack = audioAsset.tracks(withMediaType: .audio).first else {return}
        
        let composition = AVMutableComposition()
        let videoCompositionTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        let audioCompositionTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        var endTime = CMTimeRange()
        var loopAudio = false
        var loopVideo = false
        let audioDurtion = audioAsset.mc_mediaDuration()
        let videoDurtion = videoAsset.mc_mediaDuration()
        switch durationType {
        case .audio:
            endTime = CMTimeRange(start: .zero, duration: audioAsset.duration)
            break
        case .video:
            endTime = CMTimeRange(start: .zero, duration: videoAsset.duration)
            break
        case .custom(let duration):
            endTime = CMTimeRange(start: .zero, end: CMTime(value: CMTimeValue(duration), timescale: 1))
            break
        case .video_loopAudio:
            endTime = CMTimeRange(start: .zero, duration: videoAsset.duration)
            if audioDurtion < videoDurtion {
                loopAudio = true
            }
            break
        case .audio_loopVideo:
            endTime = CMTimeRange(start: .zero, duration: audioAsset.duration)
            if videoDurtion < audioDurtion {
                loopVideo = true
            }
            break
        }
        if !loopVideo {
            try? videoCompositionTrack?.insertTimeRange(endTime, of: videoAssetTrack, at: .zero)
        }else {//循环视频
            let loopCount = audioDurtion / videoDurtion
            let residue = audioDurtion - (videoDurtion * loopCount)
            print("循环视频\(loopCount)次 + \(residue)秒")
            var duration = CMTime.zero
            for _ in 0..<loopCount {
                try? videoCompositionTrack?.insertTimeRange(CMTimeRange(start: .zero, duration: videoAsset.duration), of: videoAssetTrack, at: duration)
                duration = CMTimeAdd(duration, videoAsset.duration)
            }
            if residue > 0 {
                let dura = CMTime(value: CMTimeValue(residue), timescale: 1)
                try? videoCompositionTrack?.insertTimeRange(CMTimeRange(start: .zero, duration: dura), of: videoAssetTrack, at: duration)
            }
        }
        if !loopAudio {
            try? audioCompositionTrack?.insertTimeRange(endTime, of: audioAssetTrack, at: .zero)
        }else {//循环音频
            let loopCount = videoDurtion / audioDurtion
            let residue = videoDurtion - (audioDurtion * loopCount)
            print("循环音频\(loopCount)次 + \(residue)秒")
            var duration = CMTime.zero
            for _ in 0..<loopCount {
                try? audioCompositionTrack?.insertTimeRange(CMTimeRange(start: .zero, duration: audioAsset.duration), of: audioAssetTrack, at: duration)
                duration = CMTimeAdd(duration, audioAsset.duration)
            }
            if residue > 0 {
                let dura = CMTime(value: CMTimeValue(residue), timescale: 1)
                try? audioCompositionTrack?.insertTimeRange(CMTimeRange(start: .zero, duration: dura), of: audioAssetTrack, at: duration)
            }
        }
        setupAssetExport(composition, videoCom: nil)
    }
    
}
