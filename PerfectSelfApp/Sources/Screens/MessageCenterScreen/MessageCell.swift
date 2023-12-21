//
//  MessageCell.swift
//  PerfectSelf
//
//  Created by user232392 on 3/27/23.
//  Copyright © 2023 Stas Seldin. All rights reserved.
//

import UIKit

class MessageCell: UICollectionViewCell {

    @IBOutlet weak var messageLabel: UILabel!
    var messageType: MessageType?
    
    @IBOutlet weak var container: UIStackView!
    @IBOutlet weak var messageView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
   
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let messageType = messageType else {
            return
        }
//        print("here", messageType)
        switch messageType {
        case .sent:
            container.alignment = .trailing
            messageView.backgroundColor = UIColor(rgb: 0x7587D9)
            messageView.layer.cornerRadius = 10
            messageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner]
        
        case .received:
            container.alignment = .leading
            messageView.backgroundColor = UIColor(rgb: 0xA9A9A9)
            messageView.layer.cornerRadius = 10
            messageView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner]
        }
    }
    override func prepareForReuse() {
         super.prepareForReuse()
         
         // Reset any properties that could affect the cell's appearance
        container.alignment = .fill
//        print("there" )
     }

}
