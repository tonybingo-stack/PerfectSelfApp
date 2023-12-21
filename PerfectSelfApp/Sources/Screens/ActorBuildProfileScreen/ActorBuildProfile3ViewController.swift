//
//  ActorBuildProfile3ViewController.swift
//  PerfectSelf
//
//  Created by user232392 on 3/18/23.
//  Copyright © 2023 Stas Seldin. All rights reserved.
//

import UIKit
import DropDown

class ActorBuildProfile3ViewController: UIViewController {

    var uid = ""
    var username:String = ""
    var gender:Int = 0
    var agerange:String = ""
    var height:String = ""
    var weight: String = ""
    var vaccin = 0
    
    let dropDownForCountry = DropDown()
    let dropDownForState = DropDown()
    let dropDownForCity = DropDown()
    let dropDownForAgency = DropDown()
    let dropDownForVaccination = DropDown()
    
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
    
    var countryMap = Dictionary<String, String>()
    var stateMap = Dictionary<String, String>()
    var cityMap = Dictionary<String, String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let userInfo = UserDefaults.standard.object(forKey: "USER") as? [String:Any] {
            // Use the saved data
            uid = userInfo["uid"] as! String
        } else {
            // No data was saved
            print("No data was saved.")
        }
        // The view to which the drop down will appear on
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
        
        //Country
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
        let list = self.countryMap.keys.filter {$0.lowercased().contains(sender.text!.lowercased() )}
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
    @IBAction func Later(_ sender: UIButton) {
        let controller = ActorTabBarController()
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: false)
    }
    
    @IBAction func Done(_ sender: UIButton) {
        var inputCheck: String = ""
        var focusTextField: UITextField? = nil
        if(text_country.text!.isEmpty){
            inputCheck += "- Please select country .\n"
            if(focusTextField == nil){
                focusTextField = text_country
            }
        }
        if(text_state.text!.isEmpty){
            inputCheck += "- Please select state .\n"
            if(focusTextField == nil){
                focusTextField = text_state
            }
        }
        if(text_city.text!.isEmpty){
            inputCheck += "- Please select city .\n"
            if(focusTextField == nil){
                focusTextField = text_city
            }
        }
        if(text_agency.text!.isEmpty){
            inputCheck += "- Please select agency .\n"
            if(focusTextField == nil){
                focusTextField = text_agency
            }
        }
//Omitted 
//        if(text_vaccination.text!.isEmpty){
//            inputCheck += "- Please select vaccination .\n"
//            if(focusTextField == nil){
//                focusTextField = text_vaccination
//            }
//        }
        if(!inputCheck.isEmpty){
            showAlert(viewController: self, title: "Confirm", message: inputCheck) { UIAlertAction in
                focusTextField!.becomeFirstResponder()
            }
            return
        }
        showIndicator(sender: sender, viewController: self)
   
        webAPI.updateActorProfile(actoruid: uid, ageRange: agerange, height: height, weight: weight, country: text_country.text ?? "", state: text_state.text ?? "", city: text_city.text ?? "", agency: text_agency.text ?? "", vaccination: self.vaccin) { data, response, error in
            guard let _ = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                DispatchQueue.main.async {
                    Toast.show(message: "Profile update failed! please try again.", controller: self)
                }
                return
            }
            DispatchQueue.main.async {
                
                if var userInfo = UserDefaults.standard.object(forKey: "USER") as? [String:Any] {
                    // Use the saved data
                    let bucketName = userInfo["avatarBucketName"] as? String
                    let avatarKey = userInfo["avatarKey"] as? String
                    webAPI.updateUserInfo(uid: self.uid, userType: -1, bucketName: bucketName ?? "", avatarKey: avatarKey ?? "", username: "", email: "", password: "", firstName: "", lastName: "", dateOfBirth: "", gender: self.gender, currentAddress: "", permanentAddress: "", city: "", nationality: "", phoneNumber: "", isLogin: true, fcmDeviceToken: "", deviceKind: -1) { data, response, error in
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
                            
                            let controller = ActorTabBarController()
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
