//
//  FilterViewController.swift
//  PerfectSelf
//
//  Created by user232392 on 3/31/23.
//  Copyright © 2023 Stas Seldin. All rights reserved.
//

import UIKit
import RangeSeekSlider
protocol FilterDelegate {
    func fetchReadersWithFilter(viewController: UIViewController)
}

class FilterViewController: UIViewController, SelectDateDelegate {
    func didPassData(fromDate: Date, toDate: Date) {
        let df = DateFormatter()
        df.dateFormat = "MM/dd/yyyy"
        text_date_range.text = df.string(from: fromDate) + "-" + df.string(from: toDate)
        Filter["isDateSelected"] = true
        Filter["fromDate"] = fromDate
        Filter["toDate"] = toDate
    }
    var fd: FilterDelegate?
    var originType = 0
    
    var genderCheckAry: [UIButton] = [UIButton]()
    var parentUIViewController : UIViewController?
    
    @IBOutlet weak var maleGenderchk: UIButton!
    @IBOutlet weak var fmaleGenderChk: UIButton!
    @IBOutlet weak var nonBinGenderChk: UIButton!
    @IBOutlet weak var genderqueerGenderChk: UIButton!
    @IBOutlet weak var genderFluidGenChk: UIButton!
    @IBOutlet weak var transGenderChk: UIButton!
    @IBOutlet weak var agenderGenderChk: UIButton!
    @IBOutlet weak var bigGenderChk: UIButton!
    @IBOutlet weak var twoSpiritGenderChk: UIButton!
    @IBOutlet weak var androgynousGenderChk: UIButton!
    @IBOutlet weak var unkownGenderChk: UIButton!
    @IBOutlet weak var allGenderChk: UIButton!
    
    @IBOutlet weak var btn_availablesoon: UIButton!
    @IBOutlet weak var btn_onlinenow: UIButton!
    @IBOutlet weak var btn_standby: UIButton!
    @IBOutlet weak var btn_45min: UIButton!
    @IBOutlet weak var btn_30min: UIButton!
    @IBOutlet weak var btn_15min: UIButton!
    @IBOutlet weak var sliderView: UIStackView!
    @IBOutlet weak var btn_comercialread: UIButton!
    @IBOutlet weak var btn_shortread: UIButton!
    @IBOutlet weak var btn_extendedread: UIButton!
    
    @IBOutlet weak var btn_explicitChk: UIButton!
    @IBOutlet weak var text_date_range: UITextField!
    
