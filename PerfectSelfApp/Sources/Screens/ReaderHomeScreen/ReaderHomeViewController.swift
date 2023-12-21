//
//  ReaderHomeViewController.swift
//  PerfectSelf
//
//  Created by Kayan Mishra on 3/8/23.
//  Copyright © 2023 Stas Seldin. All rights reserved.
//

import UIKit
import WebRTC

class ReaderHomeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    var uid = ""
    @IBOutlet weak var switch_mode: UISwitch!
    @IBOutlet weak var bookList: UICollectionView!
    @IBOutlet weak var todayLabel: UILabel!
    var items = [BookingCard]()
    let cellsPerRow = 1
    var todayStr = "08-17-2023"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uiViewContoller = self
        
        todayLabel.isHidden = true;
        let nib = UINib(nibName: "BookingCollectionViewCell", bundle: nil)
        bookList.register(nib, forCellWithReuseIdentifier: "Booking Collection View Cell")
        bookList.dataSource = self
        bookList.delegate = self
        bookList.allowsSelection = true
        // Do any additional setup after loading the view.
        switch_mode.transform = CGAffineTransform(scaleX: 0.8, y: 0.75);
        if let thumb = switch_mode.subviews[0].subviews[1].subviews[2] as? UIImageView {
            thumb.transform = CGAffineTransform(scaleX:1.25, y: 1.333)
        }
        if let userInfo = UserDefaults.standard.object(forKey: "USER") as? [String:Any] {
            // Use the saved data
            uid = userInfo["uid"] as! String
        } else {
            // No data was saved
            print("No data was saved.")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true);
        
        //call API to fetch booking list
        showIndicator(sender: nil, viewController: self)
      
        webAPI.getBookingsByUid(uid: uid, bookType: 1, name: "") { data, response, error in
            DispatchQueue.main.async {
                hideIndicator(sender: nil)
            }
            
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            do {
                let respItems = try JSONDecoder().decode([BookingCard].self, from: data)
//                print(respItems)
                DispatchQueue.main.async {
                    self.todayLabel.isHidden = true
                    self.items.removeAll()
                    self.items.append(contentsOf: respItems)
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                    //UTC2local
                    for index in self.items.indices {
                        self.items[index].bookStartTime = utcToLocal(dateStr: self.items[index].bookStartTime)!
                        self.items[index].bookEndTime = utcToLocal(dateStr: self.items[index].bookEndTime)!
                        
                        if self.todayLabel.isHidden {
                            let datestart = dateFormatter.date(from: self.items[index].bookStartTime)
                            self.todayLabel.isHidden = !Calendar.current.isDateInToday(datestart!)
                        }
                    }
                    
                    self.bookList.reloadData()
                    if self.items.isEmpty {
                        self.bookList.isHidden = true
                    }
                }

            } catch {
                print(error)
                DispatchQueue.main.async {
                    Toast.show(message: "Fetching reader list failed! please try again.", controller: self)
                }
            }
        }
        
#if RECORDING_TEST
        if(!onAWSUploading)
        {
            var count = 3
            _ = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { timer in
                count -= 1
                if count == 0 {
                    timer.invalidate()
                    if(self.items.count > 0)
                    {
                        let roomUid = self.items[0].roomUid
                        let conferenceViewController = ConferenceViewController(roomUid: roomUid, prjName: self.items[0].projectName, rdrName: self.items[0].readerName)
                        conferenceViewController.modalPresentationStyle = .fullScreen
                        
                        //        let transition = CATransition()
                        //        transition.duration = 0.5 // Set animation duration
                        //        transition.type = CATransitionType.push // Set transition type to push
                        //        transition.subtype = CATransitionSubtype.fromRight // Set transition subtype to from right
                        //        self.parentViewController!.view.window?.layer.add(transition, forKey: kCATransition) // Add transition to window layer
                        self.present(conferenceViewController, animated: false)
                    }
                    else
                    {
                        Toast.show(message: "Can't test for camera recording", controller: self)
                    }
                }
            })
        }
#endif//RECORDING_TEST
    }
    // MARK: - Booking List Delegate.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         // myData is the array of items
        return self.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
            + (flowLayout.minimumInteritemSpacing * CGFloat(cellsPerRow - 1))
        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(cellsPerRow))
        return CGSize(width: size, height: size*145/328)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Booking Collection View Cell", for: indexPath) as! BookingCollectionViewCell
        let roomUid = self.items[indexPath.row].roomUid
        
        let dateFormatter = DateFormatter()
//        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let datestart = dateFormatter.date(from: self.items[indexPath.row].bookStartTime)
        let dateend = dateFormatter.date(from: self.items[indexPath.row].bookEndTime)
        
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = appDatetimeFormat
        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = "hh:mm a"
        
        cell.bookType = 1
        cell.readerType = "reader"
        cell.projectName = self.items[indexPath.row].projectName
        cell.name = self.items[indexPath.row].actorName
        cell.selfName = self.items[indexPath.row].readerName
        cell.uid = self.items[indexPath.row].actorUid
        cell.muid = self.items[indexPath.row].readerUid
        cell.script = self.items[indexPath.row].scriptFile ?? ""
        cell.scriptBucketName = self.items[indexPath.row].scriptBucket ?? ""
        cell.scriptKey = self.items[indexPath.row].scriptKey ?? ""
        var url: String?
        if self.items[indexPath.row].actorBucketName != nil {
            url = "https://\(self.items[indexPath.row].actorBucketName!).s3.us-east-2.amazonaws.com/\(self.items[indexPath.row].actorAvatarKey!)"
        }
        cell.url = url
   
        cell.id = self.items[indexPath.row].id
        cell.lbl_name.text = self.items[indexPath.row].actorName;
        cell.lbl_date.text = dateFormatter1.string(from: datestart ?? Date())
        cell.lbl_time.text = dateFormatter2.string(from: datestart ?? Date()) + "-" + dateFormatter2.string(from: dateend ?? Date())
        
//        cell.layer.masksToBounds = false
//        cell.layer.shadowOffset = CGSizeZero
//        cell.layer.shadowRadius = 8
//        cell.layer.shadowOpacity = 0.2
//        cell.contentView.layer.cornerRadius = 12
//        cell.contentView.layer.borderWidth = 1.0
//        cell.contentView.layer.borderColor = UIColor.clear.cgColor
//        cell.contentView.layer.masksToBounds = true
//        cell.webRTCClient = webRTCClient
//        cell.signalClient = signalClient
        cell.navigationController = self.navigationController
        cell.parentViewController = self
        cell.roomUid = roomUid
        cell.readerFCMDeviceToken = self.items[indexPath.row].readerFCMDeviceToken
        cell.actorFCMDeviceToken = self.items[indexPath.row].actorFCMDeviceToken
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        // add the code here to perform action on the cell
        print("didDeselectItemAt")
//        let cell = collectionView.cellForItem(at: indexPath) as? LibraryCollectionViewCell
    }

    @IBAction func changeOnlineState(_ sender: UISwitch) {
        print(sender.isOn)
        //call api to update user online state
        webAPI.updateOnlineState(uid: uid, newState: sender.isOn) { data, response, error in
            guard let _ = data, error == nil else {
                DispatchQueue.main.async {
                    Toast.show(message: "Something went wrong", controller: self)
                }
                return
            }
        }
    }
    
    @IBAction func viewAllDidTap(_ sender: UIButton) {
        if(rootTabbar != nil){
            rootTabbar!.selectedIndex = 1
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
