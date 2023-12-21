//
//  ActorProfileEditViewController.swift
//  PerfectSelf
//
//  Created by user232392 on 3/19/23.
//  Copyright © 2023 Stas Seldin. All rights reserved.
//

import UIKit
import DropDown
import Photos

class ActorProfileEditViewController: UIViewController, PhotoDelegate {
    var id = ""
    
    var photoType = 0//0: from lib, 1: from camera
    let dropDownForGender = DropDown()
    let dropDownForAgeRange = DropDown()
    let dropDownForCountry = DropDown()
    let dropDownForState = DropDown()
    let dropDownForCity = DropDown()
    let dropDownForAgency = DropDown()
    let dropDownForVaccination = DropDown()
    
    @IBOutlet weak var genderview: UIStackView!
    @IBOutlet weak var text_gender: UITextField!
    
    @IBOutlet weak var img_user_avatar: UIImageView!
    @IBOutlet weak var ageview: UIStackView!
    @IBOutlet weak var text_age: UITextField!
    
    @IBOutlet weak var text_country: UITextField!
    @IBOutlet weak var countryview: UIStackView!
    
    @IBOutlet weak var text_state: UITextField!
    @IBOutlet weak var stateview: UIStackView!
    
    @IBOutlet weak var text_city: UITextField!
    @IBOutlet weak var cityview: UIStackView!
    
    @IBOutlet weak var agencyview: UIStackView!
    @IBOutlet weak var text_agency: UITextField!
    
    @IBOutlet weak var vaccinationview: UIStackView!
    @IBOutlet weak var text_vaccination: UITextField!
    
    
    @IBOutlet weak var text_username: UITextField!
    @IBOutlet weak var text_weight: UITextField!
    @IBOutlet weak var text_height: UITextField!
    
    var countryMap = Dictionary<String, String>()
    var stateMap = Dictionary<String, String>()
    var cityMap = Dictionary<String, String>()
    var vaccin = 0
    var gender = 0
    
    var bucketName: String?
    var avatarKey: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // set dropdown
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
        
        // City
        dropDownForCity.anchorView = cityview
        dropDownForCity.dataSource = []
        dropDownForCity.selectionAction = { [unowned self] (index: Int, item: String) in
            text_city.text = item
        }
        dropDownForCity.bottomOffset = CGPoint(x: 0, y:(dropDownForCity.anchorView?.plainView.bounds.height)!)
        dropDownForCity.dismissMode = .onTap
        
        // State
        dropDownForState.anchorView = stateview
        dropDownForState.dataSource = []
        dropDownForState.selectionAction = { [unowned self] (index: Int, item: String) in
            text_state.text = item
            self.text_city.text = ""
            
            webAPI.getCities(stateCode: self.stateMap[item]!) { data, response, error in
                guard let data = data, error == nil else {
                    print(error?.localizedDescription ?? "No data")
                    return
                }
                do {
                    let respItemsTmp = try JSONDecoder().decode([String: String].self, from: data)
                    let respItems = respItemsTmp.sorted(by: <)
                    //print(respItems)
                    DispatchQueue.main.async {
                        self.dropDownForCity.dataSource.removeAll()
                        self.cityMap = [:]
                        respItems.forEach { (key, value) in
                            //print("Key: \(key), Value: \(value)")
                            self.cityMap[key] = "\(value)"
                            self.dropDownForCity.dataSource.append(key)
                        }
                    }
                } catch {
                    print(error)
                }
            }
        }
        dropDownForState.bottomOffset = CGPoint(x: 0, y:(dropDownForState.anchorView?.plainView.bounds.height)!)
        dropDownForState.dismissMode = .onTap
        
