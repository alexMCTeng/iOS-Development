//
//  SettingViewController.swift
//  MingcheTeng-Lab4
//
//  Created by AlexTeng on 11/3/20.
//  Copyright © 2020 AlexTeng. All rights reserved.
//

import UIKit

// Pickerview is learned at assignment 1.
// The link is https://codewithchris.com/uipickerview-example/
class SettingViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate{
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return languageList.count
    }
    
    @IBOutlet weak var saveBtn: UIButton!
    
    /*
     When the Save Changes button is clicked, first to check if the main page view is still loading some data, may be users are scrolling down and an additional query was made to display more movies
     Or users are trying to search movies then suddenly want to change settings.
     In these two cases, there will be 2 functions manipulating the data arrays, which can cause a crash.
     Only when the previous arrays manipulation is done, users can make another query.
     Note: Other functions are still can be used, click tabs, navigation, favorite movie list, or clicked a movie from favorite, these still can be done without locking up the user interface.
     */
    @IBAction func saveBtnHit(_ sender: Any) {
        if settingPass.shareInstance.isLoading == false{
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changeSetting"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changeSettingPushBack"), object: nil)
        }else{
            let ac = UIAlertController(title:"Loading", message: "We are currently finishing your previous request, please try again later", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(ac, animated: true, completion: nil)
        }
    }
    
    @IBOutlet weak var adultSwitch: UISegmentedControl!
    @IBOutlet weak var languagePicker: UIPickerView!
    let languageList = ["English", "中文", " 日本語", "Deutsche Sprache", "Español"]
    let languageSymbolArray = ["en-US", "zh", "ja", "de", "es"]
    var allowAdultContent:Bool = true
    var languageSelected:String = "en-US"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        languagePicker.dataSource = self
        languagePicker.delegate = self
    }
    
    @IBAction func adultSwitchFunction(_ sender: Any) {
        if adultSwitch.selectedSegmentIndex == 0{
            allowAdultContent = true
            settingPass.shareInstance.adultContent = "true"
        } else{
            allowAdultContent = false
            settingPass.shareInstance.adultContent = "false"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return languageList[row]
    }
    
    
    // learn switch case from: https://stackoverflow.com/questions/39151953/picker-views-and-if-statements
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch row{
        case 0:
            languageSelected = languageSymbolArray[0]
        case 1:
            languageSelected = languageSymbolArray[1]
        case 2:
            languageSelected = languageSymbolArray[2]
        case 3:
            languageSelected = languageSymbolArray[3]
        case 4:
            languageSelected = languageSymbolArray[4]
        default:
            languageSelected = languageSymbolArray[0]
        }
        settingPass.shareInstance.language = languageSelected
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
