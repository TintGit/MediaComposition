//
//  ViewController.swift
//  MediaComposition
//
//  Created by 闫明 on 2019/1/16.
//  Copyright © 2019 闫明. All rights reserved.
//

import UIKit
import AVKit
class ViewController: UIViewController {

    
    var path: String?
    var images: [UIImage?] = []
    lazy var composition: MediaComposition = {
        let temp = MediaComposition()
        return temp
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        let image1 = UIImage(named: "cheese@2x")
        let image2 = UIImage(named: "kxk@2x")
        let image3 = UIImage(named: "guide@2x")
        self.images = [image1, image2, image3]
    }
    
    @IBAction func compositionAnimationAction(_ sender: UIButton) {
        composition.videoAnimation(with: images, progress: { (progress) in
            print("合成进度",progress)
        }, success: {[weak self] (path) in
            guard let `self` = self else {return}
            print("合成后地址",path)
            self.path = path
        }) { (errMessage) in
            print("合成失败",errMessage ?? "")
        }
    }
    @IBAction func compositionAction(_ sender: UIButton) {
        composition.video(with: images, progress: { (progress) in
            //print("合成进度",progress)
        }, success: {[weak self] (path) in
            guard let `self` = self else {return}
            print("合成后地址",path)
            self.path = path
            
        }) { (errMessage) in
            print("合成失败",errMessage ?? "")
        }
    }
    @IBAction func avAction(_ sender: UIButton) {
        let audioPath = Bundle.main.path(forResource: "直到世界尽头", ofType: "mp3")
        let videoPath = NSTemporaryDirectory() + "imagesComposition.mp4"
        //let videoPath = Bundle.main.path(forResource: "black", ofType: "mp4")
        //let type = MediaDurationType.custom(duration: 15)
        composition.video(audioPath: audioPath, videoPath: videoPath, durationType: .audio_loopVideo, progress: { (progress) in
            print("合成进度",progress)
        }, success: {[weak self] (path) in
            guard let `self` = self else {return}
            print("合成后地址",path)
            self.path = path
            
        }) { (errMessage) in
            print("合成失败",errMessage ?? "")
        }
    }
    
    @IBAction func audiosAction(_ sender: UIButton) {
        let audioPath1 = Bundle.main.path(forResource: "record1", ofType: "aac")
        let audioPath2 = Bundle.main.path(forResource: "record2", ofType: "aac")
        let audioPath3 = Bundle.main.path(forResource: "record3", ofType: "aac")
        composition.audios(paths: [audioPath1, audioPath2, audioPath3], progress: { (progress) in
            print("合成进度",progress)
        }, success: {[weak self] (path) in
            guard let `self` = self else {return}
            print("合成后地址",path)
            self.path = path
            
        }) { (errMessage) in
            print("合成失败",errMessage ?? "")
        }
    }
    @IBAction func playAction(_ sender: UIButton) {
        guard let path = path else { return }
        let ctrl = AVPlayerViewController()
        ctrl.player = AVPlayer(url: URL(fileURLWithPath: path))
        self.present(ctrl, animated: true, completion: nil)
    }
}

