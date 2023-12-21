//
//  UIView+Extensions.swift
//  VIdeoAudioOverLay
//
//  Created by Jatin Kathrotiya on 07/09/22.
//

import Foundation
import UIKit

extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            layer.cornerRadius
        } set {
            layer.cornerRadius = newValue
        }
    }

    @IBInspectable var borderWidth: CGFloat {
        get {
            layer.borderWidth
        } set {
            layer.borderWidth = newValue
        }
    }

    @IBInspectable var borderColor: UIColor {
        get {
            UIColor(cgColor: layer.borderColor ?? UIColor.white.cgColor)
        } set {
            layer.borderColor = newValue.cgColor
        }
    }
}
