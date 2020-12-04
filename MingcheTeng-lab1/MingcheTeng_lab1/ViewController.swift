//
//  ViewController.swift
//  cse438_lab1
//
//  Created by AlexTeng on 9/2/20.
//  Copyright © 2020 AlexTeng. All rights reserved.
//

/*
This section indicates when I get help from a TA and what kind of help he/she did:
   2020/9/24 10am from Xiaowen, asking about the localization, and confirming that the currency exchange is enough for 10 point in creative portion.
*/

import UIKit
import Foundation

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate{
    
    /*
     Learn how to restrict users' input from:
     http://www.globalnerdy.com/2015/04/27/how-to-program-an-ios-text-field-that-takes-only-numeric-input-or-specific-characters-with-a-maximum-length/
     When users try to change text in the text field, this function will be called.
     True means the changes are allowed.
     */
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // if the user delete the input to an empty string, then, of course, it's allowed, return true
        if(string.count == 0){
            return true
        } else{
            var tempBoolean = true
            let r = Range(range, in: textField.text!)
            let newText = textField.text!.replacingCharacters(in: r!, with: string)
            // In order to allow only number and decimal point, we can use inverted CharacterSet, that is, the original characterSet is [0-9] and .
            // then inverted it, then use string.rangeOfCharacer(from: ) == nil, if the return is true, means the input is not a character but [0-9] or a dot
            // Learn from :
            // https://stackoverflow.com/questions/27215495/limit-uitextfield-input-to-numbers-in-swift
            // print(string)
            
            let anythingButNumberAndDot = NSCharacterSet(charactersIn: "0123456789.").inverted
            let isNewStringValid = string.rangeOfCharacter(from: anythingButNumberAndDot) == nil
            tempBoolean = isNewStringValid
            // the textField is going to know which textField is changed, since our isLessThanTwoDecimalNum doesn't know the new extra string is, we'll need to add it.
            return tempBoolean && isLessThanTwoDecimalNum(inputText: newText)
        }
    }
    /*
     There's a problem with the textField() fucntion above, as we use editing changed to update the final price live, the new string which are going to be tested are not the whole number in the textfield, we can verify that by print out the "string" in that function.
     That means we need another method to verify if the whole input is valid. isLessThanTwoDecimalNum will check if there's only 1 dot, and if the number after decimal dot is less than or equal to 2.
     Learn how to check the number of decimal from:
     https://stackoverflow.com/questions/45443289/how-to-limit-the-textfield-entry-to-2-decimal-places-in-swift-4
     */
    func isLessThanTwoDecimalNum(inputText: String) -> Bool{
        // Seperate the input by ., if there's only 1 dot, then the count should be 2, if there's no dots, then count should be 1.
        let dotNum = inputText.components(separatedBy: ".").count - 1
        //print(dotNum)
        // More than 1 dots, return false, 2 dots is not a decimal
        if(dotNum > 1){
            return false
        } else{
            let decimalNum: Int
            // I used string.index(), but xcode autofix to firstIndex()
            if let dotIndex = inputText.firstIndex(of: "."){
                // calculate the distance from the dot to the end
                // Note: https://developer.apple.com/documentation/swift/string/1539571-endindex
                // From the documentation, endIndex return 1 greater than the last valid subscript argument.
                // Example: 100.51 the dotIndex is 3, and the endIndex is 6, the last valid argument is 1 which is at index 5.
                decimalNum = inputText.distance(from: dotIndex, to: inputText.endIndex) - 1
            } else{
                // number of decimal = 0 if there's no dot.
                decimalNum = 0
            }
            return decimalNum <= 2
        }
    }
    
    /*
     Create connections between viewController and storyboard.
     */
    
    @IBOutlet weak var oPrice: UITextField!
    @IBOutlet weak var discountP: UITextField!
    @IBOutlet weak var taxP: UITextField!
    @IBOutlet weak var finalPrice: UILabel!
    @IBOutlet weak var exchangeRateNote: UILabel!
    @IBOutlet weak var languageSeg: UISegmentedControl!
    @IBOutlet weak var appName: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var discountLabel: UILabel!
    @IBOutlet weak var taxLabel: UILabel!
    @IBOutlet weak var exchangeLabel: UILabel!
    @IBOutlet weak var finalPriceLabel: UILabel!
    @IBOutlet weak var noteLabel: UILabel!
    
    
    /*
     Creative idea: currency exchange with pickerView
     Learned how to use pickerView from: https://codewithchris.com/uipickerview-example/
     Creative Portion Start
     */
    
    @IBOutlet weak var currencyPicker: UIPickerView!
    
    var countryList:[String] = [String]()
    var countryList_us:[String] = ["USD($)", "GBP(£)", "JPY(¥)", "TWD(NT$)"]
    var countryList_tw:[String] = ["美金($)", "英鎊(£)", "日圓(¥)", "新台幣(NT$)"]
    var currencyList: [Double] = [1.00, 0.75, 110.00, 30.00]
    var currencySymbolList:[String] = ["$", "£", "¥", "NT$"]
    var currentCountry:String = "USD($)"
    var currentExchangeRate:Double = 1.00
    var currentCurrencySymbol = "$"
    var noteShow = false
    var currentLanguage = "ENG"
    
    // The function will return how many column in the pickerView, in this case, only 1
    func numberOfComponents(in currencyPicker: UIPickerView) -> Int{
        return 1
    }
    
    // The fucntion will return how many rows(number of data) in the pickerView, in the case, the answer is equal to the length from one of three list
    func pickerView(_ taxPicker: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countryList_us.count
    }
    
    // In this function, we return the country list corresponded to the language the user selected.
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(languageSeg.selectedSegmentIndex == 0){
            countryList = countryList_us
            return countryList_us[row]
        } else {
            countryList = countryList_tw
            return countryList_tw[row]
        }
    }
    
    // Once the user did select a row, call displayUpdate() to udpate the final price live.
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // inComponent 0 is the row that user selects
        let selected:Int = currencyPicker.selectedRow(inComponent: 0)
        currentCountry = countryList[selected]
        currentExchangeRate = currencyList[selected]
        currentCurrencySymbol = currencySymbolList[selected]
        
        /*
         If the user is selecting a currency that isn't US Dollar, set the noteShow to true.
         Given the language selected by the user, display texts accordingly.
         */
        if(selected != 0){
            noteShow = true
            if(currentLanguage == "ENG"){
                noteLabel.text = "Note: Exchange Rate"
            } else if(currentLanguage == "zh_TW"){
                noteLabel.text = "註：貨幣匯率"
            }
            exchangeRateNote.text = "\(countryList[0]) : \(currentCountry) = 1 : \(String(format: "%.2f", currentExchangeRate))"
            noteLabel.textAlignment = .center
            exchangeRateNote.textAlignment = .center
        } else{
            noteShow = false
            noteLabel.text = ""
            exchangeRateNote.text = ""
        }
        displayPrice()
    }
    // Creative Portion End
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // Load the dismissKeyboard function after loading the view.
        dismissKeyboard()
        self.oPrice.delegate = self
        self.discountP.delegate = self
        self.taxP.delegate = self
        self.currencyPicker.delegate = self
        self.currencyPicker.dataSource = self
    }
    
    // Switch the language between English and traditional Chinese
    @IBAction func switchLanguage(_ sender: Any) {
        if(languageSeg.selectedSegmentIndex == 0){
            appName.text = "My Shopping Calculator"
            priceLabel.text = "Product Price($)"
            discountLabel.text = "Discount %"
            taxLabel.text = "Sales Tax %"
            exchangeLabel.text = "Currency"
            finalPriceLabel.text = "Final Price"
            
            // Get the index of country in the original countryList and use that to update currenty country with different language
            let tempIndex = countryList.firstIndex(of: currentCountry)
            countryList = countryList_us
            currentCountry = countryList[tempIndex!]
            currentLanguage = "ENG"
            
            if(noteShow == true){
                // only need to show the currency exchange rate when the user choose other than US dollar
                if(currentCountry != countryList[0]){
                    noteLabel.text = "Note: Exchange Rate"
                    exchangeRateNote.text = "\(countryList[0]) : \(currentCountry) = 1 : \(String(format: "%.2f", currentExchangeRate))"
                    noteLabel.textAlignment = .center
                    exchangeRateNote.textAlignment = .center
                }
            } else{
                noteLabel.text = ""
                exchangeRateNote.text = ""
            }
            currencyPicker.reloadAllComponents()
        } else if(languageSeg.selectedSegmentIndex == 1){
            appName.text = "商品價格計算器"
            priceLabel.text = "商品價格(美金)"
            discountLabel.text = "折扣 %"
            taxLabel.text = "稅 %"
            exchangeLabel.text = "貨幣選擇"
            finalPriceLabel.text = "最終價格"
            
            let tempIndex = countryList.firstIndex(of: currentCountry)
            countryList = countryList_tw
            currentCountry = countryList[tempIndex!]
            currentLanguage = "zh_TW"
            
            if(noteShow == true){
                if(currentCountry != countryList[0] ){
                    noteLabel.text = "註：貨幣匯率"
                    exchangeRateNote.text = "\(countryList[0]) : \(currentCountry) = 1 : \(String(format: "%.2f", currentExchangeRate))"
                    noteLabel.textAlignment = .center
                    exchangeRateNote.textAlignment = .center
                }
            } else{
                noteLabel.text = ""
                exchangeRateNote.text = ""
            }
            currencyPicker.reloadAllComponents()
            
            // For traditional Chinese, realign the texts to the center.
            appName.textAlignment = .center
            priceLabel.textAlignment = .center
            discountLabel.textAlignment = .center
            taxLabel.textAlignment = .center
            exchangeLabel.textAlignment = .center
            finalPriceLabel.textAlignment = .center

        }
        displayPrice()
    }
    
    /*
     In order to dismiss the keyboard once the user's done editing.
     We'll need a function to do that.
     Learned from:
     https://stackoverflow.com/questions/24126678/close-ios-keyboard-by-touching-anywhere-using-swift?page=1&tab=votes#tab-top
    */
    func dismissKeyboard(){
        // create a GestureRecognizer variable with target(itself) and action
        // add the variable to the gestureRecognizer
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(tempDismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func tempDismissKeyboard(){
        view.endEditing(true)
    }
    
    /*
     Once there's an input from the user,
     no matter it's a product price, discount, or tax
     call the displayUpdate
     To perform a live update given user's input, the sent event is editing change
     */
    @IBAction func receiveOPrice(_ sender: Any) {
        displayPrice()
    }
    
    @IBAction func receiveDiscount(_ sender: Any) {
        displayPrice()
    }
    
    @IBAction func receiveTax(_ sender: Any) {
        displayPrice()
    }
        
    /*
     This function will calculate final price.
     Considering the inputs, original price, discount, tax, and currency the user are selecting
     */
    func displayPrice(){
        
        var oPriceStore:Double = 0.0
        var discountStore:Double = 0.0
        var taxStore:Double = 0.0
        
        // using if let to see if we can unwrap the user inputs.
        if let tempOriginal = Double(oPrice.text!){
            oPriceStore = Double(tempOriginal)
        }
        if let tempDiscount = Double(discountP.text!){
            discountStore = Double(tempDiscount)
        }
        if let tempTax = Double(taxP.text!){
            taxStore = Double(tempTax)
        }
        
        //finalPrice.text = "$" + String(oPriceStore * (1 - discountStore * 0.01) * (1 + taxStore * 0.01))
        
        if(oPriceStore > 1000000.00){
            finalPrice.text = "Exorbitant. Do not buy it"
            finalPrice.textAlignment = .center
            return
        }
        
        let p = oPriceStore * (1 - discountStore/100.0) * (1 + taxStore/100.0) * currentExchangeRate
        
        if(oPriceStore > 0 && discountStore <= 100 && discountStore >= 0 && taxStore >= 0 && p >= 0){
            // quoted from lab1 pdf, round the final price
            finalPrice.text = "\(currentCurrencySymbol)\(String(format: "%.2f", p))"
        } else{
            if(languageSeg.selectedSegmentIndex == 0){
                finalPrice.text = "Enter valid inputs"
            } else{
                finalPrice.text = "輸入有效數值"
            }
        }
    
    }
    

    
    
    
//         Abandoned creative idea: pickerView states sales tax
//         Abandoned reason: tax rate are composed of federal, state, and city
//         Even if users can user pickerView select state tax, it seems to me that finding a city tax solely will be much more exhausting
//         than enter the total tax, which they can find on other receipts or simply asking the staffs.
    
//         the state tax record is from: https://taxfoundation.org/2020-sales-taxes/
//         let stateTaxList:[String: Double] = ["Alabama":4.00, "Alaska": 0.00, "Arizona": 5.60, "Arkansas":6.50,
//                            "California":7.25, "Colorodo": 2.9, "Connecticut": 6.35,
//                            "D.C.": 6.00, "Delaware": 0.00,
//                            "Florida": 6.00,
//                            "Georgia":4.00,
//                            "Hawaii": 4.00,
//                            "Idaho":6.00, "Illinois": 6.25, "Indiana": 7.00, "Iowa": 6.00,
//                            "Kansas":6.50, "Kentucky": 6.00,
//                            "Louisiana":4.45,
//                            "Maine": 5.50, "Massachusetts": 6.25, "Maryland": 6.00, "Michigan": 6.00, "Minnesota": 6.875, "Mississippi": 7.00, "Missouri": 4.225, "Montana": 0.00,
//                            "North Carolina": 4.75, "North Dakota": 5.00, "New Hampshire": 0.00, "New Jersey": 6.625, "New Mexico": 5.125, "New York": 4.00, "Nebraska": 5.50, "Nevada": 6.85,
//                            "Ohio": 5.75, "Oklahoma": 4.50, "Oregon": 0.00, "Pennsylvania": 6.00, "Rhode Island": 7.00, "South Carolina": 6.00, "South Dakota": 4.50,
//                            "Tennessee": 7.00, "Texas": 6.25,
//                            "Utah": 6.10,
//                            "Virginia":5.30, "Vermont": 6.00,
//                            "West Virginia": 6.00, "Washington": 6.50, "Wisconsin": 5.00, "Wyoming": 4.00]
//
//        let stateList:[String] = ["Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado", "Connecticut", "D.C.", "Delaware", "Florida", "Gerogia", "Hawaii",
//                                  "Idaho", "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky", "Louisiana", "Maine", "Massachusetts","Maryland", "Michigan", "Minnesota", "MIssissippi",
//                                  "Missouri", "Montana", "North Carolina", "North Dakota", "New Hampshire", "New Jersey", "New Mexico", "New York", "Nerbraska", "Nevada", "Ohio", "Oklahoma",
//                                  "Oregon", "Pennsylvania", "Rhode Island", "South Carolina", "South Dakota", "Tennessee", "Texas", "Utah", "Virginia", "Vermont", "West Virginia",
//                                  "Washington", "Wisconsin", "Wyoming"]
//
//        let currentState:String = "Missouri"
//        let currentSalesTax:Double = 4.225
//
//        first attemp of understanding how function works
//        @IBAction func receivedOPrice(_ sender: Any) {
//            var original:Double = 0.0
//            var disc:Double = 0.0
//            var tax: Double = 0.0
//
//            original = Double(oPrice.text!)!
//            finalPrice.text = "$" + String(original * (1-disc) * (1 + tax))
//        }

}

