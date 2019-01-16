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

    lazy var com: MediaComposition = {
        let temp = MediaComposition()
        return temp
    }()
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
        let image4 = UIImage(named: "kxkX@2x")
        self.images = [image1, image2, image4,image3, image2, image3, image1]
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
    @IBAction func playAction(_ sender: UIButton) {
        guard let path = path else { return }
        let ctrl = AVPlayerViewController()
        ctrl.player = AVPlayer(url: URL(fileURLWithPath: path))
        self.present(ctrl, animated: true, completion: nil)
    }
}

