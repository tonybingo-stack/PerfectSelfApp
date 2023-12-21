//
//  AudioInputCell.swift
//  PerfectSelf
//
//  Created by user237184 on 7/4/23.
//  Copyright © 2023 Stas Seldin. All rights reserved.
//

import UIKit

class AudioInputTableCell: UITableViewCell {
   
    @IBOutlet weak var lblName: UILabel!
    func configCell(name: String) {
        lblName?.text = name
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
