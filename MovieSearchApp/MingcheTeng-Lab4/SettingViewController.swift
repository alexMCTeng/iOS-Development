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

    private let saveBtn = UIButton(type: .system)

    /*
     When the Save Changes button is clicked, first to check if the main page view is still loading some data, may be users are scrolling down and an additional query was made to display more movies
     Or users are trying to search movies then suddenly want to change settings.
     In these two cases, there will be 2 functions manipulating the data arrays, which can cause a crash.
     Only when the previous arrays manipulation is done, users can make another query.
     Note: Other functions are still can be used, click tabs, navigation, favorite movie list, or clicked a movie from favorite, these still can be done without locking up the user interface.
     */
    @objc func saveBtnHit(_ sender: Any) {
        if settingPass.shareInstance.isLoading == false{
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changeSetting"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changeSettingPushBack"), object: nil)
        }else{
            let ac = UIAlertController(title:"Loading", message: "We are currently finishing your previous request, please try again later", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(ac, animated: true, completion: nil)
        }
    }

    private let adultSwitch = UISegmentedControl(items: ["On", "Off"])
    private let languagePicker = UIPickerView()
    let languageList = ["English", "中文", " 日本語", "Deutsche Sprache", "Español"]
    let languageSymbolArray = ["en-US", "zh", "ja", "de", "es"]
    var allowAdultContent:Bool = true
    var languageSelected:String = "en-US"

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
        languagePicker.dataSource = self
        languagePicker.delegate = self
        adultSwitch.selectedSegmentIndex = settingPass.shareInstance.adultContent == "true" ? 0 : 1
        let row = languageSymbolArray.firstIndex(of: settingPass.shareInstance.language) ?? 0
        languagePicker.selectRow(row, inComponent: 0, animated: false)
        adultSwitch.addTarget(self, action: #selector(adultSwitchFunction(_:)), for: .valueChanged)
        saveBtn.addTarget(self, action: #selector(saveBtnHit(_:)), for: .touchUpInside)
    }

    @objc func adultSwitchFunction(_ sender: Any) {
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



    private func setupLayout() {
        view.backgroundColor = .systemBackground
        let adultLabel = UILabel()
        adultLabel.text = "Adult Content"
        adultLabel.font = .preferredFont(forTextStyle: .body)
        adultLabel.numberOfLines = 0
        let languageLabel = UILabel()
        languageLabel.text = "Pick a Language"
        languageLabel.font = .preferredFont(forTextStyle: .body)
        languageLabel.numberOfLines = 0
        adultSwitch.accessibilityLabel = "Adult Content"
        languagePicker.accessibilityLabel = "Language"
        saveBtn.setTitle("Save Changes", for: .normal)
        saveBtn.titleLabel?.font = .systemFont(ofSize: 31)
        saveBtn.titleLabel?.adjustsFontSizeToFitWidth = true

        let logo = UIImageView(image: UIImage(named: "tmdbLogo"))
        logo.contentMode = .scaleAspectFit
        logo.isAccessibilityElement = true
        logo.accessibilityLabel = "TMDb"
        let disclosure = UILabel()
        disclosure.text = "This product uses the TMDb API but is not endorsed or certified by TMDb."
        disclosure.font = .preferredFont(forTextStyle: .body)
        disclosure.adjustsFontForContentSizeCategory = true
        disclosure.textAlignment = .center
        disclosure.numberOfLines = 0

        let content = UIStackView(arrangedSubviews: [
            adultLabel, adultSwitch, languageLabel, languagePicker, saveBtn, logo, disclosure
        ])
        content.axis = .vertical
        content.spacing = 20
        let scrollView = UIScrollView()
        view.addSubview(scrollView)
        scrollView.addSubview(content)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        content.translatesAutoresizingMaskIntoConstraints = false
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            content.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20),
            content.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 20),
            content.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -20),
            content.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -20),
            content.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -40),
            languagePicker.heightAnchor.constraint(equalToConstant: 160),
            saveBtn.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),
            logo.heightAnchor.constraint(equalToConstant: 120)
        ])
    }
}
