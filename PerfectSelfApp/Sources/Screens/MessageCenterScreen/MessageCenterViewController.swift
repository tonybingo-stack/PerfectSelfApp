//
//  ActorMessageCenterViewController.swift
//  PerfectSelf
//
//  Created by user232392 on 3/16/23.
//  Copyright © 2023 Stas Seldin. All rights reserved.
//

import UIKit

class MessageCenterViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    let divide = UIImage(named: "filter_divide");
    @IBOutlet weak var chatCardList: UICollectionView!
    @IBOutlet weak var btn_back: UIButton!
    
    @IBOutlet weak var noChat: UILabel!
    var items = [ChatChannel]()
    let cellsPerRow = 1
    var uid = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName: "ChatCardCollectionViewCell", bundle: nil)
        chatCardList.register(nib, forCellWithReuseIdentifier: "Chat Card Collection View Cell")
        chatCardList.dataSource = self
        chatCardList.delegate = self
        chatCardList.allowsSelection = true
        // Do any additional setup after loading the view.
        self.navigationItem.setHidesBackButton(true, animated: false)
        // Retrieve the saved data from UserDefaults
        if let userInfo = UserDefaults.standard.object(forKey: "USER") as? [String:Any] {
            // Use the saved data
            let userType = userInfo["userType"] as? Int
            uid = userInfo["uid"] as! String
            btn_back.isHidden = userType == 4
        } else {
            // No data was saved
            print("No data was saved.")
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        
        // call API for chat history
        fetchChatChannels()
    }
    func fetchChatChannels() {
        // call API for chat channels
        showIndicator(sender: nil, viewController: self)
        webAPI.getChannelHistoryByUid(uid: uid) { data, response, error in
            DispatchQueue.main.async {
                hideIndicator(sender: nil)
            }
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                DispatchQueue.main.async {
                    Toast.show(message: "error while fetch chat history. try again later", controller: self)
                }
                return
            }
            do {
                let respItems = try JSONDecoder().decode([ChatChannel].self, from: data)
                //print(items)
                DispatchQueue.main.async {
                    self.items.removeAll()
                    self.items.append(contentsOf: respItems)
                    self.noChat.isHidden = (respItems.count != 0)
                    //UTC2local
                    for index in self.items.indices {
                        self.items[index].sendTime = utcToLocal(dateStr: self.items[index].sendTime)!
                    }
                    self.chatCardList.reloadData()
                }

            } catch {
                print(error)
                DispatchQueue.main.async {
                    Toast.show(message: "Fetching chat channel history failed! please try again.", controller: self)
                }
            }
        }
    }
    // MARK: - ChatCard List Delegate.
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
        return CGSize(width: size, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Chat Card Collection View Cell", for: indexPath) as! ChatCardCollectionViewCell
        let card = self.items[indexPath.row]
        if card.senderUid == uid {
            if card.receiverAvatarKey != nil {
                let url = "https://\(card.receiverAvatarBucket!).s3.us-east-2.amazonaws.com/\(card.receiverAvatarKey!)"
                cell.img_avatar.imageFrom(url: URL(string: url)!)
            }
        
            cell.view_status.backgroundColor = card.receiverIsOnline ? UIColor(rgb: 0x34C759) : UIColor(rgb: 0xAAAAAA)
            cell.lbl_name.text = card.receiverName
            cell.lbl_message.text = card.message
        }
        else {
            if card.senderAvatarKey != nil {
                let url = "https://\(card.senderAvatarBucket!).s3.us-east-2.amazonaws.com/\(card.senderAvatarKey!)"
                cell.img_avatar.imageFrom(url: URL(string: url)!)
            }
        
            cell.view_status.backgroundColor = card.senderIsOnline ? UIColor(rgb: 0x34C759) : UIColor(rgb: 0xAAAAAA)
            cell.lbl_name.text = card.senderName
            cell.lbl_message.text = card.message
        }
        
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.maximumUnitCount = 1
        formatter.allowedUnits = [.day]

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd"

        let df = DateFormatter()
        df.dateFormat =  "yyyy-MM-dd'T'HH:mm:ss.SSSSSSS"
        let someDate = df.date(from: card.sendTime) ?? Date()
       
        let currentDateComponents = Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        let thisWeekStart = Calendar.current.date(from: currentDateComponents)!
        let thisWeekEnd = Calendar.current.date(byAdding: .day, value: 6, to: thisWeekStart)!

        if Calendar.current.isDateInToday(someDate) {
            // Display the time only
            dateFormatter.dateFormat = "h:mm a"
            let timeString = dateFormatter.string(from: someDate)
            print(timeString)
            cell.lbl_time.text = timeString

        } else if Calendar.current.isDateInYesterday(someDate) {
            cell.lbl_time.text = "Yesterday"
        } else if someDate >= thisWeekStart && someDate <= thisWeekEnd {
            let daysAgoString = formatter.string(from: someDate, to: Date())!
            let daysAgo = daysAgoString.replacingOccurrences(of: ",", with: "")
            let dateString = "\(daysAgo) ago"
            print(dateString)
            cell.lbl_time.text = dateString
        }
        else {
            // Display the month and day
            let dateString = dateFormatter.string(from: someDate)
            print(dateString)
            cell.lbl_time.text = dateString
        }
        // unread number
        if self.items[indexPath.row].senderUid == uid {
            cell.view_unread.isHidden = true
            cell.lbl_unviewednum.text = String(self.items[indexPath.row].unreadCount)
        }
        else {
            cell.view_unread.isHidden = self.items[indexPath.row].unreadCount == 0
            cell.lbl_unviewednum.text = String(self.items[indexPath.row].unreadCount)
        }
        
        // return card
//        cell.layer.masksToBounds = false
//        cell.layer.shadowOffset = CGSize(width: 3,height: 3)
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
        let card = self.items[indexPath.row]
        var url: String? = nil
        var name: String!
        var uuid: String!
        if card.senderUid == uid {
            if card.receiverAvatarKey != nil {
                url = "https://\(card.receiverAvatarBucket!).s3.us-east-2.amazonaws.com/\(card.receiverAvatarKey!)"
            }
            name = card.receiverName
            uuid = card.receiverUid
        }
        else {
            if card.senderAvatarKey != nil {
                url = "https://\(card.senderAvatarBucket!).s3.us-east-2.amazonaws.com/\(card.senderAvatarKey!)"
            }
            name = card.senderName
            uuid = card.senderUid
        }
        let roomUid = card.roomUid
        let controller = ChatViewController(roomUid: roomUid, url: url, name: name, uid: uuid);
        controller.modalPresentationStyle = .fullScreen
        let transition = CATransition()
        transition.duration = 0.5 // Set animation duration
        transition.type = CATransitionType.push // Set transition type to push
        transition.subtype = CATransitionSubtype.fromRight // Set transition subtype to from right
        self.view.window?.layer.add(transition, forKey: kCATransition) // Add transition to window layer
        
        self.present(controller, animated: false)
    }
  
    @IBAction func GoBack(_ sender: UIButton) {
//        self.navigationController?.popViewController(animated: true)
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
