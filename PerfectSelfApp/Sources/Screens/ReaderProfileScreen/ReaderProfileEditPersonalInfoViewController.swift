//
//  ReaderProfileEditPersonalInfoViewController.swift
//  PerfectSelf
//
//  Created by Kayan Mishra on 3/8/23.
//  Copyright © 2023 Stas Seldin. All rights reserved.
//

import UIKit
import DropDown

class ReaderProfileEditPersonalInfoViewController: UIViewController {
    var username = ""
    var usertitle = ""
    var gender = 0
    var uid = ""
    @IBOutlet weak var readerTitle: UITextField!
    @IBOutlet weak var readerName: UITextField!
    @IBOutlet weak var genderView: UIStackView!
    let dropDownForGender = DropDown()
    @IBOutlet weak var text_gender: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        readerName.text = username
        readerTitle.text = usertitle
        dropDownForGender.anchorView = genderView
        dropDownForGender.dataSource = genderAry
        dropDownForGender.selectionAction = { [unowned self] (index: Int, item: String) in
            text_gender.text = item
            gender = index
        }
        // Top of drop down will be below the anchorView
        dropDownForGender.bottomOffset = CGPoint(x: 0, y:(dropDownForGender.anchorView?.plainView.bounds.height)!)
        dropDownForGender.dismissMode = .onTap
        
        DropDown.startListeningToKeyboard()
        DropDown.appearance().textColor = UIColor.black
        DropDown.appearance().selectedTextColor = UIColor.link
        DropDown.appearance().textFont = UIFont.systemFont(ofSize: 15)
        DropDown.appearance().backgroundColor = UIColor.white
        DropDown.appearance().selectionBackgroundColor = UIColor.lightGray
        DropDown.appearance().cellHeight = 40
        DropDown.appearance().setupCornerRadius(5)
        
        //get user info
        webAPI.getUserInfo(uid: uid) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            
            if let responseJSON = responseJSON as? [String: Any] {
                let g = responseJSON["gender"] as? Int
//                print(g ?? "ok")
                DispatchQueue.main.async {
                    self.gender = g ?? 0
                    self.text_gender.text = genderAry[self.gender]
                }
            }
        }
        
    }

    @IBAction func ShowDropdownForGender(_ sender: UITapGestureRecognizer) {
        dropDownForGender.show()
    }
    
    @IBAction func SaveChange(_ sender: UIButton) {
        var inputCheck: String = ""
        var focusTextField: UITextField? = nil
        if(readerTitle.text!.isEmpty){
            inputCheck += "- Please input title.\n"
            if(focusTextField == nil){
                focusTextField = readerTitle
            }
        }
 
        if(readerName.text!.isEmpty){
            inputCheck += "- Please input name.\n"
            if(focusTextField == nil){
                focusTextField = readerName
            }
        }
        
        if(!inputCheck.isEmpty){
            showAlert(viewController: self, title: "Confirm", message: inputCheck) { UIAlertAction in
                focusTextField!.becomeFirstResponder()
            }
            return
        }
        // call API for about update
        showIndicator(sender: nil, viewController: self)

        webAPI.editReaderProfile(uid: uid, title: readerTitle.text!, min15Price: -1, min30Price: -1, hourlyPrice: -1, about: "", introBucketName: "", introVideokey: "", skills: nil, auditionType: -1, isExplicitRead: nil) { data, response, error in
            
            guard let _ = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
//                DispatchQueue.main.async {
//                    hideIndicator(sender: nil);
//                }
                return
            }
//            print("333")
//            if let httpResponse = response as? HTTPURLResponse {
//                print("statusCode: \(httpResponse.statusCode)")
//            }
            DispatchQueue.main.async {
                if var userInfo = UserDefaults.standard.object(forKey: "USER") as? [String:Any] {
                    // Use the saved data
                    
                    let bucketName = userInfo["avatarBucketName"] as? String
                    let avatarKey = userInfo["avatarKey"] as? String
                    webAPI.updateUserInfo(uid: self.uid, userType: -1, bucketName: bucketName ?? "", avatarKey: avatarKey ?? "", username: self.readerName.text!, email: "", password: "", firstName: "", lastName: "", dateOfBirth: "", gender: self.gender, currentAddress: "", permanentAddress: "", city: "", nationality: "", phoneNumber: "", isLogin: true, fcmDeviceToken: "", deviceKind: -1) { data, response, error in
                        DispatchQueue.main.async {
                            hideIndicator(sender: nil);
                        }
                       
                        guard let _ = data, error == nil else {
                            print(error?.localizedDescription ?? "No data")
                            return
                        }
                        
                        DispatchQueue.main.async {
                            //update gender info in local
                            userInfo["gender"] = self.gender
                            UserDefaults.standard.removeObject(forKey: "USER")
                            UserDefaults.standard.set(userInfo, forKey: "USER")
                            
                            let transition = CATransition()
                            transition.duration = 0.5 // Set animation duration
                            transition.type = CATransitionType.push // Set transition type to push
                            transition.subtype = CATransitionSubtype.fromLeft // Set transition subtype to from right
                            self.view.window?.layer.add(transition, forKey: kCATransition) // Add transition to window layer
                            self.dismiss(animated: false)
                        }
                    }
                    
                } else {
                    // No data was saved
                    print("No data was saved.")
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
