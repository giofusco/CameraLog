//
//  SessionConfig.swift
//  CameraLog
//
//  Created by Giovanni Fusco on 2/28/20.
//  Copyright © 2020 Smith-Kettlewell Eye Research Institute. All rights reserved.
//

import UIKit

class SessionConfig: UIViewController{
    
    @IBOutlet weak var sessionName: UITextField!
    @IBOutlet weak var frameRateLbl: UILabel!
    
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var frameRateSlider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        frameRateLbl.text = "\(Int(frameRateSlider.value))"
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @IBAction func textChanged(_ sender: UITextField) {
        if sender.text != ""{
            continueButton.isEnabled = true
        }
        else{
            continueButton.isEnabled = false
        }
    }
    @IBAction func frameRateChanged(_ sender: UISlider) {
        frameRateSlider.value = round(frameRateSlider.value)
        frameRateLbl.text = "\(Int(frameRateSlider.value))"
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "startCaptureSession", sender: self)
    }
    
    // pass parameters to next view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destVC : ViewController = segue.destination as! ViewController
        destVC.frameRate = Int(frameRateSlider.value)
        destVC.sessionID = sessionName.text!
    }
}
