//
//  ReaderCollectionViewCell.swift
//  PerfectSelf
//
//  Created by Kayan Mishra on 3/23/23.
//  Copyright © 2023 Stas Seldin. All rights reserved.
//

import UIKit

class ReaderCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var readerAvatar: UIImageView!
    @IBOutlet weak var readerName: UILabel!
    @IBOutlet weak var availableDate: UILabel!
    @IBOutlet weak var score: UILabel!
    @IBOutlet weak var salary: UILabel!
    @IBOutlet weak var status: UIView!
    @IBOutlet weak var review: UILabel!
    @IBOutlet weak var starImage: UIImageView!        
    @IBOutlet weak var availableView: UIStackView!
    override func awakeFromNib() {
        
        super.awakeFromNib()
        // Initialization code
    }
    override func prepareForReuse() {
         super.prepareForReuse()
         
         // Reset any properties that could affect the cell's appearance
        readerAvatar.image = UIImage(systemName: "person.fill")
        readerName.text = ""
        score.text = ""
        salary.text = ""
        availableDate.text = ""
        status.backgroundColor = UIColor(rgb: 0xAAAAAA)
        review.text = ""
        availableView.isHidden = false
     }

}
