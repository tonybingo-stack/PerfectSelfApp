//
//  ActorBuildProfile1ViewController.swift
//  PerfectSelf
//
//  Created by user232392 on 3/18/23.
//  Copyright © 2023 Stas Seldin. All rights reserved.
//

import UIKit

class ActorBuildProfile1ViewController: UIViewController {

//    var userType : String = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


    @IBAction func Later(_ sender: UIButton) {
        let controller = ActorTabBarController()
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: false)
    }
    @IBAction func BuildProfile(_ sender: UIButton) {
        let controller = ActorBuildProfile2ViewController()
        controller.modalPresentationStyle = .fullScreen
//        let transition = CATransition()
//        transition.duration = 0.5 // Set animation duration
//        transition.type = CATransitionType.push // Set transition type to push
//        transition.subtype = CATransitionSubtype.fromRight // Set transition subtype to from right
//        self.view.window?.layer.add(transition, forKey: kCATransition) // Add transition to window layer
        self.present(controller, animated: false)
//        self.navigationController?.pushViewController(controller, animated: true)
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
