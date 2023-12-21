//
//  TextFieldsFont.swift
//  AdaptiveLayoutTest
//
//  Created by Nikesh Shakya on 4/1/19.
//  Copyright © 2019 Nikesh Shakya. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {
    
    open override func awakeFromNib() {
        self.font = self.font.withSize(self.font.pointSize.relativeToIphone8Width())
    }
    
}

extension UITextView {
    
    open override func awakeFromNib() {
        self.font = self.font?.withSize((self.font?.pointSize.relativeToIphone8Width())!)
    }
    
    func centerVertically() {
        let fittingSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fittingSize)
        let topOffset = (bounds.size.height - size.height * zoomScale) / 2
        let positiveTopOffset = max(1, topOffset)
        contentOffset.y = -positiveTopOffset
    }
}

extension UITextField {
    
    open override func awakeFromNib() {
        self.font = self.font?.withSize((self.font?.pointSize.relativeToIphone8Width())!)
    }
    
}

extension UIButton {
    
    open override func awakeFromNib() {
        self.titleLabel?.font = self.titleLabel?.font.withSize((self.titleLabel?.font.pointSize.relativeToIphone8Width())!)
    }
    
}

