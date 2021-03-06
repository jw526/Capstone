//
//  ViewController.swift
//  PrototypeApp
//
//  Created by New User on 10/14/18.
//  Copyright © 2018 New User. All rights reserved.
//


import UIKit

//code to identify color of pixels in RGB
extension UIImage {
    public func getPixelColor(pos: CGPoint) -> UIColor {
        
        let pixelData = self.cgImage!.dataProvider!.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        let pixelInfo: Int = ((Int(self.size.width) * Int(pos.y)) + Int(pos.x)) * 4
        
        let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
        let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
        let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
        let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
        }
}
// get RGB value from UIColor
extension UIColor {
    var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return (red, green, blue, alpha)
    }
}



class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate{
    
    
    
// This is the label that displays the number when calculate is hit
    @IBOutlet weak var piCalc: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //faceDetect1()
        
        // this code is for the filter (not yet integrated)
//        if let image = UIImage(named: "pupil.jpg"){
//           let originalImage = CIImage(image: image)
//           let filter = CIFilter(name: "CISharpenLuminance")
//           filter?.setDefaults()
  //         filter?.setValue(originalImage, forKey: kCIInputImageKey)
 //          if let outputImage = filter?.outputImage{
 //               let newImage = UIImage(ciImage: outputImage)
//                pupil.image = newImage
        
            }


//Displays the image
    @IBOutlet weak var pupil: UIImageView!
    
    @IBOutlet weak var testLabel: UILabel!
    
    // code to access camera: take picture button
    @IBAction func camera(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera;
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    // code to access photo library: upload photo button
    @IBAction func library(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary;
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }

// code to display selected image and crop
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.editedImage] as! UIImage
        pupil.image = image
        dismiss(animated:true, completion: nil)
    }
    

//defines the area of the circle. The loop checks whether or not the points are within this

    
    //defines the colors that are "black" and part of the pupil. Not all pixels in the pupil will be exactly black, rather, a varying range of dark shades that appear black.
// calculate pi button. Checks "x" number of pixels. "Black" points inside the circle are added to i, others are added to o. Divides to get ratio and displays this ratio.
    
    @IBAction func calculate(_ sender: Any) {
        var i = 0
        var o = 0
        var x = 0
        
        let image = pupil.image
        let Xmin = Int(pupil.frame.minX)
        let Ymin = Int(pupil.frame.minY)
        let Xmax = Int(pupil.frame.maxX)
        let Ymax = Int(pupil.frame.maxY)
        let radius = Int(pupil.frame.size.width)/2
        let xCenter = Int(Xmin + radius)
        let yCenter = Int(Ymin + radius)
        print(Xmin, Ymin, Xmax, Ymax)
        let circle1 = UIBezierPath(arcCenter: CGPoint(x: xCenter, y: yCenter), radius: CGFloat(radius), startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2), clockwise: true)
        //find the color of the center point
        let centerPoint = CGPoint(x:xCenter,y:yCenter)
        let centerColor = image?.getPixelColor(pos: centerPoint)
        if centerColor == nil {piCalc.text = "please select an image"}
        else{
            var centerR: CGFloat = centerColor!.rgba.red
            var centerG: CGFloat = centerColor!.rgba.green
            var centerB: CGFloat = centerColor!.rgba.blue
            
            while x < 3000{
                
                let point = CGPoint(x:Int.random(in:Xmin...Xmax),y:Int.random(in: Ymin...Ymax))
                let color = image?.getPixelColor(pos: point)
                var red: CGFloat = 0
                var green: CGFloat = 0
                var blue: CGFloat = 0
                //var alpha: CGFloat = 0
                //defines the colors that are "black" and part of the pupil. Not all pixels in the pupil will be exactly black, rather, a varying range of dark shades that appear black.

                red = color!.rgba.red
                green = color!.rgba.green
                blue = color!.rgba.blue
                //edge case when center is black
                if circle1.contains(point) && (centerR + centerG + centerB <= 0.02) {
                    centerR = 0.05
                    centerG = 0.05
                    centerB = 0.05
                }
                
                //adjust the values for contrast: right now 0.2 deviation from the color of the center pt
                //gray scale transformation: New grayscale image = ( (0.3 * R) + (0.59 * G) + (0.11 * B) ).
                
                if circle1.contains(point) && (red + green + blue <= 1.2 * (centerR + centerG + centerB))
                {
                    //print(color)
                    //print(point)
                    
                    i += 1}
                else{
                    o += 1}
                
                x += 1}
            let ratio = 4 * Float(i)/Float(x)
            
    //            print(color)
    //            print(point)
                piCalc.text = String(ratio)
        }
        
    }
    
    func faceDetect1(){
        if let inputImage = UIImage(named: "test1.jpg") {
            let ciImage = CIImage(cgImage: inputImage.cgImage!)
            
            let options = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
            let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: options)!
            
            let faces = faceDetector.features(in: ciImage)
            
            if let face = faces.first as? CIFaceFeature {
                print("Found face at \(face.bounds)")
                
                if face.hasLeftEyePosition {
                    print("Found left eye at \(face.leftEyePosition)")
                }
                
                if face.hasRightEyePosition {
                    print("Found right eye at \(face.rightEyePosition)")
                }
                
                if face.hasMouthPosition {
                    print("Found mouth at \(face.mouthPosition)")
                }
            }
        }
    }


    
    // face detection using CI Image library
    func faceDetect() {
        //get the image from image view
        let faceImage = CIImage(image: pupil.image!)!//unwrap imageview
        
        //set up detector
        let accuracy = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        let faceDetetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: accuracy)
        let faces = faceDetetector?.features(in: faceImage)
        
        if !(faces!.isEmpty) { //if faces is not empty, has features
            for face in faces as! [CIFaceFeature] {
                var hasEyeVisible = "An eye is visible"
                    
                if (!face.hasLeftEyePosition) || (!face.hasRightEyePosition) //no eyes
                {
                    hasEyeVisible = "No eyes found in photo"
                }
                
                testLabel.text = hasEyeVisible
            }
            
            
        }
        
    }
    
    
}







