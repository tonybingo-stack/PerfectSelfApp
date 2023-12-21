//
//  ReaderProfileEditAvailabilityViewController.swift
//  PerfectSelf
//
//  Created by Kayan Mishra on 3/8/23.
//  Copyright © 2023 Stas Seldin. All rights reserved.
//

import UIKit
import DropDown

class ReaderProfileEditAvailabilityViewController: UIViewController {
    
    var uid : String = ""
    @IBOutlet weak var picker_date: UIDatePicker!

    let dateFormatter = DateFormatter()
    let timeFormatter = DateFormatter()
    @IBOutlet weak var btn_9am: UIButton!
    @IBOutlet weak var btn_10am: UIButton!
    @IBOutlet weak var btn_11am: UIButton!
    @IBOutlet weak var btn_12pm: UIButton!
    @IBOutlet weak var btn_1pm: UIButton!
    @IBOutlet weak var btn_2pm: UIButton!
    @IBOutlet weak var btn_3pm: UIButton!
    @IBOutlet weak var btn_4pm: UIButton!
    @IBOutlet weak var btn_5pm: UIButton!
    @IBOutlet weak var btn_6pm: UIButton!
    @IBOutlet weak var btn_7pm: UIButton!
    @IBOutlet weak var btn_8pm: UIButton!
    @IBOutlet weak var btn_9pm: UIButton!
    @IBOutlet weak var btn_10pm: UIButton!
    
    @IBOutlet weak var btn_standby_yes: UIButton!
    @IBOutlet weak var btn_standby_no: UIButton!
    @IBOutlet weak var text_repeat: UITextField!
    @IBOutlet weak var repeatView: UIStackView!
    var repeatFlag = 0
    var startTime = -1
    let dropDownForRepeat = DropDown()
    var timeSlotList = [TimeSlot]()
    
    var timeBtnAry: [UIButton] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timeBtnAry.append(btn_9am)
        timeBtnAry.append(btn_10am)
        timeBtnAry.append(btn_11am)
        timeBtnAry.append(btn_12pm)
        timeBtnAry.append(btn_1pm)
        timeBtnAry.append(btn_2pm)
        timeBtnAry.append(btn_3pm)
        timeBtnAry.append(btn_4pm)
        timeBtnAry.append(btn_5pm)
        timeBtnAry.append(btn_6pm)
        timeBtnAry.append(btn_7pm)
        timeBtnAry.append(btn_8pm)
        timeBtnAry.append(btn_9pm)
        timeBtnAry.append(btn_10pm)

        // Do any additional setup after loading the view.
        dateFormatter.dateFormat = "yyyy-MM-dd"
        timeFormatter.dateFormat = "hh:mm"
        dropDownForRepeat.anchorView = repeatView
        dropDownForRepeat.dataSource = ["No", "Every Day", "Every Week", "Every Month"]
        dropDownForRepeat.selectionAction = { [unowned self] (index: Int, item: String) in
            text_repeat.text = item
            repeatFlag = index
            let id = getTimeSlotObjectIndex(d: picker_date.date)
            timeSlotList[id].repeatFlag = index
        }
        // Top of drop down will be below the anchorView
        dropDownForRepeat.bottomOffset = CGPoint(x: 0, y:(dropDownForRepeat.anchorView?.plainView.bounds.height)!)
        
        dropDownForRepeat.dismissMode = .onTap
        
        DropDown.startListeningToKeyboard()
        DropDown.appearance().textColor = UIColor.black
        DropDown.appearance().selectedTextColor = UIColor.link
        DropDown.appearance().textFont = UIFont.systemFont(ofSize: 15)
        DropDown.appearance().backgroundColor = UIColor.white
        DropDown.appearance().selectionBackgroundColor = UIColor.lightGray
        DropDown.appearance().cellHeight = 40
        DropDown.appearance().setupCornerRadius(5) // available since v2.3.6
        