    var rangeSlider : RangeSeekSlider = RangeSeekSlider(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        genderCheckAry.removeAll()
        genderCheckAry = [maleGenderchk, fmaleGenderChk, nonBinGenderChk, genderqueerGenderChk, genderFluidGenChk, transGenderChk, agenderGenderChk, bigGenderChk, twoSpiritGenderChk, androgynousGenderChk, unkownGenderChk]
        
        rangeSlider = RangeSeekSlider(frame: CGRect(x: 0, y: 0, width: sliderView.frame.width-35, height: sliderView.frame.height))
        sliderView.addSubview(rangeSlider)
        rangeSlider.minValue = 0
        rangeSlider.maxValue = 100
        rangeSlider.step = 1
        
        // initialize the state
        if (Filter["isAvailableSoon"] as! Bool) {
            btn_availablesoon.backgroundColor = UIColor(rgb: 0x4865FF)
            btn_availablesoon.setTitleColor(.white, for: .normal)
        }
        else {
            btn_availablesoon.backgroundColor = UIColor(rgb: 0xFFFFFF)
            btn_availablesoon.setTitleColor(UIColor(rgb: 0x4865FF), for: .normal)
        }
        if Filter["isOnlineNow"] as! Bool {
            btn_onlinenow.backgroundColor = UIColor(rgb: 0x4865FF)
            btn_onlinenow.setTitleColor(.white, for: .normal)
        }
        else {
            btn_onlinenow.backgroundColor = UIColor(rgb: 0xFFFFFF)
            btn_onlinenow.setTitleColor(UIColor(rgb: 0x4865FF), for: .normal)
        }
        let tType = Filter["timeSlotType"] as! Int
        if tType == 0 {
            btn_15min.backgroundColor = UIColor(rgb: 0x4865FF)
            btn_15min.setTitleColor(.white, for: .normal)
            btn_30min.backgroundColor = UIColor(rgb: 0xFFFFFF)
            btn_30min.setTitleColor(UIColor(rgb: 0x4865FF), for: .normal)
            btn_45min.backgroundColor = UIColor(rgb: 0xFFFFFF)
            btn_45min.setTitleColor(UIColor(rgb: 0x4865FF), for: .normal)
            btn_standby.backgroundColor = UIColor(rgb: 0xFFFFFF)
            btn_standby.setTitleColor(UIColor(rgb: 0x4865FF), for: .normal)
        } else if tType == 1 {
            btn_30min.backgroundColor = UIColor(rgb: 0x4865FF)
            btn_30min.setTitleColor(.white, for: .normal)
            btn_15min.backgroundColor = UIColor(rgb: 0xFFFFFF)
            btn_15min.setTitleColor(UIColor(rgb: 0x4865FF), for: .normal)
            btn_45min.backgroundColor = UIColor(rgb: 0xFFFFFF)
            btn_45min.setTitleColor(UIColor(rgb: 0x4865FF), for: .normal)
            btn_standby.backgroundColor = UIColor(rgb: 0xFFFFFF)
            btn_standby.setTitleColor(UIColor(rgb: 0x4865FF), for: .normal)
        }
        else if tType == 2 {
            btn_45min.backgroundColor = UIColor(rgb: 0x4865FF)
            btn_45min.setTitleColor(.white, for: .normal)
            btn_30min.backgroundColor = UIColor(rgb: 0xFFFFFF)
            btn_30min.setTitleColor(UIColor(rgb: 0x4865FF), for: .normal)
            btn_15min.backgroundColor = UIColor(rgb: 0xFFFFFF)
            btn_15min.setTitleColor(UIColor(rgb: 0x4865FF), for: .normal)
            btn_standby.backgroundColor = UIColor(rgb: 0xFFFFFF)
            btn_standby.setTitleColor(UIColor(rgb: 0x4865FF), for: .normal)
        } else if tType == 3 {
            btn_standby.backgroundColor = UIColor(rgb: 0x4865FF)
            btn_standby.setTitleColor(.white, for: .normal)
            btn_30min.backgroundColor = UIColor(rgb: 0xFFFFFF)
            btn_30min.setTitleColor(UIColor(rgb: 0x4865FF), for: .normal)
            btn_45min.backgroundColor = UIColor(rgb: 0xFFFFFF)
            btn_45min.setTitleColor(UIColor(rgb: 0x4865FF), for: .normal)
            btn_15min.backgroundColor = UIColor(rgb: 0xFFFFFF)
            btn_15min.setTitleColor(UIColor(rgb: 0x4865FF), for: .normal)
        }
        else {
            Toast.show(message: "Unknown TypeSlot Type", controller: self)
        }
        
        if (Filter["isDateSelected"] as! Bool) {
            let df = DateFormatter()
            df.dateFormat = "MM/dd/yyyy"
            let fromDate = Filter["fromDate"] as! Date
            let toDate = Filter["toDate"] as! Date
            text_date_range.text = df.string(from: fromDate) + "-" + df.string(from: toDate)
        }
        rangeSlider.selectedMinValue = CGFloat(Filter["priceMinVal"] as! Int)
        rangeSlider.selectedMaxValue = CGFloat(Filter["priceMaxVal"] as! Int)
        
        maleGenderchk.isSelected = Filter["isMale"] as! Bool
        fmaleGenderChk.isSelected = Filter["isFemale"] as! Bool
        nonBinGenderChk.isSelected = Filter["isNonBinary"] as! Bool
        genderqueerGenderChk.isSelected = Filter["isGenderqueer"] as! Bool
        genderFluidGenChk.isSelected = Filter["isGenderfluid"] as! Bool
        transGenderChk.isSelected = Filter["isTransgender"] as! Bool
        agenderGenderChk.isSelected = Filter["isAgender"] as! Bool
        bigGenderChk.isSelected = Filter["isBigender"] as! Bool
        twoSpiritGenderChk.isSelected = Filter["isTwoSpirit"] as! Bool
        androgynousGenderChk.isSelected = Filter["isAndrogynous"] as! Bool
        unkownGenderChk.isSelected = Filter["isUnknown"] as! Bool
        allGenderChk.isSelected = Filter["isAll"] as! Bool
        if (Filter["isCommercialRead"] as! Bool) {
            btn_comercialread.backgroundColor = UIColor(rgb: 0x4865FF)
            btn_comercialread.setTitleColor(.white, for: .normal)
            btn_comercialread.tintColor = .white
        }
        else {
            btn_comercialread.backgroundColor = UIColor(rgb: 0xFFFFFF)
            btn_comercialread.setTitleColor(UIColor(rgb: 0x4865FF), for: .normal)
            btn_comercialread.tintColor = UIColor(rgb: 0x4865FF)
        }
        if (Filter["isShortRead"] as! Bool) {
            btn_shortread.backgroundColor = UIColor(rgb: 0x4865FF)
            btn_shortread.setTitleColor(.white, for: .normal)
            btn_shortread.tintColor = .white
        }
        else {
            btn_shortread.backgroundColor = UIColor(rgb: 0xFFFFFF)
            btn_shortread.setTitleColor(UIColor(rgb: 0x4865FF), for: .normal)
            btn_shortread.tintColor = UIColor(rgb: 0x4865FF)
        }
        if (Filter["isExtendedRead"] as! Bool) {
            btn_extendedread.backgroundColor = UIColor(rgb: 0x4865FF)
            btn_extendedread.setTitleColor(.white, for: .normal)
            btn_extendedread.tintColor = .white
        }
        else {
            btn_extendedread.backgroundColor = UIColor(rgb: 0xFFFFFF)
            btn_extendedread.setTitleColor(UIColor(rgb: 0x4865FF), for: .normal)
            btn_extendedread.tintColor = UIColor(rgb: 0x4865FF)
        }
        btn_explicitChk.isSelected = Filter["isExplicitRead"] as! Bool
    }
    @IBAction func tapCallback(_ sender: UITapGestureRecognizer) {
          self.dismiss(animated: true);
      }

