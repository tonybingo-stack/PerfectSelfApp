//
//  ReaderProfileEditAboutViewController.swift
//  PerfectSelf
//
//  Created by Kayan Mishra on 3/8/23.
//  Copyright © 2023 Stas Seldin. All rights reserved.
//

import UIKit

//protocol DataDelegate: AnyObject {
//    func dataChanged(data: String)
//}

class ReaderProfileEditAboutViewController: UIViewController {
//    weak var delegate: DataDelegate?
    var uid = ""
    var about = ""
    @IBOutlet weak var text_about: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    
        text_about.text = about
    }

    @IBAction func GoBack(_ sender: UIButton) {
        let transition = CATransition()
        transition.duration = 0.5 // Set animation duration
        transition.type = CATransitionType.push // Set transition type to push
        transition.subtype = CATransitionSubtype.fromLeft // Set transition subtype to from right
        self.view.window?.layer.add(transition, forKey: kCATransition) // Add transition to window layer
        self.dismiss(animated: true)
    }
    
    @IBAction func SaveChanges(_ sender: UIButton) {
        // call API for about update
        showIndicator(sender: nil, viewController: self)
        webAPI.editReaderProfile(uid: uid, title: "", min15Price: -1, min30Price: -1,hourlyPrice: -1, about: text_about.text, introBucketName: "", introVideokey: "", skills: nil, auditionType: -1, isExplicitRead: nil) { data, response, error in
            DispatchQueue.main.async {
                hideIndicator(sender: nil);
            }
            guard let _ = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            
            DispatchQueue.main.async {
                let transition = CATransition()
                transition.duration = 0.5 // Set animation duration
                transition.type = CATransitionType.push // Set transition type to push
                transition.subtype = CATransitionSubtype.fromLeft // Set transition subtype to from right
                self.view.window?.layer.add(transition, forKey: kCATransition) // Add transition to window layer
                self.dismiss(animated: false)
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