        displayTimeSlotsForDate(d: Date())
    }
    
    @IBAction func showDropDown(_ sender: UITapGestureRecognizer) {
        dropDownForRepeat.show()
    }
    
    @IBAction func SelectedDateChanged(_ sender: UIDatePicker) {
        displayTimeSlotsForDate(d: sender.date)
    }
    
    func displayTimeSlotsForDate(d: Date) {
        let item = timeSlotList[getTimeSlotObjectIndex(d: d)]
        initTimeSlotState()
        if item.isStandBy {
            btn_standby_no.isSelected = false
            btn_standby_yes.isSelected = true
        }
        dropDownForRepeat.selectRow(item.repeatFlag)
        
        for t in item.time {
            if (t.slot < 1) {
                continue
            }
            
//            timeBtnAry[t.slot-1].isHighlighted = false
//            timeBtnAry[t.slot-1].isEnabled = true
            timeBtnAry[t.slot-1].backgroundColor = UIColor.black
            timeBtnAry[t.slot-1].isSelected = true
        }
    }
    
    func getTimeSlotObjectIndex(d: Date) -> Int {
        
        let index = timeSlotList.firstIndex(where: { dateFormatter.string(from: Date.getDateFromString(date: $0.date)!) == dateFormatter.string(from: d) })
        if index == nil {
            timeSlotList.append(TimeSlot(date: Date.getStringFromDate(date: picker_date.date), time: [], repeatFlag: 0, isStandBy: false))
        }
        return index ?? timeSlotList.count - 1
    }
    
    func initTimeSlotState() {
        dropDownForRepeat.selectRow(0)
        repeatFlag = 0
        text_repeat.text = "No"
        
        btn_standby_no.isSelected = true
        btn_standby_yes.isSelected = false
        btn_9am.isSelected = false
        btn_10am.isSelected = false
        btn_11am.isSelected = false
        btn_12pm.isSelected = false
        btn_1pm.isSelected = false
        btn_2pm.isSelected = false
        btn_3pm.isSelected = false
        btn_4pm.isSelected = false
        btn_5pm.isSelected = false
        btn_6pm.isSelected = false
        btn_7pm.isSelected = false
        btn_8pm.isSelected = false
        btn_9pm.isSelected = false
        btn_10pm.isSelected = false
        
        btn_9am.backgroundColor = UIColor.white
        btn_10am.backgroundColor = UIColor.white
        btn_11am.backgroundColor = UIColor.white
        btn_12pm.backgroundColor = UIColor.white
        btn_1pm.backgroundColor = UIColor.white
        btn_2pm.backgroundColor = UIColor.white
        btn_3pm.backgroundColor = UIColor.white
        btn_4pm.backgroundColor = UIColor.white
        btn_5pm.backgroundColor = UIColor.white
        btn_6pm.backgroundColor = UIColor.white
        btn_7pm.backgroundColor = UIColor.white
        btn_8pm.backgroundColor = UIColor.white
        btn_9pm.backgroundColor = UIColor.white
        btn_10pm.backgroundColor = UIColor.white
    }
    
    @IBAction func SaveChanges(_ sender: UIButton) {
       // call API for save changes
        webAPI.updateAvailability(uid: uid, timeSlotList: timeSlotList) { data, response, error in
            guard let _ = data, error == nil else {
                DispatchQueue.main.async {
                    Toast.show(message: "Something went wrong!, try agian later.", controller: self)
                }
                return
            }
            DispatchQueue.main.async {
                Toast.show(message: "Availability Updated!", controller: self)
                self.GoBack(self.btn_4pm)
            }
        }
    }
    
    @IBAction func SelectStandByYes(_ sender: UIButton) {
        let index = getTimeSlotObjectIndex(d: picker_date.date)
        timeSlotList[index].isStandBy = true
        btn_standby_no.isSelected = false
        btn_standby_yes.isSelected = true
    }
    
    @IBAction func SelectStandByNo(_ sender: UIButton) {
        let index = getTimeSlotObjectIndex(d: picker_date.date)
        timeSlotList[index].isStandBy = false
        btn_standby_no.isSelected = true
        btn_standby_yes.isSelected = false
    }
    
    @IBAction func Select9Am(_ sender: UIButton) {
        clickedTimeSlot(btn: sender, slotNo: 1)
    }
    
    @IBAction func Select10Am(_ sender: UIButton) {
        clickedTimeSlot(btn: sender, slotNo: 2)
    }
    
    @IBAction func Select11Am(_ sender: UIButton) {
        clickedTimeSlot(btn: sender, slotNo: 3)
    }
    
    @IBAction func Select12PmDidTap(_ sender: UIButton) {
        clickedTimeSlot(btn: sender, slotNo: 4)
    }
    
    @IBAction func Select1PmDidTap(_ sender: UIButton) {
        clickedTimeSlot(btn: sender, slotNo: 5)
    }
    
    @IBAction func Select2Pm(_ sender: UIButton) {
        clickedTimeSlot(btn: sender, slotNo: 6)
    }
    
    @IBAction func Select3Pm(_ sender: UIButton) {
        clickedTimeSlot(btn: sender, slotNo: 7)
    }
    
    @IBAction func Select4Pm(_ sender: UIButton) {
        clickedTimeSlot(btn: sender, slotNo: 8)
    }
    
    @IBAction func Select5Pm(_ sender: UIButton) {
        clickedTimeSlot(btn: sender, slotNo: 9)
    }
    
    @IBAction func Select6Pm(_ sender: UIButton) {
        clickedTimeSlot(btn: sender, slotNo: 10)
    }
    
    @IBAction func Select7Pm(_ sender: UIButton) {
        clickedTimeSlot(btn: sender, slotNo: 11)
    }
    
    @IBAction func Select8Pm(_ sender: UIButton) {
        clickedTimeSlot(btn: sender, slotNo: 12)
    }
    
    @IBAction func Select9Pm(_ sender: UIButton) {
        clickedTimeSlot(btn: sender, slotNo: 13)
    }
    
    @IBAction func Select10Pm(_ sender: UIButton) {
        clickedTimeSlot(btn: sender, slotNo: 14)
    }
    
    @IBAction func GoBack(_ sender: UIButton) {
        let transition = CATransition()
        transition.duration = 0.5 // Set animation duration
        transition.type = CATransitionType.push // Set transition type to push
        transition.subtype = CATransitionSubtype.fromLeft // Set transition subtype to from right
        self.view.window?.layer.add(transition, forKey: kCATransition) //  Add transition to window layer
        self.dismiss(animated: true)
    }
    
    func clickedTimeSlot(btn: UIButton, slotNo: Int){
        btn.isSelected = !btn.isSelected
        let index = getTimeSlotObjectIndex(d: picker_date.date)
        let idx = timeSlotList[index].time.firstIndex(where: { $0.slot == slotNo })
        
        if btn.isSelected {
            if idx != nil {
                timeSlotList[index].time[idx!].isDeleted = false
            }
            else {
                timeSlotList[index].time.append(Slot(id: 0, slot: slotNo, duration: 0, isDeleted: false))
            }
            
            btn.backgroundColor = UIColor.black
        }
        else {
            timeSlotList[index].time[idx!].isDeleted = true
            btn.backgroundColor = UIColor.white
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