    @IBAction func tapSelectAvailableDate(_ sender: UITapGestureRecognizer) {
        let controller = DateSelectViewController()
        controller.delegate = self
        controller.modalPresentationStyle = .fullScreen
        let transition = CATransition()
        transition.duration = 0.5 // Set animation duration
        transition.type = CATransitionType.push // Set transition type to push
        transition.subtype = CATransitionSubtype.fromRight // Set transition subtype to from right
        self.view.window?.layer.add(transition, forKey: kCATransition) // Add transition to window layer
        self.present(controller, animated: false, completion: nil)
    }
    
    @IBAction func ApplyFilter(_ sender: UIButton) {
        Filter["priceMinVal"] = Int(rangeSlider.selectedMinValue)
        Filter["priceMaxVal"] = Int(rangeSlider.selectedMaxValue)
        
        self.dismiss(animated: true) {
            if self.originType == 0 {
                let controller = ActorFindReaderViewController()
                
//                controller.isAvailableSoon = self.isAvailableSoon
//                controller.isOnline = self.isOnline
//                controller.timeSlotType = self.timeSlotType
//                controller.isDateSelected = self.isDateSelected
//                controller.fromDate = self.fromDate
//                controller.toDate = self.toDate
//                controller.minPrice = Float(self.rangeSlider.selectedMinValue)
//                controller.maxPrice = Float(self.rangeSlider.selectedMaxValue)
//                controller.gender = self.getSelectedGenderAry()
//                controller.isCommercialRead = self.isCommercialRead
//                controller.isShortRead = self.isShortRead
//                controller.isExtendedRead = self.isExtendedRead
//                controller.isComfortableWithExplicitRead = self.isExplicitRead
                
                self.parentUIViewController?.navigationController?.pushViewController(controller, animated: true)
            }
            else {
                // call delegate
                self.fd?.fetchReadersWithFilter(viewController: self)
            }
        }
    }
    
    @IBAction func SelectMale(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        //isMaleSelected = !isMaleSelected
        Filter["isMale"] = sender.isSelected
    }
    
