//
//  VideoCollectionViewCell.swift
//  PerfectSelf
//
//  Created by user232392 on 3/24/23.
//  Copyright © 2023 Stas Seldin. All rights reserved.
//

import UIKit

class VideoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var tapeThumb: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var createdDate: UILabel!
    @IBOutlet weak var folderView: UIView!
        
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func playVideo(_ sender: UIButton) {
        print("play")
    }
    
    //Share feature
    @IBAction func editVideo(_ sender: UIButton) {
        print("edit")
        
//        DispatchQueue.global(qos: .background).async {
//            exportMergedVideo(avUrl: self.videoURL, aaUrl: self.audioURL!
//                              , rvUrl: self.readerVideoURL, raUrl: self.readerAudioURL
//                              , vc: self) { url in
//                DispatchQueue.main.async {
//                    guard let _ = url else{
//                        Toast.show(message: "Failed during export result video.", controller: self)
//                        return
//                    }
//
//                    //let textToShare = "Share this awesome video."
//                    let activityViewController = UIActivityViewController(activityItems: [url!/*, textToShare*/], applicationActivities: nil)
//
//                    // If you want to exclude certain activities, you can set excludedActivityTypes
//                    activityViewController.excludedActivityTypes = [
//                        //.addToReadingList,
//                        //.assignToContact,
//                        //.print,
//                        // Add any other activity types you want to exclude
//                    ]
//
//                    activityViewController.popoverPresentationController?.sourceView = sender// If your app is iPad-compatible, this line will set the source view for the popover
//                    self.present(activityViewController, animated: true, completion: nil)
//                }
//            }
//        }
    }
}
