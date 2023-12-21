//
//  ActorHomeViewController.swift
//  PerfectSelf
//
//  Created by Kayan Mishra on 3/8/23.
//  Copyright © 2023 Stas Seldin. All rights reserved.
//

import UIKit
import RangeSeekSlider

protocol BookingNotificationDelegate{
    func bookingAccepted()
}

class ActorHomeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITextFieldDelegate
{
//    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var readerList: UICollectionView!
    
    @IBOutlet weak var spin: UIActivityIndicatorView!
    @IBOutlet weak var readerListFlow: UICollectionViewFlowLayout!
    @IBOutlet weak var greetingLabel: UILabel!
    
    @IBOutlet weak var unread_badge: UIView!
    @IBOutlet weak var img_actor_avatar: UIImageView!
    
    @IBOutlet weak var btn_sponsored: UIButton!
    @IBOutlet weak var btn_availablesoon: UIButton!
    @IBOutlet weak var btn_topRate: UIButton!
    @IBOutlet weak var nextSessionLabel: UILabel!
    @IBOutlet weak var joinButton: UIButton!
    
    let backgroundView = UIView()
    var uid: String!
    var isSponsored = false
    var isAvailableSoon = false
    var isTopRated = false
    var searchString = ""
    var soonBooking: SoonBooking? = nil
    var delegate: BookingNotificationDelegate?
    
    var items = [ReaderProfileCard]()
    
    let cellsPerRow = 1
  
    override func viewDidLoad() {
        super.viewDidLoad()
        uiViewContoller = self
        actorHomeView = self
        delegate = self
         
        let nib = UINib(nibName: "ReaderCollectionViewCell", bundle: nil)
        readerList.register(nib, forCellWithReuseIdentifier: "Reader Collection View Cell")
        readerList.dataSource = self
        readerList.delegate = self
        readerList.allowsSelection = true
        self.unread_badge.isHidden = false
        // Do any additional setup after loading the view.
      
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        // Retrieve the saved data from UserDefaults
        if let userInfo = UserDefaults.standard.object(forKey: "USER") as? [String:Any] {
            // Use the saved data
            uid = userInfo["uid"] as? String
            getNextSesstion(uid: uid)

            // call user info
            webAPI.getUserInfo(uid: uid) { data, response, error in
                guard let data = data, error == nil else {
                    print(error?.localizedDescription ?? "No data")
                    return
                }
                
                let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                if let responseJSON = responseJSON as? [String: Any] {
                    
                    UserDefaults.standard.removeObject(forKey: "USER")
                    UserDefaults.standard.setValue(responseJSON, forKey: "USER")
                    DispatchQueue.main.async {
                        let firstName = responseJSON["firstName"] as! String
                        let lastName = responseJSON["lastName"] as! String
                        let name = "\(firstName) \(lastName)"//responseJSON["userName"] as? String
                        
                        let bucketName = responseJSON["avatarBucketName"] as? String
                        let avatarKey = responseJSON["avatarKey"] as? String
                        self.greetingLabel.text = "Hi, \(name)"
                        if (bucketName != nil && avatarKey != nil) {
                            let url = "https://\( bucketName!).s3.us-east-2.amazonaws.com/\(avatarKey!)"
                            self.img_actor_avatar.imageFrom(url: URL(string: url)!)
                        }
                    }
                }
            }
        } else {
            // No data was saved
            print("No data was saved.")
        }
        fetchReaderList()
        fetchUnreadState()
    }

