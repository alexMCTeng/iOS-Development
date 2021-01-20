//
//  colorPickerController.swift
//  MingcheTeng-Lab3
//
//  Created by AlexTeng on 10/11/20.
//  Copyright © 2020 AlexTeng. All rights reserved.
//

import Foundation
import UIKit

protocol ColorPickerDelegate {
    func colorPickerSelected(selectedColor: UIColor, selectedHex:String)
}

class colorPickerController: UIViewController{
    var colorPickerDelegate: ColorPickerDelegate
    
}
