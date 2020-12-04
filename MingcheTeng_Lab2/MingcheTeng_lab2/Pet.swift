//
//  petObject.swift
//  MingcheTeng_lab2
//
//  Created by AlexTeng on 9/22/20.
//  Copyright © 2020 AlexTeng. All rights reserved.
//

import Foundation
import UIKit

/*
 The pet object should contain the happiness and food level, played and fed num, image, colors.
 Using enum to list all pet choices.
 Implement play function and some creative portions.
 */

class Pet{
    
    var petKind:petChoices?
    var happinessLevelNum:Int
    var foodLevelNum:Int
    let petImage: UIImage
    let petLightColor: UIColor
    let petDarkColor:UIColor
    
    // keeping record of the number of time of play and feed.
    var playNum: Int
    var fedNum: Int?
    
    enum petChoices{
        case bird
        case bunny
        case cat
        case dog
        case fish
    }
    
    init(petKind:petChoices, image:UIImage, petLightColor:UIColor, petDarkColor:UIColor, happinessLevelNum:Int, foodLevelNum:Int, playNum:Int, fedNum:Int) {
        self.petKind = petKind
        self.petImage = image
        self.petLightColor = petLightColor
        self.petDarkColor = petDarkColor
        self.happinessLevelNum = happinessLevelNum
        self.foodLevelNum = foodLevelNum
        self.playNum = playNum
        self.fedNum = fedNum
    }
    
    /*
     The play function will handle the happiness and food level
     The rules are as follows,
     In order to play with a pet, you'll need a pet with > 0 foodLevel,
     If foodLevel == 0, that means the pet is hungry and does not play with you unless you feed it first.
     And, to educate the owners be more humane, when the owner want to play with a hungry pet, the happiness level will decrease by 1 because the pet is harrased by the owner.
     */
    func play() {
        if(foodLevelNum <= 0){
            foodLevelNum = 0
            if(happinessLevelNum > 0){
                happinessLevelNum -= 1
            } else{
                happinessLevelNum = 0
            }
        } else{
            if(happinessLevelNum < 10){
                happinessLevelNum += 1
            }else{
                happinessLevelNum = 10
            }
            foodLevelNum -= 1
            playNum += 1
        }
    }
    
    
    /*
     The feed function will handle the feed activity
     The rules are,
     when the user feed the pet, the food level will go up by 1, not exceeding 10,
     if the pet are full but we still try to feed it, it'll get upset by decrementing the happiness level by 1, not less than 0.
     */
    func feed() {
        if(foodLevelNum < 10){
            foodLevelNum += 1
            fedNum! += 1
        } else{
            if(happinessLevelNum > 0){
                happinessLevelNum -= 1
            } else{
                happinessLevelNum = 0
            }
            foodLevelNum = 10
        }
    }
    
}
