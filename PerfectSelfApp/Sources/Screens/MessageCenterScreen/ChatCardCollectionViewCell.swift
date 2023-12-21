//
//  ChatCardCollectionViewCell.swift
//  PerfectSelf
//
//  Created by user232392 on 3/25/23.
//  Copyright © 2023 Stas Seldin. All rights reserved.
//

import UIKit

class ChatCardCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var view_unread: UIView!
    @IBOutlet weak var lbl_unviewednum: UILabel!
    @IBOutlet weak var lbl_time: UILabel!
    @IBOutlet weak var lbl_message: UILabel!
    @IBOutlet weak var lbl_name: UILabel!
    @IBOutlet weak var view_status: UIView!
    @IBOutlet weak var img_avatar: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func prepareForReuse() {
         super.prepareForReuse()
         
         // Reset any properties that could affect the cell's appearance
        img_avatar.image = UIImage(systemName: "person.circle.fill")
        lbl_name.text = ""
        lbl_message.text = ""
        lbl_time.text = ""
        lbl_unviewednum.text = ""
        view_status.backgroundColor = UIColor(rgb: 0xAAAAAA)
        view_unread.isHidden = false
     }
}
