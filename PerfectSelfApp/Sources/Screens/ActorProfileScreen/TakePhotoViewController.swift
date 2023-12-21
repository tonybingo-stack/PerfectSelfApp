//
//  TakePhotoViewController.swift
//  PerfectSelf
//
//  Created by user232392 on 4/24/23.
//  Copyright © 2023 Stas Seldin. All rights reserved.
//

import UIKit

protocol PhotoDelegate {
    func chooseFromLibrary()
    func takePhoto()
    func removeCurrentPicture()
}

class TakePhotoViewController: UIViewController {
    var delegate: PhotoDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func CloseModal(_ sender: UITapGestureRecognizer) {
        self.dismiss(animated: true)
    }
    @IBAction func ChooseFromLib(_ sender: UIButton) {
        delegate?.chooseFromLibrary()
        self.dismiss(animated: true)
    }
    
    @IBAction func TakePhoto(_ sender: UIButton) {
        delegate?.takePhoto()
        self.dismiss(animated: true)
    }
    @IBAction func RemoveCurrentPicture(_ sender: UIButton) {
        delegate?.removeCurrentPicture()
        self.dismiss(animated: true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
