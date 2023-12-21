//
//  DateSelectViewController.swift
//  PerfectSelf
//
//  Created by user232392 on 4/3/23.
//  Copyright © 2023 Stas Seldin. All rights reserved.
//

import UIKit
import Koyomi

protocol SelectDateDelegate: AnyObject {
    func didPassData(fromDate: Date, toDate: Date)
}

class DateSelectViewController: UIViewController {
    
    @IBOutlet weak var koyomiContainer: UIStackView!
    fileprivate let invalidPeriodLength = 90

    @IBOutlet weak var currentDateLabel: UILabel!
    var koyomi = Koyomi(frame: CGRect(x: 0, y: 0, width: 0, height: 0), sectionSpace: 0, cellSpace: 0, inset: .zero, weekCellHeight: 40)
    var fromDate = Date()
    var toDate = Date()
    var isSelectedDate = false
    weak var delegate: SelectDateDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
       
        let frame = CGRect(x: 0, y : 0, width: koyomiContainer.frame.width, height: koyomiContainer.frame.width*0.8)
        koyomi = Koyomi(frame: frame, sectionSpace: 0, cellSpace: 0, inset: .zero, weekCellHeight: 40)
        koyomiContainer.addSubview(koyomi)
        currentDateLabel.text = koyomi.currentDateString(withFormat: "MMMM yyyy")

        koyomi.calendarDelegate = self
        koyomi.inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        koyomi.weeks = ("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat")
        koyomi.style = .standard
        koyomi.dayPosition = .center
        koyomi.selectionMode = .sequence(style: .circle)
        koyomi.selectedStyleColor = UIColor(red: 203/255, green: 119/255, blue: 223/255, alpha: 1)
        koyomi
            .setDayFont(size: 16)
            .setWeekFont(size: 18)
    }
    
    @IBAction func ApplyDateSelection(_ sender: UIButton) {
        if isSelectedDate {
            delegate?.didPassData(fromDate: self.fromDate, toDate: self.toDate)
        }
        let transition = CATransition()
        transition.duration = 0.5 // Set animation duration
        transition.type = CATransitionType.push // Set transition type to push
        transition.subtype = CATransitionSubtype.fromLeft // Set transition subtype to from right
        self.view.window?.layer.add(transition, forKey: kCATransition) // Add transition to window layer
        self.dismiss(animated: true)
    }
    @IBAction func prevMonth(_ sender: UIButton) {
        let month: MonthType = {
            return .previous
        }()
        self.koyomi.display(in: month)
    }
    @IBAction func nextMonth(_ sender: UIButton) {
        let month: MonthType = {
            return .next
        }()
        self.koyomi.display(in: month)
    }
   
    @IBAction func ClearDateSelection(_ sender: UIButton) {
        koyomi.unselectAll()
        koyomi.reloadData()
    }
    @IBAction func GoBack(_ sender: UITapGestureRecognizer) {
        let transition = CATransition()
        transition.duration = 0.5 // Set animation duration
        transition.type = CATransitionType.push // Set transition type to push
        transition.subtype = CATransitionSubtype.fromLeft // Set transition subtype to from right
        self.view.window?.layer.add(transition, forKey: kCATransition) // Add transition to window layer
        self.dismiss(animated: true)
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
// MARK: - KoyomiDelegate -
extension DateSelectViewController: KoyomiDelegate {
    func koyomi(_ koyomi: Koyomi, didSelect date: Date?, forItemAt indexPath: IndexPath) {
        print("You Selected: \(date ?? Date())")
    }
    
    func koyomi(_ koyomi: Koyomi, currentDateString dateString: String) {
        currentDateLabel.text = koyomi.currentDateString(withFormat: "MMMM yyyy")
    }
    
    @objc(koyomi:shouldSelectDates:to:withPeriodLength:)
    func koyomi(_ koyomi: Koyomi, shouldSelectDates date: Date?, to toDate: Date?, withPeriodLength length: Int) -> Bool {
        if length > invalidPeriodLength, date == nil {
            print("More than \(invalidPeriodLength) days are invalid period.")
            return false
        }
        isSelectedDate = true
        if toDate != nil {
            self.fromDate = date!
            self.toDate = toDate!
        }
        else{
            self.fromDate = date!
            self.toDate = date!
        }
        
        return true
    }
}
