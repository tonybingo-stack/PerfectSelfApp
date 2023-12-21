//
//  ActorLibraryViewController.swift
//  PerfectSelf
//
//  Created by Kayan Mishra on 3/8/23.
//  Copyright © 2023 Stas Seldin. All rights reserved.
//

import UIKit

class ActorLibraryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
        
    @IBOutlet weak var createFolderPannel: UIView!
    @IBOutlet weak var newFolderName: UITextField!
    @IBOutlet weak var videoList: UICollectionView!
    @IBOutlet weak var searchTxt: UITextField!    
    @IBOutlet weak var folderBackButton: UIButton!
    
    var uid = ""
    var items = [VideoCard]()
    var folderList = [VideoCard]()
    var tapeList = [VideoCard]()
    
    let cellsPerRow = 2
    //Omitted var menuArray: [HSMenu] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "VideoCollectionViewCell", bundle: nil)
        videoList.register(nib, forCellWithReuseIdentifier: "Video Collection View Cell")
        videoList.dataSource = self
        videoList.delegate = self
        videoList.allowsSelection = true
        // Do any additional setup after loading the view.
        if let userInfo = UserDefaults.standard.object(forKey: "USER") as? [String:Any] {
            // Use the saved data
            uid = userInfo["uid"] as! String
        } else {
            // No data was saved
            print("No data was saved.")
        }
        
//        //Omitted
//        let menu1 = HSMenu(icon: nil, title: "Create Folder")
//        let menu2 = HSMenu(icon: nil, title: "Edit")
//
//        menuArray = [menu1, menu2]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        items.removeAll()
        fetchVideos()
        videoList.reloadData()
        
#if OVERLAY_TEST
        var count = 3
        _ = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { timer in
            count -= 1
            if count == 0 {
                timer.invalidate()
                if(self.items.count > 0)
                {
                    selectedTape = self.items[0]
                    let projectViewController = ProjectViewController()
                    projectViewController.modalPresentationStyle = .fullScreen
                    self.present(projectViewController, animated: false, completion: nil)
                }
            }
        })
