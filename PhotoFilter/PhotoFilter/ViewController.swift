//
//  ViewController.swift
//  PhotoFilter
//
//  Created by Cunqi.X on 10/12/14.
//  Copyright (c) 2014 cunqi xiao. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var imageView: UIImageView!
    
    //craete a place to render the filter image
    let context = CIContext(options: nil)
    
    @IBAction func applyFilter(sender: AnyObject) {
        //create an image to filter
        let inputImage = CIImage(image: imageView.image)
        
        //create a random color to pass to a filter
        let randomColor = [kCIInputAngleKey: (Double(arc4random_uniform(314)) / 100)]
        
        //apply a filter to the image
        let filteredImage = inputImage.imageByApplyingFilter("CIHueAdjust", withInputParameters: randomColor)
        
        //Render the filtered image
        let renderedImage = context.createCGImage(filteredImage, fromRect: filteredImage.extent())
        
        imageView.image = UIImage(CGImage: renderedImage)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

