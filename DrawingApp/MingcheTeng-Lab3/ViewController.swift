//
//  ViewController.swift
//  MingcheTeng-Lab3
//
//  Created by AlexTeng on 10/4/20.
//  Copyright © 2020 AlexTeng. All rights reserved.
//

/*
 2020/10/5, attended TA hours, Emma and Ian, on how to reconcile weird white space of the stroke. No one knows what cause it.
 2020/10/10, attend TA hours, DK, on how to reconcile werid white space of the stroke, TA had some ideas but the issue remains.
            My own solution (not perfect), addQuadCurve after the addCurve provided by the lab instruction. It work fine but I'm skeptical whether there's a better solution.
 */

/*
 creative thoughts:
 10/5, allow user adjust transparency, checked on 10/10,
 10/6, allow user save drawings, change brushes, save drawing checked on 10/11, but abandon the change brushes idea.
 10/8, have a color picker palette, completed on 10/12.
 */

/*
 Things to improve after the assignment
 1. all the outlets in the colorSettingViewController should correspond to the current settings (Not set to UIColor.black, opacity = 1 every time open the palette.) Complete already on 10/12
 2. implement different brushes. maybe have more thick line when user press the screen hard.
 3. Improve UI.
 */

// resource of color pen images: https://www.pngwing.com/en/free-png-bamth
// resource of palette image: https://www.iconfinder.com/icons/1296498/paint_paint_brush_palette_icon_painting_palette_icon

import UIKit

class ViewController: UIViewController, UINavigationControllerDelegate, ColorSettingViewControllerDelegate{
    
    /*
     A delegate function that pass data between ViewController and colorSettingViewController
     */
    func colorSettingViewControllerFinished(color: UIColor, opacity: Float) {
//        print("I'm in VC delegate method")
        currentTransparency = opacity
        currentColor = color
    }
    
