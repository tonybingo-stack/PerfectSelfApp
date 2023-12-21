//
//  LoginDetailViewController.swift
//  PerfectSelf
//
//  Created by Kayan Mishra on 3/8/23.
//  Copyright © 2023 Stas Seldin. All rights reserved.
//
import UIKit
import GoogleSignIn

class LoginDetailViewController: UIViewController {
    let checkedImage = UIImage(named: "icons8-checked-checkbox-14")! as UIImage
    let uncheckedImage = UIImage(named: "icons8-unchecked-checkbox-14")! as UIImage
    let show = UIImage(named: "icons8-eye-20")! as UIImage
    let hide = UIImage(named : "icons8-hide-20")! as UIImage
    
    @IBOutlet weak var btn_login: UIButton!
    @IBOutlet weak var btn_actor: UIButton!
    @IBOutlet weak var btn_reader: UIButton!
    @IBOutlet weak var btn_forgotpassword: UIButton!
    @IBOutlet weak var btn_rememberme: UIButton!
    @IBOutlet weak var text_email: UITextField!
    @IBOutlet weak var text_password: UITextField!
    @IBOutlet weak var btn_showpassword: UIButton!
    
    var isShowPassword = false;
//    var userType = 3 // 3 for actor, 4 for reader
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        btn_forgotpassword.isSelected = false;
        text_password.isSecureTextEntry = true;
        
        isShowPassword = false;
        
        let userEmail = UserDefaults.standard.string(forKey: "USER_EMAIL")
        let userPwd = UserDefaults.standard.string(forKey: "USER_PWD")
        
