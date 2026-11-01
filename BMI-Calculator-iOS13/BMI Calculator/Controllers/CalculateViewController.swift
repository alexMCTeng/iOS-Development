//
//  ViewController.swift
//  BMI Calculator
//
//  Created by Angela Yu on 21/08/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit

class CalculateViewController: UIViewController {

    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var heightSlider: UISlider!
    @IBOutlet weak var weightSlider: UISlider!
    
    var bmiValue : String?
    private var bmiRaw: Float?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        heightSlider.value = 1.5
        weightSlider.value = 100
    }


    @IBAction func heightChanged(_ sender: UISlider) {
        heightLabel.text = String(format: "%.2f", sender.value) + "m"
    }
    @IBAction func weightChanged(_ sender: UISlider) {
        weightLabel.text = String(format: "%.0f",sender.value) + "kg"
    }
    @IBAction func calPressed(_ sender: UIButton) {
        let bmi = weightSlider.value / pow(heightSlider.value, 2)
        self.bmiRaw = bmi
        bmiValue = String(format: "%.1f", bmi)
        self.performSegue(withIdentifier: "gotoResult", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "gotoResult"{
            let destinationVC = segue.destination as! ResultViewController
            destinationVC.bmiValue = bmiValue
            if self.bmiRaw ?? 0 > 30 {
                destinationVC.adviceValue = "Need more exercises."
            } else {
                destinationVC.adviceValue = "Good shape!"
            }
        }
    }
}
