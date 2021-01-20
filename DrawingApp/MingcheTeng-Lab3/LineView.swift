//
//  LineView.swift
//  MingcheTeng-Lab3
//
//  Created by AlexTeng on 10/4/20.
//  Copyright © 2020 AlexTeng. All rights reserved.
//

// Learned the differences between path.fill and path.stroke from:
// https://stackoverflow.com/questions/4125152/difference-between-stroke-and-fill
import UIKit

class LineView: UIView {
    
    /*
     Follow lecture videos instructions.
     */
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var theLine: Line?{
        didSet{
            setNeedsDisplay()
        }
    }
    
    var lines:[Line] = []{
        didSet{
            setNeedsDisplay()
        }
    }
    // end of following lecture videos instructions.
    
    func drawLine(_ line:Line){
    
        let transparency = line.transparency
        let thickness = line.thickness
//        print("print the touches \(line.points)")
        // draw a dot when user tap the screen.qq
        if line.points.count <= 2{
            let startDot = UIBezierPath()
            startDot.addArc(withCenter: line.points[0], radius: thickness/2.0, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
            line.color.setFill()
            startDot.lineJoinStyle = .round
            startDot.lineCapStyle = .round
            startDot.fill(with: .normal, alpha: transparency)
            let endDot = UIBezierPath()
            endDot.addArc(withCenter: line.points[line.points.count-1], radius: thickness / 2, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        }
        let path = createQuadPath(points: line.points)
        path.lineWidth = thickness
        line.color.setStroke()
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        path.stroke(with: .normal, alpha: transparency)
    }
    
    /*
     Provided by the lab 3 instructions
     */
    private func midpoint(first: CGPoint, second: CGPoint) -> CGPoint {
        // implement this function here
        var ans = CGPoint.zero
        ans.x = CGFloat((first.x + second.x)/2.0)
        ans.y = CGFloat((first.y + second.y)/2.0)
        return ans
    }
    
    private func createQuadPath(points: [CGPoint]) -> UIBezierPath {
        let path = UIBezierPath() //Create the path object
        if(points.count < 2){ //There are no points to add to this path
            return path
        }
        path.move(to: points[0]) //Start the path on the first point
        for i in 1..<points.count - 1{
            let firstMidpoint = midpoint(first: path.currentPoint, second: points[i]) //Get midpoint between the path's last point and the next one in the array
            let secondMidpoint = midpoint(first: points[i], second:points[i+1]) //Get midpoint between the next point in the array and the one after it
            path.addCurve(to: secondMidpoint, controlPoint1: firstMidpoint, controlPoint2: points[i]) //This creates a cubic Bezier curve using math!
            // add an additional quadcurve to let the curve more smooth.
            path.addQuadCurve(to: secondMidpoint, controlPoint: points[i])
        }
        return path
    }
    
    // End of lab 3 instructions
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    // The following code comes from lecture videos.
    override func draw(_ rect: CGRect) {
        // Drawing code
        for line in lines{
            drawLine(line)
        }
        if theLine != nil{
            drawLine(theLine!)
        }
    }

}