        text_email.text = userEmail
        text_password.text = userPwd
//        if let userInfo = UserDefaults.standard.object(forKey: "USER") as? [String:Any] {
//            // Use the saved data
//            self.userType = userInfo["userType"] as? Int ?? 3
//            if userType == 4 {
//                btn_reader.isSelected = true
//                btn_actor.isSelected = false
//                btn_reader.borderWidth = 3;
//                btn_actor.borderWidth = 0;
//            }
//            else {
//                btn_actor.isSelected = true
//                btn_reader.isSelected = false
//                btn_actor.borderWidth = 3;
//                btn_reader.borderWidth = 0;
//            }
//        } else {
//            // No data was saved
//            print("No data was saved.")
//        }
        
//Omitted        GIDSignIn.sharedInstance().presentingViewController = self
//Omitted        GIDSignIn.sharedInstance().clientID = GoogleAuthClientID
//Omitted        GIDSignIn.sharedInstance()?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //DoLogin(UIButton())//AUTOLOGIN
    }
    
    @IBAction func DoLogin(_ sender: UIButton) {
        
        var inputCheck: String = ""
        var focusTextField: UITextField? = nil
        
        if(text_email.text!.isEmpty){
            inputCheck += "- Please input user email.\n"
            if(focusTextField == nil){
                focusTextField = text_email
            }
        }
        
        if(!isValidEmail(email: text_email.text!)){
            inputCheck += "- Email format is wrong.\n"
            if(focusTextField == nil){
                focusTextField = text_email
            }
        }
        
        if(text_password.text!.isEmpty){
            inputCheck += "- Please input user password.\n"
            if(focusTextField == nil){
                focusTextField = text_password
            }
        }
        
        if(!inputCheck.isEmpty){
            showAlert(viewController: self, title: "Confirm", message: inputCheck) { UIAlertAction in
                focusTextField!.becomeFirstResponder()
            }
            return
        }
        showIndicator(sender: sender, viewController: self)
        webAPI.login(userType: -1, email: text_email.text!, password: text_password.text!){ data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            
            if let responseJSON = responseJSON as? [String: Any] {
                guard let result = responseJSON["result"] else {
                    DispatchQueue.main.async {
                        hideIndicator(sender: sender)
                        Toast.show(message: "Login failed! please try again.", controller: self)
                        let _ = self.text_email.becomeFirstResponder()
                    }
                    return
                }
                
                if result as! Bool {
                    let user = responseJSON["user"] as! [String: Any]
                    print(user)
                    let fCMDeviceToken = user["fcmDeviceToken"] as! String
                    let uid = user["uid"] as! String
                    let bucketName = user["avatarBucketName"] as? String
                    let avatarKey = user["avatarKey"] as? String
                    let userType = user["userType"] as? Int
                    
                    if( fcmDeviceToken.count > 0 &&
                        fcmDeviceToken != fCMDeviceToken )
                    {
                        webAPI.updateUserInfo(uid: uid, userType: -1, bucketName: bucketName ?? "", avatarKey: avatarKey ?? "", username: "", email: "", password: "", firstName: "", lastName: "", dateOfBirth: "", gender: -1, currentAddress: "", permanentAddress: "", city: "", nationality: "", phoneNumber: "", isLogin: true, fcmDeviceToken: fcmDeviceToken, deviceKind: -1)  { data, response, error in
                            if error == nil {
                                // successfully update db
                                print("update db completed")
                            }
                        }
                        //print(fcmDeviceToken, deviceKind)
                    }
                    
                    UserDefaults.standard.setValue(user, forKey: "USER")
                    DispatchQueue.main.async {
                        hideIndicator(sender: sender)
                        //{{REFME
                        //var rememberMeFlag: Bool = UserDefaults.standard.bool(forKey: "REMEMBER_USER")
                        let rememberMeFlag: Bool = self.btn_rememberme.isSelected
                        UserDefaults.standard.set(rememberMeFlag, forKey: "REMEMBER_USER")
                        
                        UserDefaults.standard.set(String(self.text_email.text!), forKey: "USER_EMAIL")
                        UserDefaults.standard.set(String(self.text_password.text!), forKey: "USER_PWD")
                        
                        //}}REFME
                        if userType == 3 {
                            let controller = ActorTabBarController();
                            controller.modalPresentationStyle = .fullScreen
                            let transition = CATransition()
                            transition.duration = 0.5 // Set animation duration
                            transition.type = CATransitionType.push // Set transition type to push
                            transition.subtype = CATransitionSubtype.fromRight // Set transition subtype to from right
                            self.view.window?.layer.add(transition, forKey: kCATransition) // Add transition to window layer
                            self.present(controller, animated: false)
                        }
                        else {
                            let controller = ReaderTabBarController();
                            controller.modalPresentationStyle = .fullScreen
                            let transition = CATransition()
                            transition.duration = 0.5 // Set animation duration
                            transition.type = CATransitionType.push // Set transition type to push
                            transition.subtype = CATransitionSubtype.fromRight // Set transition subtype to from right
                            self.view.window?.layer.add(transition, forKey: kCATransition) // Add transition to window layer
                            self.present(controller, animated: false)
                        }
                    }
                }
                else
                {
                    let err = responseJSON["error"] as? String
                    DispatchQueue.main.async {
                        hideIndicator(sender: sender)
                        Toast.show(message: err ?? "", controller: self)
                        let _ = self.text_email.becomeFirstResponder()
                    }
                }
            }
            else
            {
                DispatchQueue.main.async {
                    hideIndicator(sender: sender)
                    Toast.show(message: "Login failed! please try again.", controller: self)
                    let _ = self.text_email.becomeFirstResponder()
                }
            }
        }
    }
    
    @IBAction func ActorSelected(_ sender: UIButton) {
        sender.isSelected=true;
        sender.borderWidth = 3;
        btn_reader.borderWidth = 0;
        btn_reader.isSelected = false;
//        userType = 3;
    }
    @IBAction func ReaderSelected(_ sender: UIButton) {
        sender.isSelected=true;
        sender.borderWidth = 3;
        btn_actor.borderWidth = 0;
        btn_actor.isSelected = false;
//        userType = 4;
    }
    
    @IBAction func ChangeRememberMe(_ sender: UIButton) {
        sender.isSelected.toggle();
        
        if sender.isSelected {
            sender.setImage(checkedImage, for: UIControl.State.normal);
            sender.tintColor = UIColor(red:255,green: 255, blue: 255,  alpha: 1);
        }
        else {
            sender.setImage(uncheckedImage, for: UIControl.State.normal)
        }
    }
    @IBAction func ForgotPassword(_ sender: UIButton) {
        let controller = EmailSubmitViewController();
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: false)
    }
    
    
    @IBAction func ShowPassword(_ sender: UIButton) {
        isShowPassword = !isShowPassword;
        
        if isShowPassword {
            text_password.isSecureTextEntry = false;
            sender.setImage(show, for: UIControl.State.normal);
        }
        else {
            text_password.isSecureTextEntry = true;
            sender.setImage(hide, for: UIControl.State.normal);
        }
    }
    
    @IBAction func googleLoginDidTap(_ sender: Any) {
        //Omitted        let gidSignIn = GIDSignIn.sharedInstance()
        //Omitted        gidSignIn!.signIn()
        GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: self) { signInResult, error in
            guard let signInResult = signInResult else {
                print("Error! \(String(describing: error))")
                return
            }
            print(signInResult.userID!)
        }
    }
    
    @IBAction func facebookLoginDidTap(_ sender: UIButton) {
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

//Omitted
//extension LoginDetailViewController: GIDSignInDelegate{
//    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
////        if let user = user {
////            GIDSignIn.sharedInstance().t.getAuthToken(user) { (token, error) in
////                if let token = token {
////                    // Use token to make authenticated requests to Google API
////                } else if let error = error {
////                    print("Error fetching auth token: \(error.localizedDescription)")
////                }
////            }
////        } else if let error = error {
////            print("Error signing in: \(error.localizedDescription)")
////        }
//    }
//}
