//
//  customkey.swift
//  PerfectSelf
//
//  Created by user232392 on 3/30/23.
//  Copyright © 2023 Stas Seldin. All rights reserved.
//

import Foundation
import UIKit

class KUIViewController: UIViewController {

    // KBaseVC is the KEYBOARD variant BaseVC. more on this later

    @IBOutlet var bottomConstraintForKeyboard: NSLayoutConstraint!

    @IBOutlet weak var keyboardDismissView: UIView!
    @objc func keyboardWillShow(sender: NSNotification) {
        let i = sender.userInfo!
        let s: TimeInterval = (i[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let k = (i[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height - 34
        bottomConstraintForKeyboard.constant = k
        // Note. that is the correct, actual value. Some prefer to use:
        // bottomConstraintForKeyboard.constant = k - bottomLayoutGuide.length
        UIView.animate(withDuration: s) { self.view.layoutIfNeeded() }
    }

    @objc func keyboardWillHide(sender: NSNotification) {
        let info = sender.userInfo!
        let s: TimeInterval = (info[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        bottomConstraintForKeyboard.constant = 0
        UIView.animate(withDuration: s) { self.view.layoutIfNeeded() }
    }

    @objc func clearKeyboard() {
        view.endEditing(true)
        // (subtle iOS bug/problem in obscure cases: see note below
        // you may prefer to add a short delay here)
    }

    func keyboardNotifications() {
        NotificationCenter.default.addObserver(self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        NotificationCenter.default.addObserver(self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        keyboardNotifications()
        let t = UITapGestureRecognizer(target: self, action: #selector(clearKeyboard))
        keyboardDismissView.addGestureRecognizer(t)
        t.cancelsTouchesInView = false
    }
}
