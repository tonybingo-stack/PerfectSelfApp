
//  ActorBookAppointmentViewController.swift
//  PerfectSelf
//
//  Created by user232392 on 3/21/23.
//  Copyright © 2023 Stas Seldin. All rights reserved.
//

import UIKit

class ActorResheduleViewController: UIViewController {
    var rUid: String = ""
    var rName: String = ""
    var bookId = 0
    var selectedDate: String = ""
    
    var timeSlotList = [TimeSlot]()
    let backgroundView = UIView()
    let timeFormatter = DateFormatter()
    let dateFormatter = DateFormatter()

    @IBOutlet weak var picker_date: UIDatePicker!
    @IBOutlet weak var view_main: UIStackView!
    
    @IBOutlet weak var btn_15min: UIButton!
    @IBOutlet weak var btn_30min: UIButton!
    @IBOutlet weak var btn_60min: UIButton!
    @IBOutlet weak var btn_standby: UIButton!
    
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
    
    var btn2TimeMap:Dictionary<UIButton, Int> = [:]
    var timeBtnAry: [UIButton] = []
    
    var sessionDuration = -1
    var startTime = -1
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btn2TimeMap[btn_9am] = 9;timeBtnAry.append(btn_9am)
        btn2TimeMap[btn_10am] = 10;timeBtnAry.append(btn_10am)
        btn2TimeMap[btn_11am] = 11;timeBtnAry.append(btn_11am)
        btn2TimeMap[btn_12pm] = 12;timeBtnAry.append(btn_12pm)
        btn2TimeMap[btn_1pm] = 13;timeBtnAry.append(btn_1pm)
        btn2TimeMap[btn_2pm] = 14;timeBtnAry.append(btn_2pm)
        btn2TimeMap[btn_3pm] = 15;timeBtnAry.append(btn_3pm)
        btn2TimeMap[btn_4pm] = 16;timeBtnAry.append(btn_4pm)
        btn2TimeMap[btn_5pm] = 17;timeBtnAry.append(btn_5pm)
        btn2TimeMap[btn_6pm] = 18;timeBtnAry.append(btn_6pm)
        btn2TimeMap[btn_7pm] = 19;timeBtnAry.append(btn_7pm)
        btn2TimeMap[btn_8pm] = 20;timeBtnAry.append(btn_8pm)
        btn2TimeMap[btn_9pm] = 21;timeBtnAry.append(btn_9pm)
        btn2TimeMap[btn_10pm] = 22;timeBtnAry.append(btn_10pm)

        // Do any additional setup after loading the view.
        view_main.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        timeFormatter.dateFormat = "hh:mm a"
        dateFormatter.dateFormat = "yyyy-MM-dd"

