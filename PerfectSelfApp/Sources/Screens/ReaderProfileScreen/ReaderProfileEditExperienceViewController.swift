//
//  ReaderProfileEditExperienceViewController.swift
//  PerfectSelf
//
//  Created by user237181 on 6/9/23.
//  Copyright © 2023 Stas Seldin. All rights reserved.
//

import UIKit

class ReaderProfileEditExperienceViewController: UIViewController {

    @IBOutlet weak var text_school: UITextField!
    @IBOutlet weak var text_description: UITextView!
    @IBOutlet weak var text_end_date: UITextField!
    @IBOutlet weak var text_start_date: UITextField!
    @IBOutlet weak var text_degree: UITextField!
    
    @IBOutlet weak var btn_end_date: UIButton!
    @IBOutlet weak var btn_start_date: UIButton!
    
    @IBOutlet weak var view_date_modal: UIStackView!
    @IBOutlet weak var view_background: UIView!
    @IBOutlet weak var btn_close_modal: UIButton!
    @IBOutlet weak var lbl_start_end_date: UILabel!
    
    @IBOutlet weak var date_picker: UIDatePicker!
    var isStartDate = true
    let df = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view_background.isHidden = true;
        view_date_modal.isHidden = true;
        df.dateFormat = "yyyy-MM-dd"
    }

  
    @IBAction func ShowModalForStartDate(_ sender: UIButton) {
        isStartDate = true;
        lbl_start_end_date.text = "Set Start Date"
        view_background.isHidden = false
        view_date_modal.isHidden = false
    }
    
    @IBAction func ShowModalForEndDate(_ sender: UIButton) {
        isStartDate = false
        lbl_start_end_date.text = "Set End Date"
        view_background.isHidden = false
        view_date_modal.isHidden = false
    }
    @IBAction func ApplyDate(_ sender: UIButton) {
        if isStartDate {
            text_start_date.text = df.string(from: date_picker.date)
        } else {
            text_end_date.text = df.string(from: date_picker.date)
        }
        view_background.isHidden = true;
        view_date_modal.isHidden = true;
    }
    @IBAction func CloseModal(_ sender: UIButton) {
        view_background.isHidden = true;
        view_date_modal.isHidden = true;
    }
    @IBAction func SaveChanges(_ sender: UIButton) {
        let transition = CATransition()
        transition.duration = 0.5 // Set animation duration
        transition.type = CATransitionType.push // Set transition type to push
        transition.subtype = CATransitionSubtype.fromLeft // Set transition subtype to from right
        self.view.window?.layer.add(transition, forKey: kCATransition) // Add transition to window layer
        self.dismiss(animated: false)
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