    @IBAction func SelectFemale(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        //isFemaleSelected = !isFemaleSelected
        Filter["isFemale"] = sender.isSelected
    }
    
    @IBAction func nonBinaryDidTap(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        Filter["isNonBinary"] = sender.isSelected
    }
    
    @IBAction func GenderqueerDidTap(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        Filter["isGenderqueer"] = sender.isSelected
    }
    
    @IBAction func genderfluidDidTap(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        Filter["isGenderfluid"] = sender.isSelected
    }
    
    @IBAction func transgenderDidTap(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        Filter["isTransgender"] = sender.isSelected
    }
    
    @IBAction func agenderDidTap(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        Filter["isAgender"] = sender.isSelected
    }
    
    @IBAction func bigenderDidTap(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        Filter["isBigender"] = sender.isSelected
    }
    
    @IBAction func twoSpiritDidTap(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        Filter["isTwoSpirit"] = sender.isSelected
    }
    
    @IBAction func androgynousDidTap(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        Filter["isAndrogynous"] = sender.isSelected
    }
    
    @IBAction func unkownDidTap(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        Filter["isUnknown"] = sender.isSelected
    }
    
    @IBAction func allGenderDidTap(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        maleGenderchk.isSelected = sender.isSelected
        fmaleGenderChk.isSelected = sender.isSelected
        nonBinGenderChk.isSelected = sender.isSelected
        genderqueerGenderChk.isSelected = sender.isSelected
        genderFluidGenChk.isSelected = sender.isSelected
        transGenderChk.isSelected = sender.isSelected
        agenderGenderChk.isSelected = sender.isSelected
        bigGenderChk.isSelected = sender.isSelected
        twoSpiritGenderChk.isSelected = sender.isSelected
        androgynousGenderChk.isSelected = sender.isSelected
        unkownGenderChk.isSelected = sender.isSelected
        allGenderChk.isSelected = sender.isSelected
        
        Filter["isAll"] = sender.isSelected
        Filter["isMale"] = sender.isSelected
        Filter["isFemale"] = sender.isSelected
        Filter["isNonBinary"] = sender.isSelected
        Filter["isGenderqueer"] = sender.isSelected
        Filter["isGenderfluid"] = sender.isSelected
        Filter["isTransgender"] = sender.isSelected
        Filter["isAgender"] = sender.isSelected
        Filter["isBigender"] = sender.isSelected
        Filter["isTwoSpirit"] = sender.isSelected
        Filter["isAndrogynous"] = sender.isSelected
        Filter["isUnknown"] = sender.isSelected
    }
    