        // call api for reader details
        showIndicator(sender: nil, viewController: self)
        webAPI.getReaderById(id:rUid) { data, response, error in
            DispatchQueue.main.async {
                hideIndicator(sender: nil)
            }
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            do {
                let item = try JSONDecoder().decode(ReaderProfileDetail.self, from: data)
                DispatchQueue.main.async {
                    self.timeSlotList.removeAll()
                    
                    for availibility in item.allAvailability {
                        let df = DateFormatter()
                        df.dateFormat = "yyyy-MM-dd"
                        let tf = DateFormatter()
                        tf.dateFormat = "HH"
                        
                        let index = self.timeSlotList.firstIndex(where: { df.string(from: Date.getDateFromString(date: $0.date)!) == df.string(from: Date.getDateFromString(date: utcToLocal(dateStr: availibility.date)!)!) })
                        if index == nil {
                            self.timeSlotList.append(TimeSlot(date: utcToLocal(dateStr: availibility.date)!, time: [Slot](), repeatFlag: 0, isStandBy: false))
                        }
                        let idx = index ?? self.timeSlotList.count - 1
                        
                        let t = tf.string(from:Date.getDateFromString(date:  utcToLocal(dateStr: availibility.fromTime)!)!)
                        let slot = time2slotNo(t)
                        self.timeSlotList[idx].time.append(Slot(id: 0, slot: slot, duration: 0, isDeleted: false))
                    }
                    self.timeSlotList = self.timeSlotList.sorted(by: { Date.getDateFromString(date: $0.date)! < Date.getDateFromString(date: $1.date)! })
                    
                    if !self.selectedDate.isEmpty {
                        self.picker_date.setDate(Date.getDateFromString(date: self.selectedDate) ?? Date(), animated: true)
                        self.displayTimeSlotsForDate(d: Date.getDateFromString(date: self.selectedDate) ?? Date())
                    }
                    else {
                        self.displayTimeSlotsForDate(d: self.picker_date.date)
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
    
    @IBAction func ChangeSelectedDate(_ sender: UIDatePicker) {
        displayTimeSlotsForDate(d: sender.date)
    }
    func displayTimeSlotsForDate(d: Date) {
        initTimeSlotState(isEnabled: false)
        let idx = getTimeSlotObjectIndex(d: d)
        if idx < 0 {
            return
        }
        let item = timeSlotList[idx]
        if item.isStandBy {
            initTimeSlotState(isEnabled: true)
        }
        for t in item.time {
            timeBtnAry[t.slot-1].isHighlighted = false
            timeBtnAry[t.slot-1].isEnabled = true
        }
    }
    func getTimeSlotObjectIndex(d: Date) -> Int {
        
        let index = timeSlotList.firstIndex(where: { dateFormatter.string(from: Date.getDateFromString(date: $0.date)!) == dateFormatter.string(from: d) })

        return index ?? -1
    }
    
    func initTimeSlotState(isEnabled: Bool) {
        for (key, _) in btn2TimeMap
        {
            //print("(\(btn2TimeMap[key]!) : \(val))")
            key.isHighlighted = !isEnabled
            key.isEnabled = isEnabled
        }
    }
    
    @IBAction func Select15Min(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        btn_30min.isSelected = false
        btn_60min.isSelected = false
        btn_standby.isSelected = false
        if sender.isSelected {
            sessionDuration = 1
            btn_15min.backgroundColor = UIColor.black
            btn_30min.backgroundColor = UIColor.white
            btn_60min.backgroundColor = UIColor.white
            btn_standby.backgroundColor = UIColor.white
        }
        else {
            sessionDuration = -1
            sender.backgroundColor = UIColor.white
        }
    }
    @IBAction func Select30Min(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        btn_15min.isSelected = false
        btn_60min.isSelected = false
        btn_standby.isSelected = false
        if sender.isSelected {
            sessionDuration = 2
            btn_15min.backgroundColor = UIColor.white
            btn_30min.backgroundColor = UIColor.black
            btn_60min.backgroundColor = UIColor.white
            btn_standby.backgroundColor = UIColor.white
        }
        else {
            sessionDuration = -1
            sender.backgroundColor = UIColor.white
        }
    }
    @IBAction func Select60Min(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        btn_15min.isSelected = false
        btn_30min.isSelected = false
        btn_standby.isSelected = false
        if sender.isSelected {
            sessionDuration = 3
            btn_15min.backgroundColor = UIColor.white
            btn_30min.backgroundColor = UIColor.white
            btn_60min.backgroundColor = UIColor.black
            btn_standby.backgroundColor = UIColor.white
        }
        else {
            sessionDuration = -1
            sender.backgroundColor = UIColor.white
        }
    }
    
    @IBAction func SelectStandbyDidTap(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        btn_15min.isSelected = false
        btn_30min.isSelected = false
        btn_60min.isSelected = false
        if sender.isSelected {
            sessionDuration = 4
            btn_15min.backgroundColor = UIColor.white
            btn_30min.backgroundColor = UIColor.white
            btn_60min.backgroundColor = UIColor.white
            btn_standby.backgroundColor = UIColor.black
        }
        else {
            sessionDuration = -1
            sender.backgroundColor = UIColor.white
        }
    }
    
    @IBAction func Select9Am(_ sender: UIButton) {
        timeButtonTap(sender: sender, timeVal: 1)
    }
    
    @IBAction func Select10Am(_ sender: UIButton) {
        timeButtonTap(sender: sender, timeVal: 2)
    }
    
    @IBAction func Select11Am(_ sender: UIButton) {
        timeButtonTap(sender: sender, timeVal: 3)
    }
    
    @IBAction func Select12PmDidTap(_ sender: UIButton) {
        timeButtonTap(sender: sender, timeVal: 4)
    }
    
    @IBAction func Select1PmDidTap(_ sender: UIButton) {
        timeButtonTap(sender: sender, timeVal: 5)
    }
    
    @IBAction func Select2Pm(_ sender: UIButton) {
        timeButtonTap(sender: sender, timeVal: 6)
    }
    
    @IBAction func Select3Pm(_ sender: UIButton) {
        timeButtonTap(sender: sender, timeVal: 7)
    }
    
    @IBAction func Select4Pm(_ sender: UIButton) {
        timeButtonTap(sender: sender, timeVal: 8)
    }
    
    @IBAction func Select5Pm(_ sender: UIButton) {
        timeButtonTap(sender: sender, timeVal: 9)
    }
    
    @IBAction func Select6Pm(_ sender: UIButton) {
        timeButtonTap(sender: sender, timeVal: 10)
    }
    
    @IBAction func Select7Pm(_ sender: UIButton) {
        timeButtonTap(sender: sender, timeVal: 11)
    }
    
    @IBAction func Select8Pm(_ sender: UIButton) {
        timeButtonTap(sender: sender, timeVal: 12)
    }
    
    @IBAction func Select9Pm(_ sender: UIButton) {
        timeButtonTap(sender: sender, timeVal: 13)
    }
    
    @IBAction func Select10Pm(_ sender: UIButton) {
        timeButtonTap(sender: sender, timeVal: 14)
    }
    
    @IBAction func ConfirmReschedule(_ sender: UIButton) {
        // check if session selected
        if sessionDuration < 0 || startTime < 0 {
            showAlert(viewController: self, title: "Confirm", message: "Please select session to continue") { UIAlertAction in
                           return
            }
        }

        let bookingDate = dateFormatter.string(from: picker_date.date)
        let fromTime = "\(bookingDate)\(availableTime[ startTime-1 ]):00:00"
        let toTime = "\(bookingDate)\(availableTime[ startTime-1 ]):\(availableDuration[sessionDuration-1]):00"
        
        // call reschedule API and go back
        showIndicator(sender: nil, viewController: self)
        webAPI.rescheduleBooking(id: bookId, bookStartTime: fromTime, bookEndTime: toTime) { data, response, error in
            DispatchQueue.main.async {
                hideIndicator(sender: nil);
            }
            guard let _ = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                DispatchQueue.main.async {
                    Toast.show(message: "Error while rescheduling..., try again later", controller: self)
                }
               
                return
            }
            DispatchQueue.main.async {
                Toast.show(message: "Booking rescheduled!", controller: self)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        // do stuff 1 seconds later
                    let transition = CATransition()
                    transition.duration = 0.5 // Set animation duration
                    transition.type = CATransitionType.push // Set transition type to push
                    transition.subtype = CATransitionSubtype.fromLeft // Set transition subtype to from right
                    self.view.window?.layer.add(transition, forKey: kCATransition) // Add transition to window layer
                    self.dismiss(animated: false)
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
    
    func timeButtonTap( sender: UIButton, timeVal: Int ){
        sender.isSelected = !sender.isSelected
        
        for (btn, _) in btn2TimeMap
        {
            if btn == sender { continue }
            btn.isSelected = false
        }
        
        if sender.isSelected {
            startTime = timeVal
            
            for (btn, _) in btn2TimeMap
            {
                if btn == sender {//Select color if this button
                    btn.backgroundColor = UIColor.black
                }
                else{//Otherwise, clear color with white
                    btn.backgroundColor = UIColor.white
                }
            }
        }
        else {
            startTime = -1
            sender.backgroundColor = UIColor.white
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
