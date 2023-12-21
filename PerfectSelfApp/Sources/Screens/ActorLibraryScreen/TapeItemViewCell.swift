//
//  TapeItemViewCell.swift
//  PerfectSelf
//
//  Created by user237181 on 8/3/23.
//  Copyright © 2023 Stas Seldin. All rights reserved.
//

import UIKit

class TapeItemViewCell: UITableViewCell {
    @IBOutlet weak var itemTxt: UILabel!
    @IBOutlet weak var selectMark: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
