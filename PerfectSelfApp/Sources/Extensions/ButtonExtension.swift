//
//  ButtonExtension.swift
//  PerfectSelf
//
//  Created by user237181 on 6/2/23.
//  Copyright © 2023 Stas Seldin. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    func loadingIndicator(_ show: Bool) {
        let tag = 808404
        if show {

            let indicator = UIActivityIndicatorView()
            let buttonHeight = self.bounds.size.height
            let buttonWidth = self.bounds.size.width
            indicator.center = CGPoint(x: buttonWidth/2, y: buttonHeight/2)
            indicator.tag = tag
            self.addSubview(indicator)
            indicator.startAnimating()
        } else {
            if let indicator = self.viewWithTag(tag) as? UIActivityIndicatorView {
                indicator.stopAnimating()
                indicator.removeFromSuperview()
            }
        }
    }
}
