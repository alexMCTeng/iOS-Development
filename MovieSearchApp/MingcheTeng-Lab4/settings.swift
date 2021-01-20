//
//  settings.swift
//  MingcheTeng-Lab4
//
//  Created by AlexTeng on 11/3/20.
//  Copyright © 2020 AlexTeng. All rights reserved.
//

// Learn how to share value of variables between different view controller from
// https://stackoverflow.com/questions/34642369/swift-using-a-singleton-to-share-variables-not-passing-over
// As there's a setting tab, I'll need to pass the settings to the main page and reload.
import Foundation
class settingPass{
    static var shareInstance = settingPass()
    var language:String = "en-US"
    var adultContent:String = "true"
    var isLoading:Bool = false
}
