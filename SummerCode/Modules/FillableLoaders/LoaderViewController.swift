//
//  LoaderViewController.swift
//  SummerCode
//
//  Created by daniel.martinez on 6/8/15.
//  Copyright (c) 2015 com.igz. All rights reserved.
//

import UIKit

import FillableLoaders

// Time:
let LoaderTime: Int = 20

class LoaderViewController: UIViewController {

    @IBOutlet weak var actionBarButton: UIBarButtonItem!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!
    
    var loader: FillableLoader?
    
    var closeButton: UIButton = UIButton()
    
    var counter = NSTimer()
    var count = 0
    
    override func viewDidLoad() {
        setupViews()
    }
    
    func setupViews() {
        textLabel.text = "Press 'Start' button to show a Fillable Loader for \(LoaderTime) seconds"
    }
    
    func showCloseButton() {
        var margin: CGFloat = 30
        closeButton.frame = CGRectMake(0, 0, 150, 35)
        closeButton.center = CGPoint(x: view.frame.width/2, y: view.frame.height - 2*margin - 35)
        closeButton.backgroundColor = UIColor.whiteColor()
        closeButton.layer.cornerRadius = 5.0
        closeButton.setTitle("Stop Loader", forState: .Normal)
        closeButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        closeButton.titleLabel?.font = UIFont.systemFontOfSize(14)
        closeButton.addTarget(self, action: "doAction:", forControlEvents: .TouchUpInside)
        let window = UIApplication.sharedApplication().delegate?.window!
        window!.addSubview(closeButton)
    }
    
    func hideCloseButton() {
        closeButton.removeFromSuperview()
    }
    
    @IBAction func doAction(sender: AnyObject) {
        if (loader != nil) {
            stopLoader()
        } else {
            startLoader()
        }
    }
    
    func startLoader() {
        
        //loader = WavesLoader.createLoaderWithPath( path: buildBezierPath() )
        loader = WavesLoader.createProgressBasedLoaderWithPath( path: buildBezierPath() )
        loader!.loaderColor = UIColor.orangeColor()
        loader!.loaderStrokeWidth = 0
        loader!.showLoader()
        
        // Set count
        count = LoaderTime
        countLabel.text = String(count)
        countLabel.hidden = false
        
        // Init counter
        counter = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("updateCounter"), userInfo: nil, repeats: true)
        
        showCloseButton()
        
    }
    
    func stopLoader() {
        
        loader!.removeLoader(animated: true)
        loader = nil
        
        counter.invalidate()
        
        hideCloseButton()
        
    }
    
    func updateCounter() {
        if (count > 0) {
            count = count - 1
        }
        countLabel.text = String(count)
        if (count == 0) {
            counter.invalidate()
            loader?.removeLoader()
            countLabel.hidden = true
        }
    }
    
    func updateBarButton(title: String) {
        actionBarButton.title = title
    }
    
    func buildBezierPath() -> CGPath {
        
        //// PaintCode Trial Version
        //// www.paintcodeapp.com
        
        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.moveToPoint(CGPointMake(209.52, 320.32))
        bezierPath.addCurveToPoint(CGPointMake(209.55, 321.55), controlPoint1: CGPointMake(209.54, 320.73), controlPoint2: CGPointMake(209.55, 321.14))
        bezierPath.addCurveToPoint(CGPointMake(182.65, 348.44), controlPoint1: CGPointMake(209.55, 334.04), controlPoint2: CGPointMake(200.04, 348.44))
        bezierPath.addCurveToPoint(CGPointMake(168.16, 344.2), controlPoint1: CGPointMake(177.31, 348.44), controlPoint2: CGPointMake(172.34, 346.88))
        bezierPath.addCurveToPoint(CGPointMake(170.41, 344.33), controlPoint1: CGPointMake(168.9, 344.28), controlPoint2: CGPointMake(169.65, 344.33))
        bezierPath.addCurveToPoint(CGPointMake(182.16, 340.28), controlPoint1: CGPointMake(174.84, 344.33), controlPoint2: CGPointMake(178.92, 342.82))
        bezierPath.addCurveToPoint(CGPointMake(173.32, 333.72), controlPoint1: CGPointMake(178.02, 340.21), controlPoint2: CGPointMake(174.53, 337.47))
        bezierPath.addCurveToPoint(CGPointMake(175.1, 333.89), controlPoint1: CGPointMake(173.9, 333.83), controlPoint2: CGPointMake(174.49, 333.89))
        bezierPath.addCurveToPoint(CGPointMake(177.59, 333.56), controlPoint1: CGPointMake(175.96, 333.89), controlPoint2: CGPointMake(176.8, 333.77))
        bezierPath.addCurveToPoint(CGPointMake(170.01, 324.28), controlPoint1: CGPointMake(173.27, 332.69), controlPoint2: CGPointMake(170.01, 328.87))
        bezierPath.addCurveToPoint(CGPointMake(170.01, 324.17), controlPoint1: CGPointMake(170.01, 324.24), controlPoint2: CGPointMake(170.01, 324.2))
        bezierPath.addCurveToPoint(CGPointMake(174.29, 325.35), controlPoint1: CGPointMake(171.28, 324.87), controlPoint2: CGPointMake(172.74, 325.3))
        bezierPath.addCurveToPoint(CGPointMake(170.09, 317.48), controlPoint1: CGPointMake(171.75, 323.65), controlPoint2: CGPointMake(170.09, 320.76))
        bezierPath.addCurveToPoint(CGPointMake(171.37, 312.73), controlPoint1: CGPointMake(170.09, 315.75), controlPoint2: CGPointMake(170.55, 314.12))
        bezierPath.addCurveToPoint(CGPointMake(190.85, 322.61), controlPoint1: CGPointMake(176.03, 318.45), controlPoint2: CGPointMake(183, 322.21))
        bezierPath.addCurveToPoint(CGPointMake(190.61, 320.45), controlPoint1: CGPointMake(190.69, 321.91), controlPoint2: CGPointMake(190.61, 321.19))
        bezierPath.addCurveToPoint(CGPointMake(200.06, 311), controlPoint1: CGPointMake(190.61, 315.23), controlPoint2: CGPointMake(194.84, 311))
        bezierPath.addCurveToPoint(CGPointMake(206.96, 313.98), controlPoint1: CGPointMake(202.78, 311), controlPoint2: CGPointMake(205.24, 312.14))
        bezierPath.addCurveToPoint(CGPointMake(212.97, 311.69), controlPoint1: CGPointMake(209.12, 313.56), controlPoint2: CGPointMake(211.14, 312.77))
        bezierPath.addCurveToPoint(CGPointMake(208.81, 316.92), controlPoint1: CGPointMake(212.26, 313.89), controlPoint2: CGPointMake(210.76, 315.75))
        bezierPath.addCurveToPoint(CGPointMake(214.24, 315.43), controlPoint1: CGPointMake(210.72, 316.69), controlPoint2: CGPointMake(212.54, 316.18))
        bezierPath.addCurveToPoint(CGPointMake(209.52, 320.32), controlPoint1: CGPointMake(212.97, 317.32), controlPoint2: CGPointMake(211.37, 318.99))
        bezierPath.closePath()
        bezierPath.miterLimit = 4;
        
        return bezierPath.CGPath
        
    }
    
}