    @IBAction func CloseFilterModal(_ sender: UIButton) {
        // Initialize the Filter state
        Filter["isAvailableSoon"] = false
        Filter["isOnlineNow"] = true
        Filter["timeSlotType"] = 0
        Filter["isDateSelected"] = false
        Filter["fromDate"] = Date()
        Filter["toDate"] = Date()
        Filter["priceMinVal"] = 0
        Filter["priceMaxVal"] = 0
        Filter["isMale"] = false
        Filter["isFemale"] = false
        Filter["isNonBinary"] = false
        Filter["isGenderqueer"] = false
        Filter["isGenderfluid"] = false
        Filter["isTransgender"] = false
        Filter["isAgender"] = false
        Filter["isBigender"] = false
        Filter["isTwoSpirit"] = false
        Filter["isAndrogynous"] = false
        Filter["isUnknown"] = false
        Filter["isAll"] = false
        Filter["isCommercialRead"] = true
        Filter["isShortRead"] = false
        Filter["isExtendedRead"] = false
        Filter["isExplicitRead"] = false

        btn_onlinenow.backgroundColor = UIColor(rgb: 0x4865FF)
        btn_onlinenow.setTitleColor(.white, for: .normal)
        btn_availablesoon.backgroundColor = UIColor(rgb: 0xFFFFFF)
        btn_availablesoon.setTitleColor(UIColor(rgb: 0x4865FF), for: .normal)
        btn_15min.backgroundColor = UIColor(rgb: 0x4865FF)
        btn_15min.setTitleColor(.white, for: .normal)
        btn_30min.backgroundColor = UIColor(rgb: 0xFFFFFF)
        btn_30min.setTitleColor(UIColor(rgb: 0x4865FF), for: .normal)
        btn_45min.backgroundColor = UIColor(rgb: 0xFFFFFF)
        btn_45min.setTitleColor(UIColor(rgb: 0x4865FF), for: .normal)
        btn_standby.backgroundColor = UIColor(rgb: 0xFFFFFF)
        btn_standby.setTitleColor(UIColor(rgb: 0x4865FF), for: .normal)
        text_date_range.text = ""
        rangeSlider.selectedMinValue = 0
        rangeSlider.selectedMaxValue = 100

        maleGenderchk.isSelected = false
        fmaleGenderChk.isSelected = false
        nonBinGenderChk.isSelected = false
        genderqueerGenderChk.isSelected = false
        genderFluidGenChk.isSelected = false
        transGenderChk.isSelected = false
        agenderGenderChk.isSelected = false
        bigGenderChk.isSelected = false
        twoSpiritGenderChk.isSelected = false
        androgynousGenderChk.isSelected = false
        unkownGenderChk.isSelected = false
        allGenderChk.isSelected = false
        btn_comercialread.backgroundColor = UIColor(rgb: 0x4865FF)
        btn_comercialread.setTitleColor(.white, for: .normal)
        btn_shortread.backgroundColor = UIColor(rgb: 0xFFFFFF)
        btn_shortread.setTitleColor(UIColor(rgb: 0x4865FF), for: .normal)
        btn_extendedread.backgroundColor = UIColor(rgb: 0xFFFFFF)
        btn_extendedread.setTitleColor(UIColor(rgb: 0x4865FF), for: .normal)
        btn_explicitChk.isSelected = false
    }
    @IBAction func SelectOnlineNow(_ sender: UIButton) {
        Filter["isOnlineNow"] = !(Filter["isOnlineNow"] as! Bool)
        
        if Filter["isOnlineNow"] as! Bool {
            sender.backgroundColor = UIColor(rgb: 0x4865FF)
            sender.setTitleColor(.white, for: .normal)
            
        }
        else {
            sender.backgroundColor = UIColor(rgb: 0xFFFFFF)
            sender.setTitleColor(UIColor(rgb: 0x4865FF), for: .normal)
        }
    }
    
    @IBAction func SelectAvailableSoon(_ sender: UIButton) {
        Filter["isAvailableSoon"] = !(Filter["isAvailableSoon"] as! Bool)
        if (Filter["isAvailableSoon"] as! Bool) {
            sender.backgroundColor = UIColor(rgb: 0x4865FF)
            sender.setTitleColor(.white, for: .normal)
            
        }
        else {
            sender.backgroundColor = UIColor(rgb: 0xFFFFFF)
            sender.setTitleColor(UIColor(rgb: 0x4865FF), for: .normal)
        }
    }
    
    @IBAction func Select15TimeSlot(_ sender: UIButton) {
        Filter["timeSlotType"] = 0
        
        sender.backgroundColor = UIColor(rgb: 0x4865FF)
        sender.setTitleColor(.white, for: .normal)
        
        btn_30min.backgroundColor = UIColor(rgb: 0xFFFFFF)
        btn_30min.setTitleColor(UIColor(rgb: 0x4865FF), for: .normal)
        btn_45min.backgroundColor = UIColor(rgb: 0xFFFFFF)
        btn_45min.setTitleColor(UIColor(rgb: 0x4865FF), for: .normal)
        btn_standby.backgroundColor = UIColor(rgb: 0xFFFFFF)
        btn_standby.setTitleColor(UIColor(rgb: 0x4865FF), for: .normal)
    }
    
    @IBAction func Select30TimeSlot(_ sender: UIButton) {
        Filter["timeSlotType"] = 1
        
        sender.backgroundColor = UIColor(rgb: 0x4865FF)
        sender.setTitleColor(.white, for: .normal)
        
        btn_15min.backgroundColor = UIColor(rgb: 0xFFFFFF)
        btn_15min.setTitleColor(UIColor(rgb: 0x4865FF), for: .normal)
        btn_45min.backgroundColor = UIColor(rgb: 0xFFFFFF)
        btn_45min.setTitleColor(UIColor(rgb: 0x4865FF), for: .normal)
        btn_standby.backgroundColor = UIColor(rgb: 0xFFFFFF)
        btn_standby.setTitleColor(UIColor(rgb: 0x4865FF), for: .normal)
    }
    