    /*
     Pass the color and opacity in the viewController to colorSettingViewController.
     Learn get RGB components from: https://www.hackingwithswift.com/example-code/uicolor/how-to-read-the-red-green-blue-and-alpha-color-components-from-a-uicolor
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let colorVC = segue.destination as! colorSettingViewController
        // load the colorCV first
        colorVC.loadView()
        // Get the color RGB components
        var red:CGFloat = 0.0
        var green:CGFloat = 0.0
        var blue:CGFloat = 0.0
        var alpha:CGFloat = 0.0
        currentColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        // End of get the color RGB components
        
        // assign values for diplay purpose
        colorVC.theRedSlider.value = Float(red) * 255.0
        colorVC.theGreenSlider.value = Float(green) * 255.0
        colorVC.theBlueSlider.value = Float(blue) * 255.0
        colorVC.currentOpacity = Float(alpha)
        colorVC.theOpacitySlider.value = Float(alpha)
        colorVC.theImage.backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        
        // assign values for passing purpose
        colorVC.currentColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        colorVC.currentOpacity = Float(alpha)
    }
        
    var currentColor:UIColor = UIColor.red
    var currentTransparency:Float = 1.00
    var currentThickness:Double?
    var currentLine:Line?
    var theCanvas:LineView!
    @IBOutlet weak var theThicknessSlider: UISlider!
    @IBOutlet weak var theDrawingArea: UIView!
    @IBOutlet weak var theClearBtn: UIButton!
    
    /*
     Find the source code from https://www.hackingwithswift.com/example-code/media/uiimagewritetosavedphotosalbum-how-to-write-to-the-ios-photo-album
     And learning piece by piece
     Learned save UIView as UIImage from: https://stackoverflow.com/questions/30696307/how-to-convert-a-uiview-to-an-image
     And here: https://stackoverflow.com/questions/31582222/how-to-take-screenshot-of-a-uiview-in-swift
     Learned how to pop out message from: https://stackoverflow.com/questions/25511945/swift-alert-view-with-ok-and-cancel-which-button-tapped
     */
    @IBAction func saveBtnHit(_ sender: Any) {
        let renderer = UIGraphicsImageRenderer(size: theDrawingArea.bounds.size)
        let storeImage = renderer.image { context in theDrawingArea.drawHierarchy(in: theDrawingArea.bounds, afterScreenUpdates: true)}
        let pngImage = storeImage.pngData()
        // Learned from: https://developer.apple.com/documentation/uikit/1619125-uiimagewritetosavedphotosalbum
        UIImageWriteToSavedPhotosAlbum(UIImage(data:pngImage!)!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    // Learned from: https://developer.apple.com/documentation/uikit/uiimagepickercontrollerdelegate/1619126-imagepickercontroller
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if error != nil {
            let ac = UIAlertController(title: "Save error", message: "Authorization denies access to perform save to Photos", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your drawing has been saved to your Photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    // End of quote and "Save" creative idea.

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        theCanvas = LineView(frame: theDrawingArea.frame)
        theDrawingArea.addSubview(theCanvas)
        currentThickness = Double(theThicknessSlider.value)
        delegateLaunch()
    }
    
    /*
    Learn how to pass data with delegate from: https://stackoverflow.com/questions/25759945/pass-data-when-dismiss-modal-viewcontroller-in-swift
     */
    func delegateLaunch(){
        colorSettingViewController.delegate = self
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touchPoint = touches.first?.location(in: theDrawingArea) else { return }
//        print("Began:   \(touchPoint)")
        currentLine = Line(points: [], color: currentColor, thickness: CGFloat(currentThickness!), transparency: CGFloat(currentTransparency))
        currentLine!.points.append(touchPoint)
        theCanvas.theLine = currentLine
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touchPoint = touches.first?.location(in: theDrawingArea) else { return }
//        print("Moved: \(touchPoint)")
        currentLine!.points.append(touchPoint)
        theCanvas.theLine = currentLine
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touchPoint = touches.first?.location(in: theDrawingArea) else { return }
//        print("End:   \(touchPoint)")
        currentLine!.points.append(touchPoint)
//        currentLine?.transparency = CGFloat(currentTransparency)
        theCanvas.theLine = currentLine
        theCanvas.lines.append(currentLine!)
        currentLine = nil
        theCanvas.theLine = nil
    }

    @IBAction func clearCanvas(_ sender: Any) {
        theCanvas.theLine = nil
        theCanvas.lines = []
        currentLine = nil
    }
    
    @IBAction func undoLastLine(_ sender: Any) {
        if(theCanvas.lines.count > 0){
            theCanvas.lines.removeLast()
        }else{
            print("No more lines")
        }
    }
    
    /*
     A function that handle the chnage of color
     */
    @IBAction func colorChanged(_ sender: UIButton) {
        if sender.tag == 0{
            currentColor = UIColor.red
            currentTransparency = 1.0
        } else if sender.tag == 1{
            currentColor = UIColor.blue
            currentTransparency = 1.0
        } else if sender.tag == 2{
            currentColor = UIColor.green
            currentTransparency = 1.0
        } else if sender.tag == 3{
            currentColor = UIColor.orange
            currentTransparency = 1.0
        } else if sender.tag == 4{
            currentColor = UIColor.brown
            currentTransparency = 1.0
        } else if sender.tag == 5{
            currentColor = UIColor.white
            currentTransparency = 1.0
        }
    }
    
    @IBAction func thicknessChanged(_ sender: Any) {
        currentThickness = Double(theThicknessSlider.value)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

/*
 The code that I tried Section
 */
//extension ViewController: colorSettingViewControllerDelegate{
//    func colorSettingViewControllerFinished(colorSettingViewController: colorSettingViewController) {
//        let redC = colorSettingViewController.theRedSlider.value
//        let greenC = colorSettingViewController.theGreenSlider.value
//        let blueC = colorSettingViewController.theBlueSlider.value
//        print("the red value is \(redC)")
//        self.currentTransparency = Double(colorSettingViewController.theOpacitySlider.value)
//        print("the opacity is \(currentTransparency)")
//    }
//
//}
//    PHPhotoLibrary.requestAuthorization({newStatus in
//        if newStatus == PHAuthorizationStatus.authorized{
//        }})
//}
