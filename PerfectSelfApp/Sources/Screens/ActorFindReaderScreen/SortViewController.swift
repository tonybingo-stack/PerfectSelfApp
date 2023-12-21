//
//  SortViewController.swift
//  PerfectSelf
//
//  Created by user232392 on 4/6/23.
//  Copyright © 2023 Stas Seldin. All rights reserved.
//

import UIKit

protocol SortDelegate {
    func setSortType(viewController: UIViewController, sortType: Int)
}
class SortViewController: UIViewController {
    var sd: SortDelegate?
    var sortType = 0
    @IBOutlet weak var btn_relevance: UIButton!
    @IBOutlet weak var btn_pricehightolow: UIButton!
    @IBOutlet weak var btn_pricelowtohigh: UIButton!
    @IBOutlet weak var btn_soonest: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if sortType == 0 {
            btn_relevance.isSelected = true
        }
        else if sortType == 3 {
            btn_pricelowtohigh.isSelected = true
        }
        else if sortType == 4 {
            btn_pricehightolow.isSelected = true
        }
        else if sortType == 5 {
            btn_soonest.isSelected = true
        }
        else {
            print("oops!")
        }
    }


    @IBAction func tapCallback(_ sender: UITapGestureRecognizer) {
        self.dismiss(animated: true)
    }
    
    @IBAction func SaveToApply(_ sender: UIButton) {
        sd?.setSortType(viewController: self, sortType: self.sortType)
        self.dismiss(animated: true)
    }

    @IBAction func SelectRelevance(_ sender: UIButton) {
        sortType = 0
        btn_relevance.isSelected = true
        btn_pricehightolow.isSelected = false
        btn_pricelowtohigh.isSelected = false
        btn_soonest.isSelected = false
//        btn_relevance.tintColor = UIColor(rgb: 0x4383C4)
//        btn_pricehightolow.tintColor = .black
//        btn_pricelowtohigh.tintColor = .black
//        btn_soonest.tintColor = .black
    }
    
    @IBAction func SelectPriceHighToLow(_ sender: UIButton) {
        sortType = 4
        btn_relevance.isSelected = false
        btn_pricehightolow.isSelected = true
        btn_pricelowtohigh.isSelected = false
        btn_soonest.isSelected = false
//        btn_relevance.tintColor = .black
//        btn_pricehightolow.tintColor = UIColor(rgb: 0x4383C4)
//        btn_pricelowtohigh.tintColor = .black
//        btn_soonest.tintColor = .black
    }
    @IBAction func SelectPriceLowToHigh(_ sender: UIButton) {
        sortType = 3
        btn_relevance.isSelected = false
        btn_pricehightolow.isSelected = false
        btn_pricelowtohigh.isSelected = true
        btn_soonest.isSelected = false
//        btn_relevance.tintColor = .black
//        btn_pricehightolow.tintColor = .black
//        btn_pricelowtohigh.tintColor = UIColor(rgb: 0x4383C4)
//        btn_soonest.tintColor = .black
    }
    @IBAction func SelectAvailableSoonest(_ sender: UIButton) {
        sortType = 5
        btn_relevance.isSelected = false
        btn_pricehightolow.isSelected = false
        btn_pricelowtohigh.isSelected = false
        btn_soonest.isSelected = true
//        btn_relevance.tintColor = .black
//        btn_pricehightolow.tintColor = .black
//        btn_pricelowtohigh.tintColor = .black
//        btn_soonest.tintColor = UIColor(rgb: 0x4383C4)
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