        dropDownForCountry.anchorView = countryview
        dropDownForCountry.dataSource = []
        dropDownForCountry.selectionAction = { [unowned self] (index: Int, item: String) in
            text_country.text = item
            self.text_state.text = ""
            self.text_city.text = ""
            
            webAPI.getStates(countryCode: self.countryMap[item]!) { data, response, error in
                guard let data = data, error == nil else {
                    print(error?.localizedDescription ?? "No data")
                    return
                }
                do {
                    let respItemsTmp = try JSONDecoder().decode([String: Int].self, from: data)
                    let respItems = respItemsTmp.sorted(by: <)
                    //print(respItems)
                    DispatchQueue.main.async {
                        self.dropDownForState.dataSource.removeAll()
                        self.stateMap = [:]
                        respItems.forEach { (key, value) in
                            //print("Key: \(key), Value: \(value)")
                            self.stateMap[key] = "\(value)"
                            self.dropDownForState.dataSource.append(key)
                        }
                    }
                } catch {
                    print(error)
                }
            }
        }
        dropDownForCountry.bottomOffset = CGPoint(x: 0, y:(dropDownForCountry.anchorView?.plainView.bounds.height)!)
        dropDownForCountry.dismissMode = .onTap
        webAPI.getCountries { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            do {
                let respItemsTmp = try JSONDecoder().decode([String: String].self, from: data)
                let respItems = respItemsTmp.sorted(by: <)
                //print(respItems)
                DispatchQueue.main.async {
                    self.dropDownForCountry.dataSource.removeAll()
                    self.countryMap = [:]
                    respItems.forEach { (key, value) in
                        //print("Key: \(key), Value: \(value)")
                        self.countryMap[key] = value
                        self.dropDownForCountry.dataSource.append(key)
                    }
                }
            } catch {
                print(error)
            }
        }
        
        // Agency
        dropDownForAgency.anchorView = agencyview
        dropDownForAgency.dataSource = ["No", "Yes"]
        dropDownForAgency.selectionAction = { [unowned self] (index: Int, item: String) in
            text_agency.text = item
          
        }
        dropDownForAgency.bottomOffset = CGPoint(x: 0, y:(dropDownForAgency.anchorView?.plainView.bounds.height)!)
        dropDownForAgency.dismissMode = .onTap
        
        // Vaccination
        dropDownForVaccination.anchorView = vaccinationview
        dropDownForVaccination.dataSource = ["Not Vaccinated", "Partially Vaccinated", "Fully Vaccinated"]
        