    func fetchUnreadState() {
        //call API for badge appear
        webAPI.getUnreadCountByUid(uid: uid) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            do {
                let res = try JSONDecoder().decode(UnreadState.self, from: data)
                //print(items)
                DispatchQueue.main.async {
                    self.unread_badge.isHidden = res.unreadCount == 0
                }
            }
            catch {
                print(error)
                DispatchQueue.main.async {
                    Toast.show(message: "Fetching badge state failed! please try again.", controller: self)
                }
            }
        }
    }
    
    func fetchReaderList() {
        spin.isHidden = false
        spin.startAnimating()
        // call API to fetch reader list
        webAPI.getReaders(readerName: searchString,isSponsored: isSponsored, isAvailableSoon: isAvailableSoon,isTopRated: isTopRated, isOnline: nil, availableTimeSlotType: nil, availableFrom: nil, availableTo: nil, minPrice: nil, maxPrice: nil, gender: nil, sortBy: nil) { data, response, error in
            DispatchQueue.main.async {
                self.spin.stopAnimating()
                self.spin.isHidden = true
            }
            
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            do {
               
                let respItems = try JSONDecoder().decode([ReaderProfileCard].self, from: data)
//                print(respItems)
                DispatchQueue.main.async {
                    self.items.removeAll()
                    self.items.append(contentsOf: respItems)
                    
                    //UTC2local
                    for index in self.items.indices {
                        self.items[index].fromTime = utcToLocal(dateStr: self.items[index].fromTime)!
                        self.items[index].toTime = utcToLocal(dateStr: self.items[index].toTime)!
                    }
                    
                    self.readerList.reloadData()
                }

            } catch {
                print(error)
                DispatchQueue.main.async {
                    Toast.show(message: "Fetching reader list failed! please try again.", controller: self)
                }
            }
        }
    }

    // MARK: - Reader List Delegate.
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
        return CGSize(width: size, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Reader Collection View Cell", for: indexPath) as! ReaderCollectionViewCell
        
        if self.items[indexPath.row].avatarBucketName != nil {
            let url = "https://\( self.items[indexPath.row].avatarBucketName!).s3.us-east-2.amazonaws.com/\( self.items[indexPath.row].avatarKey!)"
            cell.readerAvatar.imageFrom(url: URL(string: url)!)
        }
        cell.readerName.text = self.items[indexPath.row].userName;
        cell.salary.text = "$" + String(self.items[indexPath.row].min15Price ?? 0)
        if(self.items[indexPath.row].reviewCount > 0){
            cell.score.text = String(self.items[indexPath.row].score)
            cell.review.text = "(\(self.items[indexPath.row].reviewCount))"
            cell.starImage.tintColor = UIColor.systemYellow
        }
        else{
            cell.score.text = "0.0"
            cell.review.text = ""
            cell.starImage.tintColor = UIColor.gray
        }
        
        cell.status.backgroundColor = self.items[indexPath.row].isLogin ? UIColor(rgb: 0x34C759) : UIColor(rgb: 0xAAAAAA)
        
        if self.items[indexPath.row].date != nil {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
            let date = dateFormatter.date(from: self.items[indexPath.row].date ?? "1900-01-01T00:00:00Z")
            let t = dateFormatter.date(from: self.items[indexPath.row].fromTime ?? "1900-01-01T00:00:00Z")
            
            let dateLabel = DateFormatter()
            dateLabel.dateFormat = "MMM dd"
            let timeLabel = DateFormatter()
            timeLabel.dateFormat = "hh:mm a"
            cell.availableDate.text = dateLabel.string(from: date ?? Date()) + ", " + timeLabel.string(from: t ?? Date())
        }
        else {
            cell.availableView.isHidden = true
        }
        // return card
        cell.layer.masksToBounds = false
        cell.layer.shadowOffset = CGSizeZero
        cell.layer.shadowRadius = 5
        cell.layer.shadowOpacity = 0.3
        cell.contentView.layer.cornerRadius = 10
        cell.contentView.layer.borderWidth = 1.0
        cell.contentView.layer.borderColor = UIColor.clear.cgColor
        cell.contentView.layer.masksToBounds = true
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // add the code here to perform action on the cell
        print("didDeselectItemAt" + String(indexPath.row))
        //print( self.items[indexPath.row].fcmDeviceToken ?? "kkk")
        let controller = ActorReaderDetailViewController()
        controller.modalPresentationStyle = .fullScreen
        controller.bookingInfo.uid = self.items[indexPath.row].uid
       
        ActorBookConfirmationViewController.fcmDeviceToken = self.items[indexPath.row].fcmDeviceToken ?? ""
      
        //let transition = CATransition()
        //transition.duration = 0.5 // Set animation duration
        //transition.type = CATransitionType.push // Set transition type to push
        //transition.subtype = CATransitionSubtype.fromRight // Set transition subtype to from right
        //self.view.window?.layer.add(transition, forKey: kCATransition) // Add transition to window layer

        self.present(controller, animated: false)
    }
    
    @IBAction func ShowFilterModal(_ sender: UIButton) {
        let controller = FilterViewController()
        controller.originType = 0
        controller.modalPresentationStyle = .overFullScreen
        controller.parentUIViewController = self
        self.present(controller, animated: true)
        
    }
    
    @IBAction func SelectSponsored(_ sender: UIButton) {
        isSponsored = !isSponsored
        
        if isSponsored {
            sender.backgroundColor = UIColor(rgb: 0x4865FF)
            sender.setTitleColor(.white, for: .normal)
        }
        else {
            sender.backgroundColor = UIColor(rgb: 0xE5E5E5)
            sender.setTitleColor(UIColor(rgb: 0x4865FF), for: .normal)
        }
        fetchReaderList()
    }
    
    @IBAction func SelectAvailableSoon(_ sender: UIButton) {
        isAvailableSoon = !isAvailableSoon
        
        if isAvailableSoon {
            sender.backgroundColor = UIColor(rgb: 0x4865FF)
            sender.setTitleColor(.white, for: .normal)
        }
        else {
            sender.backgroundColor = UIColor(rgb: 0xE5E5E5)
            sender.setTitleColor(UIColor(rgb: 0x4865FF), for: .normal)
        }
        fetchReaderList()
    }
    @IBAction func SelectTopRated(_ sender: UIButton) {
        isTopRated = !isTopRated
        
        if isTopRated {
            sender.backgroundColor = UIColor(rgb: 0x4865FF)
            sender.setTitleColor(.white, for: .normal)
        }
        else {
            sender.backgroundColor = UIColor(rgb: 0xE5E5E5)
            sender.setTitleColor(UIColor(rgb: 0x4865FF), for: .normal)
        }
        fetchReaderList()
    }
    
    @IBAction func ViewAll(_ sender: UIButton) {
        isSponsored = false
        isAvailableSoon = false
        isTopRated = false
        
        btn_sponsored.backgroundColor = UIColor(rgb: 0xE5E5E5)
        btn_sponsored.setTitleColor(UIColor(rgb: 0x4865FF), for: .normal)
        btn_availablesoon.backgroundColor = UIColor(rgb: 0xE5E5E5)
        btn_availablesoon.setTitleColor(UIColor(rgb: 0x4865FF), for: .normal)
        btn_topRate.backgroundColor = UIColor(rgb: 0xE5E5E5)
        btn_topRate.setTitleColor(UIColor(rgb: 0x4865FF), for: .normal)
        
        fetchReaderList()
    }
    
    @IBAction func GoMessageCenter(_ sender: UIButton) {
        let controller = MessageCenterViewController()
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: false)
    }
    
    @IBAction func joinSessionDidTap(_ sender: UIButton) {
        guard let _ = soonBooking else{return}
        
        if(rootTabbar != nil){
            rootTabbar!.selectedIndex = 3
        }
        
// Omitted
//        let conferenceViewController = ConferenceViewController(roomUid: soonBooking!.roomUid, prjName: soonBooking!.projectName, rdrName: "Reader")
//        conferenceViewController.modalPresentationStyle = .fullScreen
//
////        let transition = CATransition()
////        transition.duration = 0.5 // Set animation duration
////        transition.type = CATransitionType.push // Set transition type to push
////        transition.subtype = CATransitionSubtype.fromRight // Set transition subtype to from right
////        self.parentViewController!.view.window?.layer.add(transition, forKey: kCATransition) // Add transition to window layer
//        self.parent!.present(conferenceViewController, animated: false)
    }
    
    func getNextSesstion(uid: String) {
        webAPI.getBookingsInMinsByUid( uid: uid, mins: 5 ) { data, response, error in
        //webAPI.getBookingsInMinsByUid(uid: uid) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            do {
                let respItems = try JSONDecoder().decode([SoonBooking].self, from: data)
                //print(items)
                DispatchQueue.main.async {[self] in
                    if(respItems.count > 0){
                        soonBooking = respItems[0]
                        //print(soonBooking!.roomUid)
                        self.nextSessionLabel.text = "Next Session In 5 Mins"
                        self.joinButton.isEnabled = true
                    }
                    else{
                        soonBooking = nil
                        self.nextSessionLabel.text = "No Upcoming Sessions"
                        self.joinButton.isEnabled = false
                    }
                }
            } catch {
                print(error)
            }
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

extension ActorHomeViewController: BookingNotificationDelegate{
    func bookingAccepted() {
        if let userInfo = UserDefaults.standard.object(forKey: "USER") as? [String:Any] {
            // Use the saved data
            uid = userInfo["uid"] as? String
            getNextSesstion(uid: uid)
        }
    }
}