    @IBAction func Select45OverTimeSlot(_ sender: UIButton) {
        Filter["timeSlotType"] = 2
        
        sender.backgroundColor = UIColor(rgb: 0x4865FF)
        sender.setTitleColor(.white, for: .normal)
        
        btn_15min.backgroundColor = UIColor(rgb: 0xFFFFFF)
        btn_15min.setTitleColor(UIColor(rgb: 0x4865FF), for: .normal)
        btn_30min.backgroundColor = UIColor(rgb: 0xFFFFFF)
        btn_30min.setTitleColor(UIColor(rgb: 0x4865FF), for: .normal)
        btn_standby.backgroundColor = UIColor(rgb: 0xFFFFFF)
        btn_standby.setTitleColor(UIColor(rgb: 0x4865FF), for: .normal)
    }
    
    @IBAction func SelectStandByTimeSlot(_ sender: UIButton) {
        Filter["timeSlotType"] = 3
        
        sender.backgroundColor = UIColor(rgb: 0x4865FF)
        sender.setTitleColor(.white, for: .normal)
        
        btn_15min.backgroundColor = UIColor(rgb: 0xFFFFFF)
        btn_15min.setTitleColor(UIColor(rgb: 0x4865FF), for: .normal)
        btn_30min.backgroundColor = UIColor(rgb: 0xFFFFFF)
        btn_30min.setTitleColor(UIColor(rgb: 0x4865FF), for: .normal)
        btn_45min.backgroundColor = UIColor(rgb: 0xFFFFFF)
        btn_45min.setTitleColor(UIColor(rgb: 0x4865FF), for: .normal)
    }
    
    @IBAction func SelectCommercialRead(_ sender: UIButton) {
        Filter["isCommercialRead"] = !(Filter["isCommercialRead"] as! Bool)
        
        if (Filter["isCommercialRead"] as! Bool) {
            sender.backgroundColor = UIColor(rgb: 0x4865FF)
            sender.setTitleColor(.white, for: .normal)
            sender.tintColor = .white
        }
        else {
            sender.backgroundColor = UIColor(rgb: 0xFFFFFF)
            sender.setTitleColor(UIColor(rgb: 0x4865FF), for: .normal)
            sender.tintColor = UIColor(rgb: 0x4865FF)
        }
    }
    
    @IBAction func SelectShortRead(_ sender: UIButton) {
        Filter["isShortRead"] = !(Filter["isShortRead"] as! Bool)
        
        if (Filter["isShortRead"] as! Bool) {
            sender.backgroundColor = UIColor(rgb: 0x4865FF)
            sender.setTitleColor(.white, for: .normal)
            sender.tintColor = .white
        }
        else {
            sender.backgroundColor = UIColor(rgb: 0xFFFFFF)
            sender.setTitleColor(UIColor(rgb: 0x4865FF), for: .normal)
            sender.tintColor = UIColor(rgb: 0x4865FF)
        }
    }
    
    @IBAction func SelectExtendedRead(_ sender: UIButton) {
        Filter["isExtendedRead"] = !(Filter["isExtendedRead"] as! Bool)
        
        if (Filter["isExtendedRead"] as! Bool) {
            sender.backgroundColor = UIColor(rgb: 0x4865FF)
            sender.setTitleColor(.white, for: .normal)
            sender.tintColor = .white
        }
        else {
            sender.backgroundColor = UIColor(rgb: 0xFFFFFF)
            sender.setTitleColor(UIColor(rgb: 0x4865FF), for: .normal)
            sender.tintColor = UIColor(rgb: 0x4865FF)
        }
    }
    
    @IBAction func SelectExplicitRead(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        Filter["isExplicitRead"] = !(Filter["isExplicitRead"] as! Bool)
    }
    
//    func getSelectedGenderAry()->[Int]
//    {
//        var ret = [Int]()
//        for (index, chk) in genderCheckAry.enumerated() {
//            if( chk.isSelected ) {ret.append(index)}
//        }
//        return ret
//    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
