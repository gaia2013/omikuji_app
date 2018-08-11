//
//  ViewController.swift
//  OmikujiApp
//
//  Created by 山口仁志 on 2018/08/11.
//  Copyright © 2018年 OmikujiApp.hitoshi. All rights reserved.
//

import UIKit
import CoreMotion
import AVFoundation

class ViewController: UIViewController {
    // 加速度センサーを使うためのオブジェクトを格納します。
    let motionManager: CMMotionManager = CMMotionManager()
    // iPhoneを振った音を出すための再生オブジェクトを格納します。
    var audioPlayer: AVAudioPlayer = AVAudioPlayer()
    
    // アプリで使用する音の準備
    func setupSound() {
        // iPhoneを振った時の音を設定します。
        if let sound = Bundle.main.path(forResource: "syakasyaka", ofType: ".mp3") {
            audioPlayer = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: sound))
            audioPlayer.prepareToPlay()
        }
    }

    // 加速度センサーからの値取得の開始とその処理
    func startGetAccelerometer() {
        // 加速度センサーの検出間隔を指定
        motionManager.accelerometerUpdateInterval = 1 / 50
        
        // 検出開始と検出後の処理
        motionManager.startAccelerometerUpdates(to: OperationQueue.main) { (accelerometerData: CMAccelerometerData?, error: Error?) in
            
            if let acc = accelerometerData {
                // 各角度への合計速度を取得します。
                let x = acc.acceleration.x
                let y = acc.acceleration.y
                let z = acc.acceleration.z
                let synthetic = (x * x) + (y * y) + (z * z)
                
                // 一定以上の速度になったら音を鳴らします。
                if synthetic >= 8 {
                    self.audioPlayer.play()
                }
            }
        }
    }

    @IBOutlet weak var overView: UIView!
    @IBOutlet weak var bigLabel: UILabel!
    @IBAction func tapRetryButton(_ sender: UIButton) {
        overView.isHidden = true
        stickButtomMargin.constant = 0
        startGetAccelerometer()
        self.overView.alpha = 0
    }
    @IBOutlet weak var stickView: UIView!
    @IBOutlet weak var stickLabel: UILabel!
    @IBOutlet weak var stickHeight: NSLayoutConstraint!
    @IBOutlet weak var stickButtomMargin: NSLayoutConstraint!
    
    let resultTexts: [String] = [
        "very good!",
        "middle good",
        "good",
        "soso",
        "bad",
        "middle bad",
        "very bad!"
    ]
     
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion != UIEventSubtype.motionShake || overView.isHidden == false {
            // シェイクモーション以外では動作させない
            // 結果の表示中は動作させない
            return
        }
        
        let resultNum = Int( arc4random_uniform(UInt32(resultTexts.count)) )
        stickLabel.text = resultTexts[resultNum]
        stickButtomMargin.constant = stickHeight.constant * -1
        
        UIView.animate(withDuration: 1.0, animations: {
            self.view.layoutIfNeeded()
        }, completion: { (finished: Bool) in
            
             self.bigLabel.text = self.stickLabel.text
             self.overView.isHidden = false
            
            UIView.animate(withDuration: 0.6, animations: {
                self.overView.alpha = 1
            })
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // 音の準備
        setupSound()
        
        // 結果アニメーションの初期値
        overView.alpha = 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

