//
//  VerifCodeViewController.swift
//  PerfectSelf
//
//  Created by user237181 on 6/2/23.
//  Copyright © 2023 Stas Seldin. All rights reserved.
//

import UIKit

class VerifCodeViewController: UIViewController {

    var email = ""
    
    var timer: Timer?
    var counter = 30
    
    @IBOutlet weak var text_code: UITextField!
    @IBOutlet weak var btn_submit: UIButton!
    @IBOutlet weak var btn_resend: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func VerifyCode(_ sender: UIButton) {
        var inputCheck: String = ""
        var focusTextField: UITextField? = nil
        
        if(text_code.text!.isEmpty){
            inputCheck += "- Please input your verification code.\n"
            if(focusTextField == nil){
                focusTextField = text_code
            }
        }
        
        if(!inputCheck.isEmpty){
            showAlert(viewController: self, title: "Confirm", message: inputCheck) { UIAlertAction in
                focusTextField!.becomeFirstResponder()
            }
            return
        }
        self.btn_submit.loadingIndicator(true)
        self.btn_submit.setTitle("", for: .normal)
        self.btn_submit.isEnabled = false
        
        webAPI.verifyCode(email: self.email, code: text_code.text!) { data, response, error in
            DispatchQueue.main.async {
                self.btn_submit.loadingIndicator(false)
                self.btn_submit.setTitle("Submit", for: .normal)
                self.btn_submit.isEnabled = true
            }
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    Toast.show(message: "Verification failed. Try again later", controller: self)
                }
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            
            if let responseJSON = responseJSON as? [String: Any] {
                guard let result = responseJSON["result"] else {
                    DispatchQueue.main.async {
                        Toast.show(message: "Verification failed. Try again later", controller: self)
                    }
                    return
                }
                
                if let result = result as? [String: Any] {
                    let err = result["error"] as! String
                    let isVerified = result["verify"] as! Bool
                    
                    if (err.isEmpty && isVerified) {
                        DispatchQueue.main.async {
                            let controller = ResetPasswordViewController()
                            controller.email = self.email
                            controller.code = self.text_code.text!
                            controller.modalPresentationStyle = .fullScreen
                            self.present(controller, animated: false)
                        }
                    }
                    else {
                        DispatchQueue.main.async {
                            Toast.show(message: err, controller: self)
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func ResendVerifCode(_ sender: UIButton) {

        self.btn_resend.loadingIndicator(true)
        self.btn_resend.setTitle("", for: .normal)
        
        webAPI.sendVerifyCodeToEmail(email: self.email) { data, response, error in
            DispatchQueue.main.async {
                self.btn_resend.loadingIndicator(false)
                self.btn_resend.setTitle("Resend Verification Code", for: .normal)
            }
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    Toast.show(message: "Unable to send verification code. Try again later", controller: self)
                }
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            
            if let responseJSON = responseJSON as? [String: Any] {
                guard let result = responseJSON["result"] else {
                    DispatchQueue.main.async {
                        Toast.show(message: "Unable to send verification code. Try again later", controller: self)
                    }
                    return
                }
                
                if let result = result as? [String: Any] {
                    let err = result["error"] as! String
                    
                    if (err.isEmpty) {
                        DispatchQueue.main.async {
                            self.btn_resend.isEnabled = false
                            self.btn_resend.setTitle("Resend Verification Code (00:\(self.counter))", for: .normal)
                            self.startTimer()
                        }
                    }
                    else {
                        DispatchQueue.main.async {
                            Toast.show(message: err, controller: self)
                        }
                    }
                }
            }
        }
    }
    @IBAction func GoBack(_ sender: UIButton) {
        let transition = CATransition()
        transition.duration = 0.5 // Set animation duration
        transition.type = CATransitionType.push // Set transition type to push
        transition.subtype = CATransitionSubtype.fromLeft // Set transition subtype to from right
        self.view.window?.layer.add(transition, forKey: kCATransition) // Add transition to window layer
        self.dismiss(animated: false)
    }
    
    func startTimer() {
        // Invalidate the previous timer if it exists
        timer?.invalidate()

        // Create a new timer and specify the interval (in seconds) and the target method
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerFired), userInfo: nil, repeats: true)
    }

    @objc func timerFired() {
        // Perform actions you want to execute when the timer fires
        counter -= 1
        self.btn_resend.setTitle("Resend Verification Code (00:\(counter))", for: .normal)
        if counter == 0 {
            stopTimer()
        }
    }

    func stopTimer() {
        // Stop the timer by invalidating it
        self.btn_resend.setTitle("Resend Verification Code", for: .normal)
        counter = 30
        self.btn_resend.isEnabled = true
        timer?.invalidate()
        timer = nil
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