        dropDownForVaccination.selectionAction = { [unowned self] (index: Int, item: String) in
            text_vaccination.text = item
            self.vaccin = index
        }
        dropDownForVaccination.bottomOffset = CGPoint(x: 0, y:(dropDownForVaccination.anchorView?.plainView.bounds.height)!)
        dropDownForVaccination.dismissMode = .onTap
        
        
        DropDown.startListeningToKeyboard()
        DropDown.appearance().textColor = UIColor.black
        DropDown.appearance().selectedTextColor = UIColor.link
        DropDown.appearance().textFont = UIFont.systemFont(ofSize: 15)
        DropDown.appearance().backgroundColor = UIColor.white
        DropDown.appearance().selectionBackgroundColor = UIColor.lightGray
        DropDown.appearance().cellHeight = 40
        DropDown.appearance().setupCornerRadius(5) // available since v2.3.6
        // Retrieve the saved data from UserDefaults
        if let userInfo = UserDefaults.standard.object(forKey: "USER") as? [String:Any] {
            // Use the saved data
            id = userInfo["uid"] as! String
            self.text_username.text = userInfo["userName"] as? String ?? ""
            let g = userInfo["gender"] as? Int
            self.gender = g!;
            self.text_gender.text = genderAry[g!]
            
            bucketName = userInfo["avatarBucketName"] as? String
            avatarKey = userInfo["avatarKey"] as? String
            
            if (bucketName != nil && avatarKey != nil) {
                let url = "https://\( bucketName!).s3.us-east-2.amazonaws.com/\(avatarKey!)"
                img_user_avatar.imageFrom(url: URL(string: url)!)
            }
        } else {
            // No data was saved
            print("No data was saved.")
        }
        // Get Actor profile from DB
        showIndicator(sender: nil, viewController: self)
        webAPI.getActorProfile(actoruid: self.id) { data, response, error in
            DispatchQueue.main.async {
                hideIndicator(sender: nil)
            }
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            do {
                enum MyError: Error {
                    case NotFound
                }
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    if statusCode != 200 {
                        throw MyError.NotFound
                    }
                    print("Status code: \(statusCode)")
                }
                let item = try JSONDecoder().decode(ActorProfile.self, from: data)
                
                DispatchQueue.main.async {
                    self.text_age.text = item.ageRange
                    self.text_height.text = String(item.height)
                    self.text_weight.text = String(item.weight)
                    self.text_country.text = item.country
                    self.text_state.text = item.state
                    self.text_city.text = item.city
                    self.text_agency.text = item.agency
                    if item.vaccinationStatus == 0 {
                        self.text_vaccination.text = "Not Vaccinated"
                        self.vaccin = 0
                    } else if item.vaccinationStatus == 1 {
                        self.text_vaccination.text = "Partially Vaccinated"
                        self.vaccin = 1
                    } else if item.vaccinationStatus == 2 {
                        self.text_vaccination.text = "Fully Vaccinated"
                        self.vaccin = 2
                    } else {
                        self.text_vaccination.text = ""
                    }
                    
                }
            }
            catch {
                print(error)
                DispatchQueue.main.async {
                    Toast.show(message: "Something went wrong. try again later", controller: self)
                }
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
     
    }
    @IBAction func SaveChanges(_ sender: UIButton) {
        var inputCheck: String = ""
        var focusTextField: UITextField? = nil
        if(self.text_username.text!.isEmpty){
            inputCheck += "- Please input user name.\n"
            if(focusTextField == nil){
                focusTextField = self.text_username
            }
        }
        
        if(self.text_gender.text!.isEmpty){
            inputCheck += "- Please select your gender.\n"
            if(focusTextField == nil){
                focusTextField = self.text_gender
            }
        }
        if(self.text_age.text!.isEmpty){
            inputCheck += "- Please select your age range.\n"
            if(focusTextField == nil){
                focusTextField = self.text_age
            }
        }
        if(self.text_height.text!.isEmpty){
            inputCheck += "- Please input your height.\n"
            if(focusTextField == nil){
                focusTextField = self.text_height
            }
        }
        if(self.text_weight.text!.isEmpty){
            inputCheck += "- Please input your weight.\n"
            if(focusTextField == nil){
                focusTextField = self.text_weight
            }
        }
        if(self.text_country.text!.isEmpty){
            inputCheck += "- Please select your country.\n"
            if(focusTextField == nil){
                focusTextField = self.text_country
            }
        }
        if(self.text_state.text!.isEmpty){
            inputCheck += "- Please select your state.\n"
            if(focusTextField == nil){
                focusTextField = self.text_state
            }
        }
        if(self.text_city.text!.isEmpty){
            inputCheck += "- Please select your city.\n"
            if(focusTextField == nil){
                focusTextField = self.text_city
            }
        }
        if(self.text_agency.text!.isEmpty){
            inputCheck += "- Please select your agency.\n"
            if(focusTextField == nil){
                focusTextField = self.text_state
            }
        }
        if(self.text_vaccination.text!.isEmpty){
            inputCheck += "- Please select your vaccination state.\n"
            if(focusTextField == nil){
                focusTextField = self.text_vaccination
            }
        }
        
        if(!inputCheck.isEmpty){
            showAlert(viewController: self, title: "Confirm", message: inputCheck) { UIAlertAction in
                focusTextField!.becomeFirstResponder()
            }
            return
        }
        if let userInfo = UserDefaults.standard.object(forKey: "USER") as? [String:Any] {
            // Use the saved data
            self.bucketName = userInfo["avatarBucketName"] as? String
            self.avatarKey = userInfo["avatarKey"] as? String
        } else {
            // No data was saved
            print("No data was saved.")
        }
        // save chages to db
        showIndicator(sender: nil, viewController: self)
        webAPI.updateActorProfile(actoruid: self.id, ageRange: self.text_age.text!, height: self.text_height.text!, weight: self.text_weight.text!, country: self.text_country.text!, state: self.text_state.text!, city: self.text_city.text!, agency: self.text_agency.text!, vaccination: self.vaccin) { data, response, error in

            guard error == nil else {
                print(error?.localizedDescription ?? "No data")
                DispatchQueue.main.async {
                    hideIndicator(sender: nil)
                    Toast.show(message: "Something went wrong. Unable to save changes", controller: self)
                }
                return
            }
           
            if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if statusCode == 204 {
                 
                    DispatchQueue.main.async {
                        //update username and gender
                        webAPI.updateUserInfo(uid: self.id, userType: -1, bucketName: self.bucketName ?? "", avatarKey: self.avatarKey ?? "", username: self.text_username.text!, email: "", password: "", firstName: "", lastName: "", dateOfBirth: "", gender: self.gender, currentAddress: "", permanentAddress: "", city: "", nationality: "", phoneNumber: "", isLogin: true, fcmDeviceToken: "", deviceKind: -1) { data, response, error in
                            DispatchQueue.main.async {
                                hideIndicator(sender: nil)
                            }
                            guard error == nil else {
                                print(error?.localizedDescription ?? "No data")
                                return
                            }
                            print(response.debugDescription)
                            if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                                if statusCode == 204 {
                                    
                                    DispatchQueue.main.async {
                                        // update local
                                        // Retrieve the saved data from UserDefaults
                                        if var userInfo = UserDefaults.standard.object(forKey: "USER") as? [String:Any] {
                                            // Use the saved data
                                            userInfo["userName"] = self.text_username.text
                                            userInfo["gender"] = self.gender
                                            UserDefaults.standard.removeObject(forKey: "USER")
                                            UserDefaults.standard.set(userInfo, forKey: "USER")
                                            
                                        } else {
                                            // No data was saved
                                            print("No data was saved.")
                                        }
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
                    return
                }
                DispatchQueue.main.async {
                    Toast.show(message: "Something went wrong, unable to save changes", controller: self)
                }
                print("Status code: \(statusCode)")
                return
            }
        }
    }
    @IBAction func ShowDropDownForAge(_ sender: UIButton) {
        dropDownForAgeRange.show()
    }
    @IBAction func ShowDropDownForGender(_ sender: UIButton) {
        dropDownForGender.show()
        
    }
    @IBAction func ShowCountryDropDown(_ sender: UIButton) {
        dropDownForCountry.show()
    }

    @IBAction func CheckValidCountry(_ sender: UITextField) {
        if !self.countryMap.keys.contains(sender.text!) {
            sender.text = ""
        }
    }
    
    @IBAction func SearchCountry(_ sender: UITextField) {
        
        self.dropDownForCountry.dataSource.removeAll()
        let list = self.countryMap.keys.filter {$0.lowercased().contains(sender.text!.lowercased())}
        self.dropDownForCountry.dataSource = list
        if list.isEmpty {
            dropDownForCountry.hide()
        } else {
            dropDownForCountry.show()
        }
    }
    @IBAction func ShowStateDropDown(_ sender: UIButton) {
        dropDownForState.show()
    }
    
    @IBAction func CheckValidState(_ sender: UITextField) {
        if !self.stateMap.keys.contains(sender.text!) {
            sender.text = ""
        }
    }
    @IBAction func SearchState(_ sender: UITextField) {
        self.dropDownForState.dataSource.removeAll()
        let list = self.stateMap.keys.filter {$0.lowercased().contains(sender.text!.lowercased())}
        self.dropDownForState.dataSource = list
        if list.isEmpty {
            dropDownForState.hide()
        } else {
            dropDownForState.show()
        }
    }
    @IBAction func ShowCityDropDown(_ sender: UIButton) {
        dropDownForCity.show()
    }
    @IBAction func CheckValidCity(_ sender: UITextField) {
        if !self.cityMap.keys.contains(sender.text!) {
            sender.text = ""
        }
    }
    @IBAction func SearchCity(_ sender: UITextField) {
        self.dropDownForCity.dataSource.removeAll()
        let list = self.cityMap.keys.filter {$0.lowercased().contains(sender.text!.lowercased())}
        self.dropDownForCity.dataSource = list
        if list.isEmpty {
            dropDownForCity.hide()
        } else {
            dropDownForCity.show()
        }
    }
    @IBAction func ShowAgencyDropDown(_ sender: UIButton) {
        dropDownForAgency.show()
    }
    @IBAction func ShowVaccinationDropDown(_ sender: UIButton) {
        dropDownForVaccination.show()
    }
    @IBAction func UploadImage(_ sender: UIButton) {
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
                        self.bucketName = ""
                        self.avatarKey = ""
                        self.img_user_avatar.image = UIImage(systemName: "person.fill")
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

/// Mark:https://perfectself-avatar-bucket.s3.us-east-2.amazonaws.com/{room-id-000-00}/{647730C6-5E86-483A-859E-5FBF05767018.jpeg}
extension ActorProfileEditViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate  {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            //Omitted let awsUpload = AWSMultipartUpload()
            DispatchQueue.main.async {
                showIndicator(sender: nil, viewController: self, color:UIColor.white)
//                Toast.show(message: "Start to upload record files", controller: self)
            }
            // Get the URL of the selected image
            //var imageUrl = info[UIImagePickerController.InfoKey.mediaURL] as! URL?
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
            
            uploadAvatar(prefix: self.id, avatarUrl: avatarUrl, imgControl: self.img_user_avatar, controller: self)
        }//DispatchQueue.global
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
