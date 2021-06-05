//
//  ViewController.swift
//  Destini-iOS13
//
//  Created by Angela Yu on 08/08/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var storyLabel: UILabel!
    @IBOutlet weak var choice1Button: UIButton!
    @IBOutlet weak var choice2Button: UIButton!
    
    var storyBrain = StoryBrain()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI(0)
    }


    @IBAction func choiceMade(_ sender: UIButton) {
        
        let currentStory = storyBrain.storyArr[storyBrain.currentIndex]
        if sender.currentTitle?.caseInsensitiveCompare(currentStory.choice1) == ComparisonResult.orderedSame{
            updateUI(currentStory.choice1Destination)
            storyBrain.currentIndex = currentStory.choice1Destination
        } else{
            updateUI(currentStory.choice2Destination)
            storyBrain.currentIndex = currentStory.choice2Destination
        }
    }
    
    func updateUI(_ index: Int){
        storyLabel.text = storyBrain.storyArr[index].title
        choice1Button.setTitle(storyBrain.storyArr[index].choice1, for: .normal)
        choice2Button.setTitle(storyBrain.storyArr[index].choice2, for: .normal)
    }
}

