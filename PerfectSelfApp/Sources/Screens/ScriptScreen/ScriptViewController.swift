//
//  ScriptViewController.swift
//  PerfectSelf
//
//  Created by user232392 on 4/26/23.
//  Copyright © 2023 Stas Seldin. All rights reserved.
//

import UIKit
import PDFKit

class ScriptViewController: UIViewController{

    var script: String = ""
    var scriptBucketName = ""
    var scriptKey = ""
    
    @IBOutlet weak var pdfView: PDFView!
    @IBOutlet weak var scriptView: UIStackView!
    @IBOutlet weak var btn_download: UIButton!
    @IBOutlet weak var text_script: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
    }
    
    override func viewWillAppear(_ animated: Bool) {
        text_script.text = script
        if scriptKey.isEmpty {
            pdfView.isHidden = true
            btn_download.isEnabled = false
        }
        else {
            scriptView.isHidden = true
            print(scriptBucketName, scriptKey)
            let filePath = URL(string: "https://\(scriptBucketName).s3.us-east-2.amazonaws.com/\(getS3KeyName(scriptKey))")!
        
            DispatchQueue.global(qos: .userInitiated).async {
                DispatchQueue.main.async {[self] in
                    if let document = PDFDocument(url: filePath) {
                        pdfView.document = document
                    }
                }
            }
        }
    }
 
    @IBAction func DownloadScript(_ sender: UIButton) {
        //download script
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
        let pdfName = (scriptKey as NSString).lastPathComponent
        let filePath = URL(fileURLWithPath: "\(documentsPath)/\(pdfName)")
        do {
            try FileManager.default.removeItem(at: filePath)
            //print("File deleted successfully")
        } catch {
            //print("Error deleting file: \(error.localizedDescription)")
        }
         
        print(scriptBucketName, scriptKey)
        awsUpload.download(filePath: filePath, bucketName: scriptBucketName, key: scriptKey) { (error) -> Void in
            DispatchQueue.main.async {
                hideIndicator(sender: nil)
            }
            
            if error != nil {
                 print(error!.localizedDescription)
                DispatchQueue.main.async {
                    Toast.show(message: "Faild to download script", controller: self)
                }
            }
            else{
                DispatchQueue.main.async {
                    Toast.show(message: "Script downloaded!", controller: self)
                }
                
                let destinationPath = getDocumentsDirectory()
                let targetUrl = destinationPath.appendingPathComponent(pdfName)

                let fileManager = FileManager.default
                if fileManager.fileExists(atPath: targetUrl.absoluteString) == false {
                    do {
                        //try fileManager.moveItem(at: filePath, to: targetUrl)
                        try fileManager.moveItem(at: filePath, to:  targetUrl)
                        print("Move successful")
                    } catch let error {
                        print("Error: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    @IBAction func GoBack(_ sender: UIButton) {
        let transition = CATransition()
        transition.duration = 0.5 // Set animation duration
        transition.type = CATransitionType.push // Set transition type to push
        transition.subtype = CATransitionSubtype.fromLeft // Set transition subtype to from right
        self.view.window?.layer.add(transition, forKey: kCATransition) // Add transition to window layer
        self.dismiss(animated: false)
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
