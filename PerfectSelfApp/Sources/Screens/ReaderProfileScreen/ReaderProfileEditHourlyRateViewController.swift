//
//  ReaderProfileEditHourlyRateViewController.swift
//  PerfectSelf
//
//  Created by user232392 on 3/31/23.
//  Copyright © 2023 Stas Seldin. All rights reserved.
//

import UIKit

class ReaderProfileEditHourlyRateViewController: UIViewController {
    var min15rate: Float = 0
    var min30rate: Float = 0
    var hourlyrate: Float = 0
    var uid = ""
    @IBOutlet weak var text_rate: UITextField!
    @IBOutlet weak var rate15Min: UITextField!
    @IBOutlet weak var rate30Min: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        rate15Min.text = String(min15rate)
        rate30Min.text = String(min30rate)
        text_rate.text = String(hourlyrate)
    }


    @IBAction func SaveChange(_ sender: UIButton) {
        var inputCheck: String = ""
        var focusTextField: UITextField? = nil
        if(rate15Min.text!.isEmpty){
            inputCheck += "- Please input 15min rate.\n"
            if(focusTextField == nil){
                focusTextField = rate15Min
            }
        }
        
        if(rate30Min.text!.isEmpty){
            inputCheck += "- Please input 30min rate.\n"
            if(focusTextField == nil){
                focusTextField = rate30Min
            }
        }
        
        if(text_rate.text!.isEmpty){
            inputCheck += "- Please input hourly rate.\n"
            if(focusTextField == nil){
                focusTextField = text_rate
            }
        }
        
        if(!inputCheck.isEmpty){
            showAlert(viewController: self, title: "Confirm", message: inputCheck) { UIAlertAction in
                focusTextField!.becomeFirstResponder()
            }
            return
        }
        
        let rate15 = Float(rate15Min.text!)
        let rate30 = Float(rate30Min.text!)
        let rateHr = Float(text_rate.text!)
        // call API for about update
        showIndicator(sender: nil, viewController: self)
        webAPI.editReaderProfile(uid: uid, title: "", min15Price: ((rate15 == nil ? 0.0 : rate15)!),
                                 min30Price: ((rate30 == nil ? 0.0 : rate30)!),
                                 hourlyPrice: ((rateHr == nil ? 0.0 : rateHr)!), about: "", introBucketName: "", introVideokey: "", skills: nil, auditionType: -1, isExplicitRead: nil) { data, response, error in
            
            guard let _ = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                DispatchQueue.main.async {
                    hideIndicator(sender: nil);
                    Toast.show(message: "Something went wrong. please try again later", controller: self)
                }
                return
            }
            DispatchQueue.main.async {
                let transition = CATransition()
                transition.duration = 0.5 // Set animation duration
                transition.type = CATransitionType.push // Set transition type to push
                transition.subtype = CATransitionSubtype.fromLeft // Set transition subtype to from right
                self.view.window?.layer.add(transition, forKey: kCATransition) // Add transition to window layer
                self.dismiss(animated: false)
            }
        }
    }
    @IBAction func GoBack(_ sender: UIButton) {
        let transition = CATransition()
        transition.duration = 0.5 // Set animation duration
        transition.type = CATransitionType.push // Set transition type to push
        transition.subtype = CATransitionSubtype.fromLeft // Set transition subtype to from right
        self.view.window?.layer.add(transition, forKey: kCATransition) // Add transition to window layer
        self.dismiss(animated: true)
    }
    /*
    
     // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
