//
//  ActorBuildProfile2ViewController.swift
//  PerfectSelf
//
//  Created by user232392 on 3/18/23.
//  Copyright © 2023 Stas Seldin. All rights reserved.
//

import UIKit
import DropDown
import Photos

class ActorBuildProfile2ViewController: UIViewController, PhotoDelegate {
    var id = ""
    var photoType = 0//0: from lib, 1: from camera
    @IBOutlet weak var genderview: UIStackView!
    @IBOutlet weak var ageview: UIStackView!
    let dropDownForGender = DropDown()
    let dropDownForAgeRange = DropDown()
    @IBOutlet weak var text_gender: UITextField!
    @IBOutlet weak var text_age: UITextField!
    @IBOutlet weak var text_username: UITextField!
    @IBOutlet weak var text_weight: UITextField!
    @IBOutlet weak var text_height: UITextField!
    @IBOutlet weak var img_avatar: UIImageView!
    var gender = 0;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // The view to which the drop down will appear on
        if let userInfo = UserDefaults.standard.object(forKey: "USER") as? [String:Any] {
            // Use the saved data
            let name = userInfo["userName"] as! String
            id = userInfo["uid"] as! String
            text_username.text = name
        } else {
            // No data was saved
            print("No data was saved.")
        }
        dropDownForGender.anchorView = genderview // UIView or UIBarButtonItem
        dropDownForAgeRange.anchorView = ageview
        // The list of items to display. Can be changed dynamically
        dropDownForGender.dataSource = genderAry
        dropDownForAgeRange.dataSource = ageRangeAry
        // Action triggered on selection
        dropDownForGender.selectionAction = { [unowned self] (index: Int, item: String) in
            text_gender.text = item
            self.gender = index
        }
        dropDownForAgeRange.selectionAction = { [unowned self] (index: Int, item: String) in
            text_age.text = item
          
        }
        // Top of drop down will be below the anchorView
        dropDownForGender.bottomOffset = CGPoint(x: 0, y:(dropDownForGender.anchorView?.plainView.bounds.height)!)
        dropDownForAgeRange.bottomOffset = CGPoint(x: 0, y:(dropDownForAgeRange.anchorView?.plainView.bounds.height)!)
        
        dropDownForGender.dismissMode = .onTap
        dropDownForAgeRange.dismissMode = .onTap
        
        DropDown.startListeningToKeyboard()
        DropDown.appearance().textColor = UIColor.black
        DropDown.appearance().selectedTextColor = UIColor.link
        DropDown.appearance().textFont = UIFont.systemFont(ofSize: 15)
        DropDown.appearance().backgroundColor = UIColor.white
        DropDown.appearance().selectionBackgroundColor = UIColor.lightGray
        DropDown.appearance().cellHeight = 40
        DropDown.appearance().setupCornerRadius(5) // available since v2.3.6
        
    }

    @IBAction func SelectAvatar(_ sender: UIButton) {
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
    @IBAction func ShowDropDownForAge(_ sender: UIButton) {
        dropDownForAgeRange.show()
    }
    @IBAction func ShowDropDownForGender(_ sender: UIButton) {
        dropDownForGender.show()
        
    }
    @IBAction func Later(_ sender: UIButton) {
        let controller = ActorTabBarController()
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: false)
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
    
    @IBAction func Continue(_ sender: UIButton) {
        var inputCheck: String = ""
        var focusTextField: UITextField? = nil
        if(text_gender.text!.isEmpty){
            inputCheck += "- Please select gender.\n"
            if(focusTextField == nil){
                focusTextField = text_gender
            }
        }
        if(text_age.text!.isEmpty){
             inputCheck += "- Please select your age.\n"
             if(focusTextField == nil){
                 focusTextField = text_age
             }
         }
        if(text_height.text!.isEmpty){
            inputCheck += "- Please input your height.\n"
            if(focusTextField == nil){
                focusTextField = text_height
            }
        }
 
        if(text_weight.text!.isEmpty){
            inputCheck += "- Please input your weight.\n"
            if(focusTextField == nil){
                focusTextField = text_weight
            }
        }
        if(!inputCheck.isEmpty){
            showAlert(viewController: self, title: "Confirm", message: inputCheck) { UIAlertAction in
                focusTextField!.becomeFirstResponder()
            }
            return
        }
        let controller = ActorBuildProfile3ViewController()
        controller.username = text_username.text != nil ? text_username.text!: ""
        controller.gender = self.gender
        controller.agerange = text_age.text != nil ? text_age.text! : ""
        controller.height = text_height.text != nil ? text_height.text! : ""
        controller.weight = text_weight.text != nil ? text_weight.text! : ""
        controller.modalPresentationStyle = .fullScreen
        
//        let transition = CATransition()
//        transition.duration = 0.5 // Set animation duration
//        transition.type = CATransitionType.push // Set transition type to push
//        transition.subtype = CATransitionSubtype.fromRight // Set transition subtype to from right
//        self.view.window?.layer.add(transition, forKey: kCATransition) // Add transition to window layer
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
extension ActorBuildProfile2ViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate  {
    
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

