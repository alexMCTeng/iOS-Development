//
//  ViewController.swift
//  Quizzler-iOS13
//
//  Created by Angela Yu on 12/07/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var trueButton: UIButton!
    @IBOutlet weak var falseButton: UIButton!
    
    var quizBrain = QuizBrain()
    
    var timer: Timer = Timer()
            
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }

    @IBAction func btnPressed(_ sender: UIButton) {
        
        let userAnswer = sender.currentTitle
        
        if quizBrain.checkAnswer(userAnswer!){
            sender.layer.cornerRadius = 20
            sender.backgroundColor = UIColor.green
        } else{
            sender.layer.cornerRadius = 20
            sender.backgroundColor = UIColor.red
        }
                
        timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(updateUI), userInfo: nil, repeats: false)
    }
    
    @objc func updateUI(){
        questionLabel.text = quizBrain.getQuestionText()
        progressBar.progress = quizBrain.getProgress()
        trueButton.backgroundColor = UIColor.clear
        falseButton.backgroundColor = UIColor.clear
    }
}