#endif//OVERLAY_TEST
    }
    
    func fetchVideos() {
        showIndicator(sender: nil, viewController: self)
        webAPI.getLibraryByUid(uid: uid, pid: parentFolderId, keyword: searchTxt.text!){ data, response, error in
            DispatchQueue.main.async {
                hideIndicator(sender: nil)
            }
            
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            do {
                let respItems = try JSONDecoder().decode([VideoCard].self, from: data)
                //print(items)
                DispatchQueue.main.async {
                    self.items.removeAll()
                    self.tapeList.removeAll()
                    if parentFolderId.isEmpty {
                        self.folderList.removeAll()
                    }
                    
                    self.items.append(contentsOf: respItems)
                    //UTC2local
                    for index in self.items.indices {
                        self.items[index].createdTime = utcToLocal(dateStr: self.items[index].createdTime)!
                        self.items[index].updatedTime = utcToLocal(dateStr: self.items[index].updatedTime)!
                        self.items[index].deletedTime = utcToLocal(dateStr: self.items[index].deletedTime)!
                        
                        //Only Tape.
                        if self.items[index].actorTapeKey.count > 0{
                            self.tapeList.append( self.items[index] )
                        }
                        
                        //Only Folder
                        if parentFolderId.isEmpty && self.items[index].actorTapeKey.count == 0 {
                            self.folderList.append( self.items[index] )
                        }
                    }
                    //                    for (i, reader) in items.enumerated() {
                    //                    }
                    self.videoList.reloadData()
                }
                
            } catch {
                print(error)
                DispatchQueue.main.async {
                    Toast.show(message: "Fetching reader list failed! please try again.", controller: self)
                }
            }
        }
    }
    
    @IBAction func createFolderMenuDidTap(_ sender: UIButton) {
        let TITLES = ["Create Folder", "Edit Folder", "Delete Folder"]
        let ICONS = ["create-folder","edit-icon-15","icons8-trash-15"]
        PopupMenu.showRelyOnView(view: sender as UIView, titles: TITLES, icons: ICONS, menuWidth: 200, delegate: self) { (popupMenu) in
            popupMenu.priorityDirection = PopupMenuPriorityDirection.none
            popupMenu.borderWidth = 1
            popupMenu.borderColor = UIColor.gray
           // popupMenu.rectCorner = [.bottomRight,.bottomLeft]
        }
    }
    
    @IBAction func createFolderCancelDidTap(_ sender: UIButton) {
        createFolderPannel.isHidden = true
    }
    
    @IBAction func createFolderOkDidTap(_ sender: UIButton) {
        var inputCheck: String = ""
        var focusTextField: UITextField? = nil
        if(newFolderName.text!.isEmpty){
            inputCheck += "- Please input folder name.\n"
            if(focusTextField == nil){
                focusTextField = newFolderName
            }
        }
        
        if(!inputCheck.isEmpty){
            showAlert(viewController: self, title: "Confirm", message: inputCheck) { UIAlertAction in
                focusTextField!.becomeFirstResponder()
            }
            return
        }
        
        createFolderPannel.isHidden = true
        
        if let userInfo = UserDefaults.standard.object(forKey: "USER") as? [String:Any] {
            let uid = userInfo["uid"] as! String
            let tapeName = getStringWithLen( newFolderName.text!, 10)
            let tapeFolderId = getTapeIdString()
            //{{Add Folder
            webAPI.addLibrary(uid: uid
                              , tapeName: tapeName
                              , bucketName: "1"
                              , tapeKey: ""
                              , roomUid: tapeFolderId
                              , tapeId: tapeFolderId) { data, response, error in
                guard let data = data, error == nil else {
                    print(error?.localizedDescription ?? "No data")
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("statusCode: \(httpResponse.statusCode)")
                }
                
                let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                if let responseJSON = responseJSON as? [String: Any] {
                    
                    guard responseJSON["id"] != nil,  responseJSON["id"] as! Int >= 0 else {
                        DispatchQueue.main.async {
                            Toast.show(message: "Already exist folder with new name.", controller: self)
                            //self.text_email.becomeFirstResponder()
                        }
                        return
                    }
                    
                    DispatchQueue.main.async {
                        self.upFolderDidTap(nil)
                    }
                }
            }
            //}}Add Folder
        }
    }
    
    @IBAction func upFolderDidTap(_ sender: UIButton?) {
        parentFolderId = ""
        folderBackButton.isHidden = true
        
        items.removeAll()
        fetchVideos()
        videoList.reloadData()
    }
    
    @IBAction func searchTxtEditingDidEnd(_ sender: UITextField) {
        items.removeAll()
        fetchVideos()
        videoList.reloadData()
    }
    
    func deleteFolder(){
        guard parentFolderId.count > 0 else{
            return
        }
        
        guard self.items.count <= 0 else{
            Toast.show(message: "This folder is not empty. To delete tapes, please use to delete after select tape from here.", controller: self)
            return
        }
        
        if let userInfo = UserDefaults.standard.object(forKey: "USER") as? [String:Any] {
            let uid = userInfo["uid"] as! String
            let tapeFolderId = parentFolderId
            //{{Delete Folder
            webAPI.deleteTapeByUid(uid: uid, tapeKey: "0", roomUid:  tapeFolderId, tapeId:  parentFolderKey) { data, response, error in
                guard let _ = data, error == nil else {
                    print(error?.localizedDescription ?? "No data")
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("statusCode: \(httpResponse.statusCode)")
                }
                
                DispatchQueue.main.async {
                    self.upFolderDidTap(nil)
                }
            }
            //}}Add Folder
        }
    }
    
