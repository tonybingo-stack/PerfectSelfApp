//
//  ActorProfileViewController.swift
//  PerfectSelf
//
//  Created by user232392 on 3/19/23.
//  Copyright © 2023 Stas Seldin. All rights reserved.
//

import UIKit

class ActorProfileViewController: UIViewController {

    var id = ""
    var bucketName: String?
    var avatarKey: String?
    
    @IBOutlet weak var lbl_fullname: UILabel!
    @IBOutlet weak var lbl_username: UILabel!
    @IBOutlet weak var lbl_email: UILabel!
    @IBOutlet weak var img_user_avatar: UIImageView!
    @IBOutlet weak var switch_mode: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        switch_mode.transform = CGAffineTransform(scaleX: 0.8, y: 0.75);
        if let thumb = switch_mode.subviews[0].subviews[1].subviews[2] as? UIImageView {
            thumb.transform = CGAffineTransform(scaleX:1.25, y: 1.333)
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        // Retrieve the saved data from UserDefaults
        if let userInfo = UserDefaults.standard.object(forKey: "USER") as? [String:Any] {
            
            // Use the saved data
            id = userInfo["uid"] as! String
            let name = userInfo["userName"] as? String ?? ""
            let fname = userInfo["firstName"] as? String
            let lname = userInfo["lastName"] as? String
            let email = userInfo["email"] as? String
            
            bucketName = userInfo["avatarBucketName"] as? String
            avatarKey = userInfo["avatarKey"] as? String
            
            if (bucketName != nil && avatarKey != nil) {
                let url = "https://\( bucketName!).s3.us-east-2.amazonaws.com/\(avatarKey!)"
                img_user_avatar.imageFrom(url: URL(string: url)!)
            }
            lbl_fullname.text = (fname ?? "") + " " + (lname ?? "")
            lbl_username.text = name
            lbl_email.text = email
        } else {
            // No data was saved
            print("No data was saved.")
        }
    }
   
    @IBAction func EditProfile(_ sender: UITapGestureRecognizer) {
        let controller = ActorProfileEditViewController()
        controller.id = id
        controller.modalPresentationStyle = .fullScreen
       
//        let transition = CATransition()
//        transition.duration = 0.5 // Set animation duration
//        transition.type = CATransitionType.push // Set transition type to push
//        transition.subtype = CATransitionSubtype.fromRight // Set transition subtype to from right
//        self.view.window?.layer.add(transition, forKey: kCATransition) // Add transition to window layer
        self.present(controller, animated: false)
    }
    
    @IBAction func ChangePassword(_ sender: UITapGestureRecognizer) {
        let controller = ActorProfileChangePasswordViewController()
        controller.id = id
        controller.bucketName = self.bucketName
        controller.avatarKey = self.avatarKey
        controller.modalPresentationStyle = .fullScreen
//        let transition = CATransition()
//        transition.duration = 0.5 // Set animation duration
//        transition.type = CATransitionType.push // Set transition type to push
//        transition.subtype = CATransitionSubtype.fromRight // Set transition subtype to from right
//        self.view.window?.layer.add(transition, forKey: kCATransition) // Add transition to window layer
        self.present(controller, animated: false)
        
    }
    
    @IBAction func LogOut(_ sender: UITapGestureRecognizer) {
        // Optional: Dismiss the tab bar controller
        // Delete localstorage
        // change user online status
        showIndicator(sender: nil, viewController: self)
        webAPI.updateOnlineState(uid: self.id, newState: false) { data, response, error in
            DispatchQueue.main.async {
                hideIndicator(sender: nil)
            }
            guard error == nil else {
                return
            }
            DispatchQueue.main.async {
                UserDefaults.standard.removeObject(forKey: "USER")
                UserDefaults.standard.removeObject(forKey: "USER_EMAIL")
                UserDefaults.standard.removeObject(forKey: "USER_PWD")
                
                let controller = LoginViewController()
                controller.modalPresentationStyle = .fullScreen
                self.present(controller, animated: false)
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


