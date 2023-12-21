//
//  ReaderBuildProfileViewController.swift
//  PerfectSelf
//
//  Created by user232392 on 3/31/23.
//  Copyright © 2023 Stas Seldin. All rights reserved.
//

import UIKit
import DropDown

class ReaderBuildProfileViewController: UIViewController, PhotoDelegate {

    var id = ""
    var username = ""
    var photoType = 0//0: from lib, 1: from camera
    
    @IBOutlet weak var text_hourly: UITextField!
    @IBOutlet weak var text_gender: UITextField!
    @IBOutlet weak var text_title: UITextField!
    @IBOutlet weak var lbl_name: UILabel!
    
    @IBOutlet weak var img_avatar: UIImageView!
    @IBOutlet weak var genderView: UIStackView!
    let dropDownForGender = DropDown()
    var gender = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        lbl_name.text = username
        dropDownForGender.anchorView = genderView
        dropDownForGender.dataSource = genderAry
        dropDownForGender.selectionAction = { [unowned self] (index: Int, item: String) in
            text_gender.text = item
            self.gender = index
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
    }
    @IBAction func ShowDropDownForGender(_ sender: UIButton) {
        dropDownForGender.show()
        
    }
    @IBAction func Done(_ sender: UIButton) {
        // calll API for reader profile update
        var inputCheck: String = ""
        var focusTextField: UITextField? = nil
        if(text_title.text!.isEmpty){
            inputCheck += "- Please input title .\n"
            if(focusTextField == nil){
                focusTextField = text_title
            }
        }
        if(text_gender.text!.isEmpty){
            inputCheck += "- Please select your gender .\n"
            if(focusTextField == nil){
                focusTextField = text_gender
            }
        }
        if(text_hourly.text!.isEmpty){
            inputCheck += "- Please input hourly rate .\n"
            if(focusTextField == nil){
                focusTextField = text_hourly
            }
        }
 
        if(!inputCheck.isEmpty){
            showAlert(viewController: self, title: "Confirm", message: inputCheck) { UIAlertAction in
                focusTextField!.becomeFirstResponder()
            }
            return
        }
        guard let rate = Float(text_hourly.text!) else {
            showAlert(viewController: self, title: "Warning", message: "Input number invalid") {_ in
                
            }
            return
        }
        showIndicator(sender: sender, viewController: self)
        let rate15 = preciseRound(Float(rate) / 4.0, precision: .tenths)
        let rate30 = preciseRound(Float(rate) / 2.0, precision: .tenths)
        webAPI.editReaderProfile(uid: id, title: text_title.text!, min15Price: rate15, min30Price: rate30, hourlyPrice: Float(rate), about: "", introBucketName: "", introVideokey: "", skills: "", auditionType: -1, isExplicitRead: nil) { data, response, error in
            guard let _ = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                DispatchQueue.main.async {
                    hideIndicator(sender: sender)
                    Toast.show(message: "Profile update failed! please try again.", controller: self)
                }
                return
            }
            
            DispatchQueue.main.async {
                
                if var userInfo = UserDefaults.standard.object(forKey: "USER") as? [String:Any] {
                    // Use the saved data
                    let uid = userInfo["uid"] as! String
                    let bucketName = userInfo["avatarBucketName"] as? String
                    let avatarKey = userInfo["avatarKey"] as? String
                    webAPI.updateUserInfo(uid: uid, userType: -1, bucketName: bucketName ?? "", avatarKey: avatarKey ?? "", username: "", email: "", password: "", firstName: "", lastName: "", dateOfBirth: "", gender: self.gender, currentAddress: "", permanentAddress: "", city: "", nationality: "", phoneNumber: "", isLogin: true, fcmDeviceToken: "", deviceKind: -1) { data, response, error in
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
                            
                            let controller = ReaderTabBarController()
                            controller.modalPresentationStyle = .fullScreen
                            self.present(controller, animated: false)
                        }
                    }
                    
                } else {
                    // No data was saved
                    print("No data was saved.")
                }
                
            }
        }
    }
    
    @IBAction func EditUserAvatar(_ sender: UIButton) {
        let controller = TakePhotoViewController()
        controller.modalPresentationStyle = .overFullScreen
        controller.delegate = self
        self.present(controller, animated: true)
    }
    func chooseFromLibrary() {
        photoType = 0
        DispatchQueue.main.async {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    func takePhoto() {
        photoType = 1
        DispatchQueue.main.async {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    func removeCurrentPicture() {
        // call API for remove picture
        //update user profile
        webAPI.updateUserInfo(uid: self.id, userType: -1, bucketName: "", avatarKey: "", username: "", email: "", password: "", firstName: "", lastName: "", dateOfBirth: "", gender: -1, currentAddress: "", permanentAddress: "", city: "", nationality: "", phoneNumber: "", isLogin: true, fcmDeviceToken: "", deviceKind: -1) { data, response, error in
            if error == nil {
                // update local
                // Retrieve the saved data from UserDefaults
                if var userInfo = UserDefaults.standard.object(forKey: "USER") as? [String:Any] {
                    // Use the saved data
                    userInfo["avatarBucketName"] = ""
                    userInfo["avatarKey"] = ""
                    UserDefaults.standard.removeObject(forKey: "USER")
                    UserDefaults.standard.set(userInfo, forKey: "USER")
                    print(userInfo)
                    DispatchQueue.main.async {
                        self.img_avatar.image = UIImage(systemName: "person.circle.fill")
                    }
                    
                } else {
                    // No data was saved
                    print("No data was saved.")
                }
            }
        }
    }
    @IBAction func Later(_ sender: UIButton) {
        let controller = ReaderTabBarController()
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: false)
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

/// Mark:https://perfectself-avatar-bucket.s3.us-east-2.amazonaws.com/{room-id-000-00}/{647730C6-5E86-483A-859E-5FBF05767018.jpeg}
extension ReaderBuildProfileViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate  {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            //Omitted let awsUpload = AWSMultipartUpload()
            DispatchQueue.main.async {
                showIndicator(sender: nil, viewController: self, color:UIColor.white)
//                Toast.show(message: "Start to upload record files", controller: self)
            }
            
            // Get the URL of the selected image
            var avatarUrl: URL? = nil
            //Upload audio at first
            guard let image = (self.photoType == 0 ? info[.originalImage] : info[.editedImage]) as? UIImage else {
                //dismiss(animated: true, completion: nil)
                DispatchQueue.main.async {
                    hideIndicator(sender: nil)
                }
                return
            }
            // save to local and get URL
            if self.photoType == 1 {
                let imgName = UUID().uuidString
                let documentDirectory = NSTemporaryDirectory()
                let localPath = documentDirectory.appending(imgName)

                let data = image.jpegData(compressionQuality: 0.3)! as NSData
                data.write(toFile: localPath, atomically: true)
                avatarUrl = URL.init(fileURLWithPath: localPath)
            }
            else {
                avatarUrl = info[.imageURL] as? URL
            }
            
            uploadAvatar(prefix: self.id, avatarUrl: avatarUrl, imgControl: self.img_avatar, controller: self)
        }//DispatchQueue.global
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

