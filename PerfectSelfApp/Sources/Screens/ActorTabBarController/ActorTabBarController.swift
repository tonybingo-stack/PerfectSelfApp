//
//  ActorTabBarController.swift
//  PerfectSelf
//
//  Created by Kayan Mishra on 3/13/23.
//  Copyright © 2023 Stas Seldin. All rights reserved.
//

import UIKit
import JJFloatingActionButton
import MobileCoreServices
import Photos

class ActorTabBarController: UITabBarController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    var videoUrl: URL?
    let imagePicker = UIImagePickerController()
    var savedReaderVideoUrl: URL? = nil
    var savedReaderAudioUrl: URL? = nil
//    let alertController = UIAlertController(title: nil, message: "", preferredStyle: .actionSheet);
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rootTabbar = self
        
        // Do any additional setup after loading the view.
        tabBar.tintColor = .white;
        tabBar.unselectedItemTintColor = .white.withAlphaComponent(0.67);
        tabBar.isTranslucent = false;
        UITabBar.appearance().backgroundColor = UIColor(rgb: 0x7587D9)
        setupVCs();
  
        // Add floating button
        let actionButton = JJFloatingActionButton()
        actionButton.addItem(title: "Create Slate", image: UIImage(systemName: "plus.circle")) { item in
          // do something
            
        }
        actionButton.addItem(title: "Create Self Tape", image: UIImage(systemName: "plus.circle")) { item in

            // do something
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
#if !targetEnvironment(simulator)
                print("captureVideoPressed and camera available.")
                
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = .camera
                self.imagePicker.mediaTypes = [kUTTypeMovie as String]
                self.imagePicker.allowsEditing = false
                self.imagePicker.showsCameraControls = true
                
                DispatchQueue.main.async {
                    self.present(self.imagePicker, animated: true, completion: nil)
                    //Omitted Toast.show(message: "Start to create self tap.", controller:  self)
                }
#endif
            } else {
                print("Camera not available.")
            }
        }

        actionButton.buttonDiameter = 50;
        actionButton.overlayView.backgroundColor = UIColor(white: 0, alpha: 0.5);
        actionButton.buttonColor =  UIColor(rgb: 0x7587D9);
      
        view.addSubview(actionButton)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
//        actionButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        actionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
        actionButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true;

#if OVERLAY_TEST
        selectedIndex = 1
#endif//OVERLAY_TEST
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true);
        
        if let arrayOfTabBarItems = self.tabBar.items as AnyObject as? NSArray,let
           tabBarItem = arrayOfTabBarItems[2] as? UITabBarItem {
           tabBarItem.isEnabled = false
        }
    }
    
    fileprivate func createNavController(for rootViewController: UIViewController,
                                                    title: String,
                                                    image: UIImage) -> UIViewController {
        let navController = UINavigationController(rootViewController: rootViewController)
//        navController.tabBarItem.title = title
        navController.tabBarItem.image = image.resizeImage(targetSize: CGSizeMake(32.0, 32.0))
        //navController.navigationBar.prefersLargeTitles = true
        // rootViewController.navigationItem.title = title
        return navController
      }
  
    func setupVCs() {
//        var fakeNC = UINavigationController(rootViewController: UIViewController());
//        fakeNC.isToolbarHidden = true;
//        fakeNC.isNavigationBarHidden = true;
        
        viewControllers = [
              createNavController(for: ActorHomeViewController(), title: NSLocalizedString("Home", comment: ""), image: UIImage(systemName: "homekit")!),
              createNavController(for: ActorLibraryViewController(), title: NSLocalizedString("Library", comment: ""), image: UIImage(systemName: "book")!),
              UINavigationController(rootViewController: UIViewController()),
              createNavController(for: ActorBookingViewController(), title: NSLocalizedString("Book", comment: ""), image: UIImage(systemName: "calendar")!),
              createNavController(for: ActorProfileViewController(), title: NSLocalizedString("FindReader", comment: ""), image: UIImage(systemName: "person")!)
        ];
      }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // Delegate method to handle the selected image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        videoUrl = info[UIImagePickerController.InfoKey.mediaURL] as! URL?
        //Omitted print(self.videoUrl!)//let pathString = self.videoUrl?.relativePath
        
//        DispatchQueue.main.async {
//            Toast.show(message: "Video Url: \(self.videoUrl!)", controller:  self)
//        }
        DispatchQueue.main.async {
            saveOnlyVideoFrom(url: self.videoUrl!) { url in
                print(url)
                self.savedReaderVideoUrl = url
//                let fileManager = FileManager.default
//                try? fileManager.removeItem(at: url)
                saveOnlyAudioFrom(url: self.videoUrl!) { url in
                    print(url)
                    self.savedReaderAudioUrl = url
//                    let fileManager = FileManager.default
//                    try? fileManager.removeItem(at: url)
                    let overlayViewController = OverlayViewController()
                    overlayViewController.uploadAudiourl = self.savedReaderVideoUrl
                    overlayViewController.uploadAudiourl = self.savedReaderAudioUrl
                    overlayViewController.modalPresentationStyle = .fullScreen
                    self.present(overlayViewController, animated: false, completion: nil)
                }
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    // Delegate method to handle cancellation of image picker
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        DispatchQueue.main.async {
            Toast.show(message: "Video Picker Canceled", controller:  self)
        }
        dismiss(animated: true, completion: nil)
    }
}
