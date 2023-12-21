//
//  ActorSetPaymentViewController.swift
//  PerfectSelf
//
//  Created by user232392 on 3/15/23.
//  Copyright © 2023 Stas Seldin. All rights reserved.
//

import UIKit
import AnimatedCardInput

class ActorSetPaymentViewController: UIViewController {
    
    let bookingInfo: BookingInfo
//Omitted
//    var readerUid: String = ""
//    var readerName: String = ""
//    var bookingStartTime: String = ""
//    var bookingEndTime: String = ""
//    var bookingDate: String = ""
//    var projectName: String = ""
//    var script: String = ""
//    var scriptBucket: String = ""
//    var scriptKey: String = ""
    
    @IBOutlet weak var cardView: UIStackView!
    @IBOutlet weak var btn_credit: UIButton!
    @IBOutlet weak var btn_paypal: UIButton!
    @IBOutlet weak var btn_applepay: UIButton!
    
    init(_ bookingInfo: BookingInfo) {
        self.bookingInfo = bookingInfo
        super.init(nibName: String(describing: ActorSetPaymentViewController.self), bundle: Bundle.main)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let myCardView = CardView(
            cardNumberDigitsLimit: 16,
            cardNumberChunkLengths: [4, 4, 4, 4],
            CVVNumberDigitsLimit: 3
        )
        cardView.addSubview(myCardView)
        NSLayoutConstraint.activate([
            myCardView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 10),
            myCardView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            myCardView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20)
        ])
    }

    @IBAction func SelectCreditCardPay(_ sender: UIButton) {
        btn_credit.isSelected = true
        btn_applepay.isSelected = false
        btn_paypal.isSelected = false
    }
    
    @IBAction func SelectApplePay(_ sender: UIButton) {
        btn_credit.isSelected = false
        btn_applepay.isSelected = true
        btn_paypal.isSelected = false
    }
    
    @IBAction func SelectPayPal(_ sender: UIButton) {
        btn_credit.isSelected = false
        btn_applepay.isSelected = false
        btn_paypal.isSelected = true
    }
    @IBAction func DoCheckout(_ sender: UIButton) {
        let controller = ActorBookConfirmationViewController( bookingInfo );
//Omitted
//        controller.readerUid = readerUid
//        controller.readerName = readerName
//        controller.bookingStartTime = bookingStartTime
//        controller.bookingEndTime = bookingEndTime
//        controller.bookingDate = bookingDate
//        controller.projectName = projectName
//        controller.script = script
//        controller.scriptBucket = self.scriptBucket
//        controller.scriptKey = self.scriptKey
        controller.modalPresentationStyle = .fullScreen
        
//        let transition = CATransition()
//        transition.duration = 0.5 // Set animation duration
//        transition.type = CATransitionType.push // Set transition type to push
//        transition.subtype = CATransitionSubtype.fromRight // Set transition subtype to from right
//        self.view.window?.layer.add(transition, forKey: kCATransition) // Add transition to window layer
        self.present(controller, animated: false)
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
