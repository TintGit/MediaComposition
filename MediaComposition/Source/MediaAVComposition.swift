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
    
    /// 音视频合成
    ///
    /// - Parameters:
    ///   - audioPath: 音频地址
    ///   - videoPath: 视频地址
    ///   - durationType: 合成时间
    ///   - progress: 合成进度
    ///   - success: 成功
    ///   - failure: 失败
    public func avVideo(audioPath: String?, videoPath: String?, durationType: MediaDurationType, progress: ProgressBlock?, success: SuccessBlock?, failure: FailureBlock?){
        self.bgMusicVideo(audioPath: audioPath, videoPath: videoPath, durationType: durationType, audioVolume: 1, musicPath: nil, musicVolume: 1, progress: progress, success: success, failure: failure)
    }
}

extension MediaComposition {
    
    /// 音视频合成 - 添加背景音乐
    ///
    /// - Parameters:
    ///   - audioPath: 音频地址
    ///   - videoPath: 视频地址
    ///   - durationType: 合成时间
    ///   - audioVolume: 音频音量
    ///   - musicPath: 背景音乐
    ///   - musicVolume: 背景音乐音量
    ///   - videoVolme: 背景视频的音量 默认 0 isMute == false 设置才会生效
    ///   - progress: 进度
    ///   - success: 成功
    ///   - failure: 失败
    public func bgMusicVideo(audioPath: String?, videoPath: String?, durationType: MediaDurationType, audioVolume: Float, musicPath: String?, musicVolume: Float?, videoVolme: Float = 0, progress: ProgressBlock?, success: SuccessBlock?, failure: FailureBlock?){
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
        let videoAudioAssetTrack = videoAsset.tracks(withMediaType: .audio).first
        let composition = AVMutableComposition()
        let videoCompositionTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        let audioCompositionTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        let videoAudioCompositionTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
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
            if !isMute { //保留视频原生
                if let _ = videoAudioAssetTrack {
                    try? videoAudioCompositionTrack?.insertTimeRange(endTime, of: videoAudioAssetTrack!, at: .zero)
                }
            }
            try? videoCompositionTrack?.insertTimeRange(endTime, of: videoAssetTrack, at: .zero)
        }else {//循环视频
            let loopCount = audioDurtion / videoDurtion
            let residue = audioDurtion - (videoDurtion * loopCount)
            print("循环视频\(loopCount)次 + \(residue)秒")
            var duration = CMTime.zero
            for _ in 0..<loopCount {
                try? videoCompositionTrack?.insertTimeRange(CMTimeRange(start: .zero, duration: videoAsset.duration), of: videoAssetTrack, at: duration)
                if !isMute { //保留视频原生
                    if let _ = videoAudioAssetTrack {
                        try? videoAudioCompositionTrack?.insertTimeRange(CMTimeRange(start: .zero, duration: videoAsset.duration), of: videoAudioAssetTrack!, at: duration)
                    }
                }
                duration = CMTimeAdd(duration, videoAsset.duration)
            }
            if residue > 0 {
                let dura = CMTime(value: CMTimeValue(residue), timescale: 1)
                try? videoCompositionTrack?.insertTimeRange(CMTimeRange(start: .zero, duration: dura), of: videoAssetTrack, at: duration)
                if !isMute { //保留视频原生
                    if let _ = videoAudioAssetTrack {
                        try? videoAudioCompositionTrack?.insertTimeRange(CMTimeRange(start: .zero, duration: dura), of: videoAudioAssetTrack!, at: duration)
                    }
                }
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
        
        //音量设置
        let audioMix: AVMutableAudioMix = AVMutableAudioMix()
        var audioMixParam: [AVMutableAudioMixInputParameters] = []
        let audioParam: AVMutableAudioMixInputParameters = AVMutableAudioMixInputParameters(track: audioAssetTrack)
        audioParam.trackID = audioCompositionTrack?.trackID ?? kCMPersistentTrackID_Invalid
        audioParam.setVolume(audioVolume, at: .zero)
        audioMixParam.append(audioParam)
        
        if !isMute { //保留视频原生
            if let _ = videoAudioAssetTrack {
                let videoAudioParam: AVMutableAudioMixInputParameters = AVMutableAudioMixInputParameters(track: videoAudioAssetTrack)
                videoAudioParam.trackID = videoAudioCompositionTrack?.trackID ?? kCMPersistentTrackID_Invalid
                videoAudioParam.setVolume(videoVolme, at: .zero)
                audioMixParam.append(videoAudioParam)
            }
        }
        
        //合成配乐
        if let musicP = musicPath{
            let musicURL = URL(fileURLWithPath: musicP)
            let musicAsset = AVURLAsset(url: musicURL)
            guard let musicAssetTrack = musicAsset.tracks(withMediaType: .audio).first else {
                return
            }
            let musicCompositionTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
            
            let musicDuration = musicAsset.mc_mediaDuration()
            let totolDuration = Int(CMTimeGetSeconds(endTime.duration))
            
            if musicDuration >= totolDuration {
                try? musicCompositionTrack?.insertTimeRange(endTime, of: musicAssetTrack, at: .zero)
            }else {
                
                let loopCount = totolDuration / musicDuration
                let residue = totolDuration - (musicDuration * loopCount)
                var musicDuration = CMTime.zero
                print("循环配乐频\(loopCount)次 + \(residue)秒")
                for _ in 0..<loopCount {
                    try? musicCompositionTrack?.insertTimeRange(CMTimeRange(start: .zero, duration: musicAsset.duration), of: musicAssetTrack, at: musicDuration)
                    musicDuration = CMTimeAdd(musicDuration, musicAsset.duration)
                }
                
                if residue > 0 {
                    let dura = CMTime(value: CMTimeValue(residue), timescale: 1)
                    try? musicCompositionTrack?.insertTimeRange(CMTimeRange(start: .zero, duration: dura), of: musicAssetTrack, at: musicDuration)
                }
            }
            let musicParam: AVMutableAudioMixInputParameters = AVMutableAudioMixInputParameters(track: musicAssetTrack)
            musicParam.trackID = musicCompositionTrack?.trackID ?? kCMPersistentTrackID_Invalid
            musicParam.setVolume(musicVolume ?? 1, at: CMTime.zero)
            audioMixParam.append(musicParam)
        }
        audioMix.inputParameters = audioMixParam
        setupAssetExport(composition, videoCom: nil, audioMix: audioMix)
    }
}
