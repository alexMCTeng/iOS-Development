//
//  quizStruct.swift
//  Quizzler-iOS13
//
//  Created by AlexTeng on 6/4/21.
//  Copyright © 2021 The App Brewery. All rights reserved.
//

import Foundation

struct Question{
    let text: String
    let answer: String
    
    init(q: String, a: String) {
        self.text = q
        self.answer = a
    }
}
