//
//  colorSettingViewController.swift
//  MingcheTeng-Lab3
//
//  Created by AlexTeng on 10/11/20.
//  Copyright © 2020 AlexTeng. All rights reserved.
//

/*
 This is a viewController of color palette.
 */

import UIKit

protocol ColorSettingViewControllerDelegate: class {
    func colorSettingViewControllerFinished(color:UIColor, opacity: Float)
}

class colorSettingViewController: UIViewController {
        
    static var delegate: ColorSettingViewControllerDelegate?

    @IBOutlet weak var theRedSlider: UISlider!
    @IBOutlet weak var theGreenSlider: UISlider!
    @IBOutlet weak var theBlueSlider: UISlider!
    @IBOutlet weak var theOpacitySlider: UISlider!
    @IBOutlet weak var theImage: UIImageView!
    var currentOpacity:Float?
    var currentColor:UIColor = UIColor.black
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /*
     Once there's a slider changed, update the background color of the image to let user know what color they're setting.
     */
    @IBAction func sliderChanged(_ sender: Any) {
        // For display purpose
        theImage.backgroundColor = UIColor(red: CGFloat(theRedSlider.value)/255.0,
                                           green: CGFloat(theGreenSlider.value)/255.0,
                                           blue: CGFloat(theBlueSlider.value)/255.0,
                                           alpha: CGFloat(theOpacitySlider.value))
        // For purpose of passing data
        currentOpacity = theOpacitySlider.value
        currentColor = UIColor(red: CGFloat(theRedSlider.value)/255.0,
                               green: CGFloat(theGreenSlider.value)/255.0,
                               blue: CGFloat(theBlueSlider.value)/255.0,
                               alpha: CGFloat(theOpacitySlider.value))
    }
    
    /*
     When back button is hit, the func will be called and it'll pass the values(color and opacity) to the ViewController
     */
    override func viewWillDisappear(_ animated: Bool) {
        colorSettingViewController.delegate?.colorSettingViewControllerFinished(color: currentColor, opacity: currentOpacity!)
//        print("I'm in disappear")
    }
    
    /*
     MARK: - Navigation

     In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         Get the new view controller using segue.destination.
         Pass the selected object to the new view controller.
    }
    */

}
