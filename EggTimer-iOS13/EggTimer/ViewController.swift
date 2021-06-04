//
//  ViewController.swift
//  EggTimer
//
//  Created by Angela Yu on 08/07/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    
    var player: AVAudioPlayer!
    
    let boilTime: [Int] = [5, 7, 12]
    let boilDict : [String: Int] = [
        "Soft": 5,
        "Medium": 7,
        "Hard": 12
    ]
    
    var timer: Timer = Timer()
    var timePassed = 0
    var totalTime = 0
    
    @IBAction func hardnessSelection(_ sender: UIButton) {
        timer.invalidate()
        progressBar.progress = 0.0
        timePassed = 0
        let hardness = sender.currentTitle
        totalTime = boilDict[hardness!]!
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer(){
        if timePassed < totalTime{
            progressBar.progress = Float(timePassed) / Float(totalTime)
            timePassed += 1
        } else {
            timer.invalidate()
            progressBar.progress = 1.0
            titleLabel.text = "Done"
            
            let url = Bundle.main.url(forResource: "alarm_sound", withExtension: "mp3")
            player = try! AVAudioPlayer(contentsOf: url!)
            player.play()
        }
    }
}
