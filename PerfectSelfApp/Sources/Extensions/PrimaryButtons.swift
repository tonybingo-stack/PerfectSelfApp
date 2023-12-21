//
//  PrimaryButtons.swift
//  VIdeoAudioOverLay
//
//  Created by Jatin Kathrotiya on 06/09/22.
//

import UIKit

final class PrimaryButtons: UIButton {
    override init(frame: CGRect){
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setup()
    }

    func setup() {
        self.clipsToBounds = true
        self.layer.cornerRadius = 8.0
        borderColor = borderColor
        borderWidth = 1.0
    }
}
