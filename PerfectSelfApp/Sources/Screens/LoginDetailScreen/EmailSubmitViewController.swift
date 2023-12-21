//
//  EmailSubmitViewController.swift
//  PerfectSelf
//
//  Created by user237181 on 6/2/23.
//  Copyright © 2023 Stas Seldin. All rights reserved.
//

import UIKit

class EmailSubmitViewController: UIViewController {

    @IBOutlet weak var btn_sendcode: UIButton!
    @IBOutlet weak var text_email: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func SendVerifCode(_ sender: UIButton) {
        var inputCheck: String = ""
        var focusTextField: UITextField? = nil
        
        if(text_email.text!.isEmpty){
            inputCheck += "- Please input your email.\n"
            if(focusTextField == nil){
                focusTextField = text_email
            }
        }
        
        if(!inputCheck.isEmpty){
            showAlert(viewController: self, title: "Confirm", message: inputCheck) { UIAlertAction in
                focusTextField!.becomeFirstResponder()
            }
            return
        }
        //call API
        self.btn_sendcode.loadingIndicator(true)
        sender.setTitle("", for: .normal)
        
        webAPI.sendVerifyCodeToEmail(email: text_email.text!) { data, response, error in
            DispatchQueue.main.async {
                self.btn_sendcode.loadingIndicator(false)
                self.btn_sendcode.setTitle("Send Verification Code", for: .normal)
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
                            let controller = VerifCodeViewController();
                            controller.email = self.text_email.text!
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
    
    @IBAction func GoBack(_ sender: UIButton) {
        let transition = CATransition()
        transition.duration = 0.5 // Set animation duration
        transition.type = CATransitionType.push // Set transition type to push
        transition.subtype = CATransitionSubtype.fromLeft // Set transition subtype to from right
        self.view.window?.layer.add(transition, forKey: kCATransition) // Add transition to window layer
        self.dismiss(animated: false)
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
