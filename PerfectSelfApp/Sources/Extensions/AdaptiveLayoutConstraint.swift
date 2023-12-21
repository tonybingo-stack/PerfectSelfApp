//
//  AdaptiveLayoutConstraint.swift
//  AdaptiveLayoutTest
//
//  Created by Nikesh Shakya on 4/1/19.
//  Copyright © 2019 Nikesh Shakya. All rights reserved.
//

import Foundation
import UIKit

class AdaptiveLayoutConstraint: NSLayoutConstraint {
    
    @IBInspectable var setAdaptiveLayout: Bool = true
    
    override func awakeFromNib() {
        if setAdaptiveLayout {
//            self.constant = self.constant.relativeToIphone8Width()
            self.constant = self.constant.relativeToIphone8Height()
            
            if let firstView = self.firstItem as? UIView {
                firstView.layoutIfNeeded()
            }
            if let secondVIew = self.secondItem as? UIView {
                secondVIew.layoutIfNeeded()
            }
        }
    }
    
}
