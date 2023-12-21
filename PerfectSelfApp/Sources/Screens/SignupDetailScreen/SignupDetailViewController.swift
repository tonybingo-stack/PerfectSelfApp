//
//  SignupDetailViewController.swift
//  PerfectSelf
//
//  Created by Kayan Mishra on 3/8/23.
//  Copyright © 2023 Stas Seldin. All rights reserved.
//

import UIKit

class SignupDetailViewController: UIViewController {
    var email: String = ""
    var phoneNumber: String = ""
    var password: String = ""
    var isActor: Bool = true
    
    @IBOutlet weak var btn_actor: UIButton!
    @IBOutlet weak var btn_reader: UIButton!
    @IBOutlet weak var txtUserName: UITextField!
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }

    @IBAction func SelectActorThpe(_ sender: UIButton) {
        sender.borderWidth = 3;
        btn_reader.borderWidth = 0;
        isActor = true
    }
    
    @IBAction func SelectReaderType(_ sender: UIButton) {
        sender.borderWidth = 3;
        btn_actor.borderWidth = 0;
        isActor = false
    }
    
    @IBAction func FinishSignUp(_ sender: UIButton) {
        var inputCheck: String = ""
        var focusTextField: UITextField? = nil
        if(txtUserName.text!.isEmpty){
            inputCheck += "- Please input user name.\n"
            if(focusTextField == nil){
                focusTextField = txtUserName
            }
        }
        
        if(txtFirstName.text!.isEmpty){
            inputCheck += "- Please input user first name.\n"
            if(focusTextField == nil){
                focusTextField = txtFirstName
            }
        }
        
        if(txtLastName.text!.isEmpty){
            inputCheck += "- Please input user last name.\n"
            if(focusTextField == nil){
                focusTextField = txtLastName
            }
        }
        
        if(!inputCheck.isEmpty){
            showAlert(viewController: self, title: "Confirm", message: inputCheck) { UIAlertAction in
                focusTextField!.becomeFirstResponder()
            }
            return
        }
        
        if isActor {
            showIndicator(sender: sender, viewController: self)
            webAPI.signup(userType: 3, userName: txtUserName.text!, firstName: txtFirstName.text!, lastName: txtLastName.text!, email: email, password: password, phoneNumber: phoneNumber) { data, response, error in
                DispatchQueue.main.async {
                    hideIndicator(sender: sender)
                }
                guard let data = data, error == nil else {
                    print(error?.localizedDescription ?? "No data")
                   
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("statusCode: \(httpResponse.statusCode)")
                }
                let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                if let responseJSON = responseJSON as? [String: Any] {
                    
                    guard responseJSON["email"] != nil else {
                        DispatchQueue.main.async {
                            Toast.show(message: "here is already an account associated with this email address. Please try again.", controller: self)
                            //self.text_email.becomeFirstResponder()
                        }
                        return
                    }
                    DispatchQueue.main.async {
                        //{{REFME
                        Toast.show(message: "Successfully signed up!", controller: self)
                        UserDefaults.standard.setValue(responseJSON, forKey: "USER")
                        UserDefaults.standard.set(String(self.email), forKey: "USER_EMAIL")
                        UserDefaults.standard.set(String(self.password), forKey: "USER_PWD")
                        
                        let controller = ActorBuildProfile1ViewController()
                        controller.modalPresentationStyle = .fullScreen
                        let transition = CATransition()
                        transition.duration = 0.5 // Set animation duration
                        transition.type = CATransitionType.push // Set transition type to push
                        transition.subtype = CATransitionSubtype.fromRight // Set transition subtype to from right
                        self.view.window?.layer.add(transition, forKey: kCATransition) // Add transition to window layer
                        self.present(controller, animated: false)
                    }
                }
                else
                {
                    DispatchQueue.main.async {
                        Toast.show(message: "here is already an account associated with this email address. Please try again.", controller: self)
                    }
                }
            }
        }
        else {
            showIndicator(sender: sender, viewController: self)
            webAPI.signup(userType: 4, userName: txtUserName.text!, firstName: txtFirstName.text!, lastName: txtLastName.text!, email: email, password: password, phoneNumber: phoneNumber) { data, response, error in
                guard let data = data, error == nil else {
                    print(error?.localizedDescription ?? "No data")
                    DispatchQueue.main.async {
                        hideIndicator(sender: sender)
                    }
                    return
                }
                if let httpResponse = response as? HTTPURLResponse {
                    print("statusCode: \(httpResponse.statusCode)")
                }
                let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                if let responseJSON = responseJSON as? [String: Any] {
                    //print(responseJSON["result"])
                    guard responseJSON["email"] != nil else {
                        DispatchQueue.main.async {
                            hideIndicator(sender: sender)
                            Toast.show(message: "There is already an account associated with this email address. Please try again.", controller: self)
                            //self.text_email.becomeFirstResponder()
                        }
                        return
                    }
                    DispatchQueue.main.async {
                        hideIndicator(sender: sender)
                        //{{REFME
                        Toast.show(message: "Successfully signed up!", controller: self)
                        UserDefaults.standard.setValue(responseJSON, forKey: "USER")
                        UserDefaults.standard.set(String(self.email), forKey: "USER_EMAIL")
                        UserDefaults.standard.set(String(self.password), forKey: "USER_PWD")
                        
                        //}}REFME
                        
                        let controller = ReaderBuildProfileViewController()
                        controller.modalPresentationStyle = .fullScreen
                        controller.id = responseJSON["uid"] as! String
                        controller.username = self.txtUserName.text!
                        
                        let transition = CATransition()
                        transition.duration = 0.5 // Set animation duration
                        transition.type = CATransitionType.push // Set transition type to push
                        transition.subtype = CATransitionSubtype.fromRight // Set transition subtype to from right
                        self.view.window?.layer.add(transition, forKey: kCATransition) // Add transition to window layer
                        self.present(controller, animated: false)
                    }
                }
                else
                {
                    DispatchQueue.main.async {
                        hideIndicator(sender: sender)
                        Toast.show(message: "There is already an account associated with this email address. Please try again.", controller: self)
                    }
                }
            }
        }
        
    }
    @IBAction func GoBack(_ sender: UIButton) {
//        self.navigationController?.popViewController(animated: true)
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