//Omitted
//    @IBAction func ShowFolderMenu(_ sender: UIButton) {
//        let originInWindow = sender.convert(CGPoint.zero, to: nil)
//
//        let x = originInWindow.x
//        let y = originInWindow.y + sender.frame.height
//
//        let popupMenu = HSPopupMenu(menuArray: menuArray, arrowPoint: CGPoint(x: x, y: y))
//        popupMenu.popUp()
//        popupMenu.delegate = self
//
//    }
    
    // MARK: - Video List Delegate.
    func collectionView(_ collectionView: UICollectionView,        numberOfItemsInSection section: Int) -> Int {
         // myData is the array of items
        return self.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
            + (flowLayout.minimumInteritemSpacing * CGFloat(cellsPerRow - 1))
        let size = Int((collectionView.bounds.width - totalSpace - 2) / CGFloat(cellsPerRow))
       
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Video Collection View Cell", for: indexPath) as! VideoCollectionViewCell
        cell.name.text = getProjectName(tape: self.items[indexPath.row])
        if self.items[indexPath.row].actorTapeKey.count == 0 {
            //Folder
            cell.folderView.isHidden = false
            cell.name.textColor = UIColor.black
            cell.createdDate.textColor = UIColor.black
            cell.createdDate.borderColor = UIColor.black
        }
        else {
            let thumb = "https://video-thumbnail-bucket-123456789.s3.us-east-2.amazonaws.com/\(self.items[indexPath.row].actorTapeKey)-0.jpg"
            cell.tapeThumb.imageFrom(url: URL(string:thumb )!)
            cell.tapeThumb.transform = CGAffineTransformMakeRotation(degreeToRadian(CGFloat(mainRotateDegree)))
            
            cell.folderView.isHidden = true
            cell.name.textColor = UIColor.white
            cell.createdDate.textColor = UIColor.white
            cell.createdDate.borderColor = UIColor.white
        }
        
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let d = df.date(from: self.items[indexPath.row].createdTime)
        df.dateFormat = "MM-dd-yyyy"
        cell.createdDate.text = df.string(from: d ?? Date())
        // return card
//        cell.layer.masksToBounds = false
//        cell.layer.shadowOffset = CGSizeZero
//        cell.layer.shadowRadius = 8
//        cell.layer.shadowOpacity = 0.2
//        cell.contentView.layer.cornerRadius = 12
//        cell.contentView.layer.borderWidth = 1.0
//        cell.contentView.layer.borderColor = UIColor.clear.cgColor
//        cell.contentView.layer.masksToBounds = true
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // add the code here to perform action on the cell
        print("didDeselectItemAt" + String(indexPath.row))
        
        if self.items[indexPath.row].actorTapeKey.count == 0 {
            //Folder
            folderBackButton.isHidden = false
            parentFolderId = self.items[indexPath.row].roomUid
            parentFolderKey = self.items[indexPath.row].tapeId
            
            items.removeAll()
            fetchVideos()
            videoList.reloadData()
        }
        else{
            //Tape
            videoRotateOffset = 0
            selectedTape = self.items[indexPath.row]
            let projectViewController = ProjectViewController()
            projectViewController.modalPresentationStyle = .fullScreen
            self.present(projectViewController, animated: false, completion: nil)
        }
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

extension ActorLibraryViewController : PopupMenuDelegate{
    
    func popupMenuDidSelected(index: NSInteger, popupMenu: PopupMenu) {
        switch index{
        case 0://Create Folder
            newFolderName.text = ""
            createFolderPannel.isHidden = false
            break
        case 1://Rename Folder
            let editFolderViewController = EditFolderViewController(tapeLst: tapeList, folderLst: folderList)
            editFolderViewController.modalPresentationStyle = .fullScreen
            self.present(editFolderViewController, animated: false, completion: nil)
            break
        case 2://Delete Folder
            deleteFolder()
            break
        default:
            break
        }
    }
}
