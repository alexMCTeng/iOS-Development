//
//  ViewController.swift
//  MingcheTeng_lab2
//
//  Created by AlexTeng on 9/14/20.
//  Copyright © 2020 AlexTeng. All rights reserved.
//

/*
This section indicates when I get help from a TA and what kind of help he/she did:
    2020/9/24 10am from Xiaowen, help me with enum declaration and init function, sort out the name and type in the Pet.swift and how to declare an Pet object in viewController
    2020/9/22 During studio session 8:30-9:45am, Prof. Todd suggested implement the pet sound can be considered a 5-point creative portion.
    2020/10/10 TA, DK, said the light/dark mode is what the graders expected.
*/

/*
 Learn how to play audio files from:
 https://jayeshkawli.ghost.io/playing-audio-file-on-ios-with-swift/
 
 Resources of Audio files,
 For other sound files, the source is http://soundbible.com/
 */


import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    /*
     Create connections between viewController and storyboard.
     */
    @IBOutlet weak var theImage: UIImageView!
    @IBOutlet weak var theBackground: UIView!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var feedBtn: UIButton!
    @IBOutlet weak var resetBtn: UIButton!
    @IBOutlet weak var happyNum: UILabel!
    @IBOutlet weak var happyBar: DisplayView!
    
    @IBOutlet weak var feedNum: UILabel!
    @IBOutlet weak var feedBar: DisplayView!
    
    @IBOutlet weak var birdBtn: UIButton!
    @IBOutlet weak var bunnyBtn: UIButton!
    @IBOutlet weak var catBtn: UIButton!
    @IBOutlet weak var dogBtn: UIButton!
    @IBOutlet weak var fishBtn: UIButton!
    
    let birdLightColor = UIColor(red:100.0/255.0, green: 190.0/255.0, blue: 49.0/255.0, alpha: 0.5)
    let birdDarkColor = UIColor(red: 0.3, green: 0.4, blue: 0.1, alpha: 0.8)
    let bunnyLightColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.5)
    let bunnyDarkColor = UIColor(red: 150.0/255.0, green: 0, blue: 0, alpha: 1.0)
    let catLightColor = UIColor(red: 0, green: 0, blue: 1, alpha: 0.3)
    let catDarkColor = UIColor(red: 63.0/255.0, green: 0, blue: 153.0/255.0, alpha: 1.0)
    let dogLightColor = UIColor(red: 200.0/255.0, green: 120.0/255.0, blue: 150.0/255.0, alpha: 0.5)
    let dogDarkColor = UIColor(red: 130.0/255.0, green: 40.0/255.0, blue: 70.0/255.0, alpha: 1.0)
    let fishLightColor = UIColor(red: 1, green: 174.0/255.0, blue: 0, alpha: 0.5)
    let fishDarkColor = UIColor(red: 140.0/255.0, green: 95.0/255.0, blue: 0, alpha: 1.0)
    
    var bird:Pet = Pet(petKind:.bird, image:UIImage(named: "bird")!, petLightColor: UIColor(red:100.0/255.0, green: 190.0/255.0, blue: 49.0/255.0, alpha: 0.5), petDarkColor: UIColor(red: 0.3, green: 0.4, blue: 0.1, alpha: 0.8),happinessLevelNum: 0, foodLevelNum: 0, playNum: 0, fedNum: 0)
    var bunny:Pet = Pet(petKind:.bunny, image:UIImage(named: "bunny")!, petLightColor: UIColor(red: 1, green: 0, blue: 0, alpha: 0.5), petDarkColor: UIColor(red: 168.0/255.0, green: 0, blue: 0, alpha: 1.0),happinessLevelNum: 0, foodLevelNum: 0, playNum: 0, fedNum: 0)
    var cat:Pet = Pet(petKind:.cat, image:UIImage(named: "cat")!, petLightColor: UIColor(red: 0, green: 0, blue: 1, alpha: 0.3), petDarkColor:UIColor(red: 63.0/255.0, green: 0, blue: 153.0/255.0, alpha: 1.0), happinessLevelNum: 0, foodLevelNum: 0, playNum: 0, fedNum: 0)
    var dog:Pet = Pet(petKind:.dog, image:UIImage(named: "dog")!, petLightColor: UIColor(red: 200.0/255.0, green: 120.0/255.0, blue: 150.0/255.0, alpha: 0.5), petDarkColor:UIColor(red: 130.0/255.0, green: 40.0/255.0, blue: 70.0/255.0, alpha: 1.0), happinessLevelNum: 0, foodLevelNum: 0, playNum: 0, fedNum: 0)
    var fish:Pet = Pet(petKind:.fish, image:UIImage(named: "fish")!, petLightColor: UIColor(red: 1, green: 174.0/255.0, blue: 0, alpha: 0.5), petDarkColor: UIColor(red: 163.0/255.0, green: 95.0/255.0, blue: 0, alpha: 1.0), happinessLevelNum: 0, foodLevelNum: 0, playNum: 0, fedNum: 0)
    
    var currentPet:Pet!
    var isInLightMode:Bool?
    
    let birdSoundNormal = Bundle.main.path(forResource: "birdSound1", ofType: ".mp3")
    let birdSoundAngry = Bundle.main.path(forResource: "rooster", ofType: ".mp3")
    let bunnySoundNormal = Bundle.main.path(forResource: "rabbitNormalReplace", ofType: ".mp3")
    let bunnySoundAngry = Bundle.main.path(forResource: "rabbitDistressReplace", ofType: ".mp3")
    let catSoundNormal = Bundle.main.path(forResource: "catMeow", ofType: ".mp3")
    let catSoundAngry = Bundle.main.path(forResource: "catCream", ofType: ".mp3")
    let dogSoundNormal = Bundle.main.path(forResource: "dogHowling", ofType: ".mp3")
    let dogSoundAngry = Bundle.main.path(forResource: "dogBarking", ofType: ".mp3")
    let fishSoundNormal = Bundle.main.path(forResource: "fishNormal", ofType: ".mp3")
    let fishSoundAngry = Bundle.main.path(forResource: "fishAngry", ofType: ".mp3")
    
    var playNormalSound:AVAudioPlayer!
    var playAngrySound:AVAudioPlayer!

    override func viewDidLoad() {
        do{
            try playNormalSound = AVAudioPlayer(contentsOf: URL(fileURLWithPath: birdSoundNormal!))
            try playAngrySound = AVAudioPlayer(contentsOf: URL(fileURLWithPath: birdSoundAngry!))
        } catch{
            print(error)
        }
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // The default pet is bird
        if self.traitCollection.userInterfaceStyle == .light{
            isInLightMode = true
        }else{
            isInLightMode = false
        }
        currentPet = bird
        updateInfo(inputPet: currentPet)
    }
    
    /*
     Learn how to check if the userInterfaceStyle is light or dark from ,
     https://www.avanderlee.com/swift/dark-mode-support-ios/
     */
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.userInterfaceStyle == .dark{
            isInLightMode = false
        }else{
            isInLightMode = true
        }
        updateInfo(inputPet: currentPet)
    }
    
    
    @IBAction func birdBtnHit(_ sender: Any) {
        currentPet = bird
        updateInfo(inputPet: currentPet)
        do{
            try playNormalSound = AVAudioPlayer(contentsOf: URL(fileURLWithPath: birdSoundNormal!))
            try playAngrySound = AVAudioPlayer(contentsOf: URL(fileURLWithPath: birdSoundAngry!))
        } catch{
            print(error)
        }
    }
    
    
    @IBAction func bunnyBtnHit(_ sender: Any) {
        currentPet = bunny
        updateInfo(inputPet: currentPet)
        do{
            try playNormalSound = AVAudioPlayer(contentsOf: URL(fileURLWithPath: bunnySoundNormal!))
            try playAngrySound = AVAudioPlayer(contentsOf: URL(fileURLWithPath: bunnySoundAngry!))
        } catch{
            print(error)
        }
    }
    
    @IBAction func catBtnHit(_ sender: Any) {
        currentPet = cat
        updateInfo(inputPet: currentPet)
        do{
            try playNormalSound = AVAudioPlayer(contentsOf: URL(fileURLWithPath: catSoundNormal!))
            try playAngrySound = AVAudioPlayer(contentsOf: URL(fileURLWithPath: catSoundAngry!))
        } catch{
            print(error)
        }
    }
    
    @IBAction func dogBtnHit(_ sender: Any) {
        currentPet = dog
        updateInfo(inputPet: currentPet)
        do{
            try playNormalSound = AVAudioPlayer(contentsOf: URL(fileURLWithPath: dogSoundNormal!))
            try playAngrySound = AVAudioPlayer(contentsOf: URL(fileURLWithPath: dogSoundAngry!))
        } catch{
            print(error)
        }
    }
    
    @IBAction func fishBtnHit(_ sender: Any) {
        currentPet = fish
        updateInfo(inputPet: fish)
        do{
            try playNormalSound = AVAudioPlayer(contentsOf: URL(fileURLWithPath: fishSoundNormal!))
            try playAngrySound = AVAudioPlayer(contentsOf: URL(fileURLWithPath: fishSoundAngry!))
        } catch{
            print(error)
        }
    }
    
    func updateInfo(inputPet:Pet){
        if isInLightMode == true || isInLightMode == nil{
            theImage.image = inputPet.petImage
            theBackground.backgroundColor = inputPet.petLightColor
            happyBar.color = inputPet.petLightColor
            feedBar.color = inputPet.petLightColor
            happyBar.value = CGFloat(Double(inputPet.happinessLevelNum) / 10.0)
            feedBar.value = CGFloat(Double(inputPet.foodLevelNum) / 10.0)
            happyNum.text = "Played: \(currentPet.playNum)"
            feedNum.text = "Fed: \(currentPet.fedNum!)"
        } else{
            theImage.image = inputPet.petImage
            theBackground.backgroundColor = inputPet.petDarkColor
            happyBar.color = inputPet.petDarkColor
            feedBar.color = inputPet.petDarkColor
            happyBar.value = CGFloat(Double(inputPet.happinessLevelNum) / 10.0)
            feedBar.value = CGFloat(Double(inputPet.foodLevelNum) / 10.0)
            happyNum.text = "Played: \(currentPet.playNum)"
            feedNum.text = "Fed: \(currentPet.fedNum!)"
        }
    }
    
    @IBAction func playHit(_ sender: Any) {
        if(currentPet.foodLevelNum == 0){
            playAngrySound?.currentTime = 0
            playAngrySound?.play()
        }
        currentPet.play()
        if(currentPet.happinessLevelNum == 10){
            playNormalSound?.currentTime = 0
            playNormalSound?.play()
        }
        happyNum.text = "Played: \(currentPet.playNum)"
        feedNum.text = "Fed: \(currentPet.fedNum!)"
        happyBar.animateValue(to: CGFloat(currentPet.happinessLevelNum) / 10.0)
        feedBar.animateValue(to: CGFloat(currentPet.foodLevelNum) / 10.0)
    }
    
    @IBAction func feedHit(_ sender: Any) {
        if(currentPet.foodLevelNum >= 10){
            playAngrySound?.currentTime = 0
            playAngrySound?.play()
        } else{
            playNormalSound?.currentTime = 0
            playNormalSound?.play()
        }
        currentPet.feed()
        happyNum.text = "Played: \(currentPet.playNum)"
        feedNum.text = "Fed: \(currentPet.fedNum!)"
        happyBar.animateValue(to: CGFloat(currentPet.happinessLevelNum) / 10.0)
        feedBar.animateValue(to: CGFloat(currentPet.foodLevelNum) / 10.0)
    }
    
    @IBAction func resetHit(_ sender: Any) {
        if(currentPet.petKind == Pet.petChoices.bird){
            bird = Pet(petKind:.bird, image:UIImage(named: "bird")!, petLightColor: currentPet.petLightColor, petDarkColor: currentPet.petDarkColor, happinessLevelNum: 0, foodLevelNum: 0, playNum: 0, fedNum: 0)
            currentPet = bird
        } else if(currentPet.petKind == Pet.petChoices.bunny){
            bunny = Pet(petKind:.bunny, image:UIImage(named: "bunny")!, petLightColor: currentPet.petLightColor, petDarkColor: currentPet.petDarkColor, happinessLevelNum: 0, foodLevelNum: 0, playNum: 0, fedNum: 0)
            currentPet = bunny
        } else if(currentPet.petKind == Pet.petChoices.cat){
            cat = Pet(petKind: .cat, image: UIImage(named: "cat")!, petLightColor: currentPet.petLightColor, petDarkColor: currentPet.petDarkColor, happinessLevelNum: 0, foodLevelNum: 0, playNum: 0, fedNum: 0)
            currentPet = cat
        } else if(currentPet.petKind == Pet.petChoices.dog){
            dog = Pet(petKind:.dog, image:UIImage(named: "dog")!, petLightColor: currentPet.petLightColor, petDarkColor: currentPet.petDarkColor, happinessLevelNum: 0, foodLevelNum: 0, playNum: 0, fedNum: 0)
            currentPet = dog
        } else if(currentPet.petKind == Pet.petChoices.fish){
            fish = Pet(petKind:.fish, image:UIImage(named: "fish")!, petLightColor: currentPet.petLightColor, petDarkColor: currentPet.petDarkColor, happinessLevelNum: 0, foodLevelNum: 0, playNum: 0, fedNum: 0)
            currentPet = fish
        }
        updateInfo(inputPet: currentPet)
    }
}

