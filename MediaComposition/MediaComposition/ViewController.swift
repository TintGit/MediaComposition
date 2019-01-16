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
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func compositionAction(_ sender: UIButton) {
        let image1 = UIImage(named: "cheese@2x")
        let image2 = UIImage(named: "kxk@2x")
        let image3 = UIImage(named: "talk_newGuide@2x")
        let images: [UIImage?] = [image1, image2, image3, image2, image3, image1]
        let compos = MediaComposition()
        compos.video(with: images, progress: { (progress) in
            print("合成进度",progress)
        }, success: {[weak self] (path) in
            guard let `self` = self else {return}
            self.path = path
            print("合成后地址",path)
        }) { (errMessage) in
            print("合成失败",errMessage)
        }
    }
    @IBAction func playAction(_ sender: UIButton) {
        guard let path = path else { return }
        let ctrl = AVPlayerViewController()
        ctrl.player = AVPlayer(url: URL(fileURLWithPath: path))
        self.present(ctrl, animated: true, completion: nil)
    }
}

