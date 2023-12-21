//
//  ActorProfileChangePasswordViewController.swift
//  PerfectSelf
//
//  Created by user232392 on 3/19/23.
//  Copyright © 2023 Stas Seldin. All rights reserved.
//

import UIKit

class ActorProfileChangePasswordViewController: UIViewController {

    var id = ""
    var bucketName: String?
    var avatarKey: String?
    
    @IBOutlet weak var text_oldpass: UITextField!
    @IBOutlet weak var text_newpass: UITextField!
    @IBOutlet weak var text_confirmpass: UITextField!
    let show = UIImage(named: "icons8-eye-20")! as UIImage
    let hide = UIImage(named : "icons8-hide-20")! as UIImage
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func SaveNewPassword(_ sender: UIButton) {
        var inputCheck: String = ""
        var focusTextField: UITextField? = nil
        if(self.text_oldpass.text!.isEmpty){
            inputCheck += "- Please input old password.\n"
            if(focusTextField == nil){
                focusTextField = self.text_oldpass
            }
        }
        
        if(self.text_newpass.text!.isEmpty){
            inputCheck += "- Please input new password.\n"
            if(focusTextField == nil){
                focusTextField = self.text_newpass
            }
        }
        if(self.text_confirmpass.text!.isEmpty){
            inputCheck += "- Please confirm new password.\n"
            if(focusTextField == nil){
                focusTextField = self.text_confirmpass
            }
        }
        if(self.text_confirmpass.text != self.text_newpass.text){
            inputCheck += "- Password doesn't match.\n"
            if(focusTextField == nil){
                focusTextField = self.text_confirmpass
            }
        }
        if(!inputCheck.isEmpty){
            showAlert(viewController: self, title: "Confirm", message: inputCheck) { UIAlertAction in
                focusTextField!.becomeFirstResponder()
            }
            return
        }
        showIndicator(sender: nil, viewController: self)
        webAPI.updateUserInfo(uid: self.id, userType: -1, bucketName: self.bucketName ?? "", avatarKey: self.avatarKey ?? "", username: "", email: "", password: self.text_newpass.text!, firstName: "", lastName: "", dateOfBirth: "", gender: -1, currentAddress: "", permanentAddress: "", city: "", nationality: "", phoneNumber: "", isLogin: true, fcmDeviceToken: "", deviceKind: -1) { data, response, error in
            DispatchQueue.main.async {
                hideIndicator(sender: nil)
            }
            guard error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
//            print(response.debugDescription)
            if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if statusCode == 204 {
                    DispatchQueue.main.async {
                       
                        let transition = CATransition()
                        transition.duration = 0.5 // Set animation duration
                        transition.type = CATransitionType.push // Set transition type to push
                        transition.subtype = CATransitionSubtype.fromLeft // Set transition subtype to from right
                        self.view.window?.layer.add(transition, forKey: kCATransition) // Add transition to window layer
                        self.dismiss(animated: false)
                    }
                    return
                } else {
                    DispatchQueue.main.async {
                        Toast.show(message: "Something went Wrong. Unable to save changes", controller: self)
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
    
    @IBAction func ShowOldPassword(_ sender: UIButton) {
        text_oldpass.isSecureTextEntry = !text_oldpass.isSecureTextEntry
        
        if text_oldpass.isSecureTextEntry {
            sender.setImage(hide, for: .normal)
        }
        else {
            sender.setImage(show, for: .normal)
        }
    }
    
    @IBAction func ShowNewPassword(_ sender: UIButton) {
        text_newpass.isSecureTextEntry = !text_newpass.isSecureTextEntry
        
        if text_newpass.isSecureTextEntry {
            sender.setImage(hide, for: .normal)
        }
        else {
            sender.setImage(show, for: .normal)
        }
    }

    @IBAction func ShowConfirmPassword(_ sender: UIButton) {
        text_confirmpass.isSecureTextEntry = !text_confirmpass.isSecureTextEntry
        
        if text_confirmpass.isSecureTextEntry {
            sender.setImage(hide, for: .normal)
        }
        else {
            sender.setImage(show, for: .normal)
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
