//
//  ResetPasswordViewController.swift
//  PerfectSelf
//
//  Created by user237181 on 6/2/23.
//  Copyright © 2023 Stas Seldin. All rights reserved.
//

import UIKit

class ResetPasswordViewController: UIViewController {

    var email = ""
    var code = ""
    
    @IBOutlet weak var text_confirm: UITextField!
    @IBOutlet weak var text_pasword: UITextField!
    
    @IBOutlet weak var btn_resetpass: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func ResetPassword(_ sender: UIButton) {
        var inputCheck: String = ""
        var focusTextField: UITextField? = nil
        
        if(text_pasword.text!.isEmpty){
            inputCheck += "- Please input new password.\n"
            if(focusTextField == nil){
                focusTextField = text_pasword
            }
        }
        if(text_confirm.text!.isEmpty){
            inputCheck += "- Please confirm your password.\n"
            if(focusTextField == nil){
                focusTextField = text_confirm
            }
        }
        if(text_pasword.text! != text_confirm.text!){
            inputCheck += "- Password doesn't match.\n"
            if(focusTextField == nil){
                focusTextField = text_pasword
            }
        }
        if(!inputCheck.isEmpty){
            showAlert(viewController: self, title: "Confirm", message: inputCheck) { UIAlertAction in
                focusTextField!.becomeFirstResponder()
            }
            return
        }
        
        self.btn_resetpass.loadingIndicator(true)
        self.btn_resetpass.setTitle("", for: .normal)
        self.btn_resetpass.isEnabled = false
        
        webAPI.resetPassword(email: self.email, code: self.code, password: text_pasword.text!) { data, response, error in
            DispatchQueue.main.async {
                self.btn_resetpass.loadingIndicator(false)
                self.btn_resetpass.setTitle("Reset Password", for: .normal)
                self.btn_resetpass.isEnabled = true
            }
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    Toast.show(message: "Password Reset failed. Try again later", controller: self)
                }
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            
            if let responseJSON = responseJSON as? [String: Any] {
                let result = responseJSON["result"] as! Bool
                
                if result {
                    DispatchQueue.main.async {
                        self.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
                    }
                } else {
                    DispatchQueue.main.async {
                        Toast.show(message: "Password Reset failed. Try again later", controller: self)
                    }
                }
            }
        }
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
