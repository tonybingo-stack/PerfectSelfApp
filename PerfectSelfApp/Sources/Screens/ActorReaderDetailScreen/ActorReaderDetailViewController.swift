//
//  ActorReaderDetailViewController.swift
//  PerfectSelf
//
//  Created by Kayan Mishra on 3/8/23.
//  Copyright © 2023 Stas Seldin. All rights reserved.
//

import UIKit
import ReadMoreTextView

class ActorReaderDetailViewController: UIViewController , UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    //Omitted var uid: String = ""
    var bookingInfo: BookingInfo = BookingInfo()
    
    @IBOutlet weak var btn_overview: UIButton!
    @IBOutlet weak var btn_videointro: UIButton!
    @IBOutlet weak var btn_review: UIButton!
    
    @IBOutlet weak var line_overview: UIImageView!
    @IBOutlet weak var line_videointro: UIImageView!
    @IBOutlet weak var line_review: UIImageView!
    
    @IBOutlet weak var view_review: UIView!
    @IBOutlet weak var view_videointro: UIStackView!
    @IBOutlet weak var view_overview: UIStackView!
   
    @IBOutlet weak var view_container: UIView!
    // info
    @IBOutlet weak var view_main: UIStackView!
    @IBOutlet weak var reader_avatar: UIImageView!
    @IBOutlet weak var reader_name: UILabel!
    @IBOutlet weak var reader_title: UILabel!
    @IBOutlet weak var reader_hourly: UILabel!
    @IBOutlet weak var reader_quarter_hourly: UILabel!
    @IBOutlet weak var sessionCounts: UILabel!
    @IBOutlet weak var reader_half_hourly: UILabel!
    @IBOutlet weak var reader_about: ReadMoreTextView!
    @IBOutlet weak var timeslotList: UICollectionView!
    
    var items = [TimeSlot]()
    let cellsPerRow = 1
    var videoUrl: URL!
    
    @IBOutlet weak var reviewList: UICollectionView!
    var reviews = [Review]()
    
    @IBOutlet weak var skillList: UICollectionView!
    var skills = [String]()
    
    @IBOutlet weak var lbl_noreview: UILabel!
    @IBOutlet var btnPlayPause: UIButton!
    @IBOutlet var slider: UISlider!

    var isPlaying: Bool = false {
        didSet {
            if isPlaying {
                btnPlayPause.setImage(UIImage(named: "pause"), for: .normal)
            } else {
                btnPlayPause.setImage(UIImage(named: "play"), for: .normal)
            }
        }
    }

    @IBOutlet var playerView: PlayerView!
    @IBOutlet weak var scoreAndReviewCount: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName: "TimeSlotCollectionViewCell", bundle: nil)
        timeslotList.register(nib, forCellWithReuseIdentifier: "Time Slot Collection View Cell")
        timeslotList.dataSource = self
        timeslotList.delegate = self
        timeslotList.allowsSelection = true
        
        let nib1 = UINib(nibName: "ReviewCell", bundle: nil)
        reviewList.register(nib1, forCellWithReuseIdentifier: "Review Cell")
        reviewList.dataSource = self
        reviewList.delegate = self
        reviewList.allowsSelection = true
        
        let nib2 = UINib(nibName: "SkillCell", bundle: nil)
        skillList.register(nib2, forCellWithReuseIdentifier: "Skill Cell")
        skillList.dataSource = self
        skillList.delegate = self
        skillList.allowsSelection = true
        // Do any additional setup after loading the view.        view_main.layer.cornerRadius = 25
        view_main.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        line_videointro.alpha = 0
        line_review.alpha = 0
        self.view_videointro.alpha = 0
        self.view_review.alpha = 0
        self.view_overview.frame.origin.x = 0
        self.view_videointro.frame.origin.x = self.view_container.frame.width
        self.view_review.frame.origin.x = self.view_container.frame.width
        
        // call api for reader details
        showIndicator(sender: nil, viewController: self)
        
        webAPI.getReaderById(id: bookingInfo.uid) { data, response, error in
            DispatchQueue.main.async {
                hideIndicator(sender: nil)
            }
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            do {
                let item = try JSONDecoder().decode(ReaderProfileDetail.self, from: data)
                DispatchQueue.main.async {
                    self.lbl_noreview.text = "\(item.userName) has no review yet"
                    self.reader_name.text = item.userName
                    self.reader_title.text = item.title
                    self.scoreAndReviewCount.text = "\(item.score) (\(item.bookPassCount))"
                    self.reader_about.text = item.about
                    let readMoreTextAttributes: [NSAttributedString.Key: Any] = [
                        NSAttributedString.Key.foregroundColor: self.view.tintColor!,
                        NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)
                    ]
                    let readLessTextAttributes = [
                        NSAttributedString.Key.foregroundColor: UIColor.red,
                        NSAttributedString.Key.font: UIFont.italicSystemFont(ofSize: 16)
                    ]
                    self.reader_about.attributedReadMoreText = NSAttributedString(string: "... Read more", attributes: readMoreTextAttributes)
                    self.reader_about.attributedReadLessText = NSAttributedString(string: " Read less", attributes: readLessTextAttributes)
                    self.reader_about.maximumNumberOfLines = 7
                    self.reader_about.shouldTrim = true
                    
                    self.reader_hourly.text = "$\(item.hourlyPrice)"
                    self.reader_quarter_hourly.text = "$\(item.min15Price)"
                    self.reader_half_hourly.text = "$\(item.min30Price)"
                    self.sessionCounts.text = "\(String(describing: item.sessionCount)) sessions"	
                    print(item.sessionCount)//REFME
                    self.skills.removeAll()
                    if !item.skills.isEmpty {
                        self.skills = item.skills.components(separatedBy: ",")
                    }
                    self.skills = self.skills.filter { !$0.isEmpty }
                    self.skillList.reloadData()
 
                    self.items.removeAll()
//                    self.items.append(contentsOf: item.allAvailability)
                    
                    for availibility in item.allAvailability {
                        let df = DateFormatter()
                        df.dateFormat = "yyyy-MM-dd"
                        let tf = DateFormatter()
                        tf.dateFormat = "HH"
                        
                        let index = self.items.firstIndex(where: { df.string(from: Date.getDateFromString(date: $0.date)!) == df.string(from: Date.getDateFromString(date: utcToLocal(dateStr: availibility.date)!)!) })
                        if index == nil {
                            self.items.append(TimeSlot(date: utcToLocal(dateStr: availibility.date)!, time: [Slot](), repeatFlag: 0, isStandBy: false))
                        }
                        let idx = index ?? self.items.count - 1
                        
                        let t = tf.string(from:Date.getDateFromString(date:  utcToLocal(dateStr: availibility.fromTime)!)!)
                        let slot = time2slotNo(t)
                        self.items[idx].time.append(Slot(id: 0, slot: slot, duration: 0, isDeleted: false))
                    }
                    self.items = self.items.sorted(by: { Date.getDateFromString(date: $0.date)! < Date.getDateFromString(date: $1.date)! })
                    self.timeslotList.reloadData()
                    self.reviews.removeAll()
                    self.reviews.append(contentsOf: item.reviewLists)
                    self.reviewList.reloadData()
                    self.lbl_noreview.isHidden = !(item.reviewLists.count == 0)
                    
                    if !item.avatarBucketName.isEmpty {
                        let url = "https://\(item.avatarBucketName).s3.us-east-2.amazonaws.com/\(item.avatarKey)"
                        self.reader_avatar.imageFrom(url: URL(string: url)!)
                    }
                    if !item.introVideoKey.isEmpty {
                        let vUrl = "https://\(item.introBucketName).s3.us-east-2.amazonaws.com/\(item.introVideoKey)"
                        
                        let downloadImageURL = vUrl.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)! as NSString
                        
                        let requestURL: NSURL = NSURL(string: downloadImageURL as String)!
                        
                        let request = URLRequest(url: requestURL as URL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
                        let config = URLSessionConfiguration.default
                        let session = URLSession(configuration: config)
                        let task = session.dataTask(with: request, completionHandler: {(data, response, error) in
                            DispatchQueue.main.async {
//                                hideIndicator(sender: nil)
                            }
                            
                             if error != nil {
                                  //print(error!.localizedDescription)
                                 DispatchQueue.main.async {
                                     Toast.show(message: "Faild to download video", controller: self)
                                 }
                             }
                             else {
                                 //print(response)//print(response ?? default "")
                                 let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
                                 let filePath = URL(fileURLWithPath: "\(documentsPath)/tempFile.mp4")
                                 DispatchQueue.main.async {
                                     do{
                                         try data!.write(to: filePath)
                                         self.setupPlayer(videoUrl: filePath)
//                                         self.playerView.url = filePath
                                     }
                                     catch{
                                         print("error: \(error)")
                                     }
                                 }
                             }
                         })
                        DispatchQueue.main.async {
                            task.resume()
                        }
                    }
                }
            }
            catch {
                print(error)
                DispatchQueue.main.async {
                    Toast.show(message: "Something went wrong. try again later", controller: self)
                }
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true);
    }
    func setupPlayer(videoUrl: URL?) {
        playerView.url = videoUrl
        playerView.delegate = self
        slider.minimumValue = 0
    }
    @IBAction func btnPlayPauseClicked(_ sender: UIButton) {
        if playerView.rate > 0 {
            playerView.pause()
            isPlaying = false
        } else {
           playerView.play()
           isPlaying = true
        }
    }
    
    // MARK: - Time Slot List Delegate.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == timeslotList {
            return self.items.count
        }
        else if collectionView == reviewList {
            return self.reviews.count
        }
        else {
            return self.skills.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpace = flowLayout.sectionInset.top
        + flowLayout.sectionInset.bottom
        + (flowLayout.minimumLineSpacing * CGFloat(cellsPerRow - 1))
        let size = (collectionView.bounds.width - totalSpace) / CGFloat(cellsPerRow)
        if collectionView == timeslotList {
            return CGSize(width: 80, height: 74)
        }
        else if collectionView == reviewList {
            let reviewText = self.reviews[indexPath.row].readerReview
            let reviewTextHeight = reviewText.height(withConstrainedWidth: size-16, font: UIFont.systemFont(ofSize: 12))
            
            let totalHeight = reviewTextHeight + 75 // add 56 for the height of the profile image and padding

            return CGSize(width: size, height: totalHeight)
        }
        else {
            let skill = self.skills[indexPath.row]
            let font = UIFont.systemFont(ofSize: 14)
            let size = (skill as NSString).size(withAttributes: [.font: font])
            return CGSize(width: size.width + 20, height: 30)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == timeslotList {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Time Slot Collection View Cell", for: indexPath) as! TimeSlotCollectionViewCell

            let date = Date.getDateFromString(date: self.items[indexPath.row].date)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEE"
            let weekDay = dateFormatter.string(from: date ?? Date())
            
            dateFormatter.dateFormat = "MMM dd"
            let dayMonth = dateFormatter.string(from: date ?? Date())
            
            cell.lbl_num_slot.text = "\(self.items[indexPath.row].time.count) slots";
            cell.lbl_weekday.text = weekDay
            cell.lbl_date_month.text = dayMonth
            // return card
            cell.layer.masksToBounds = false
            cell.layer.shadowOffset = CGSizeZero
            cell.layer.shadowRadius = 8
            cell.layer.shadowOpacity = 0.2
            cell.contentView.layer.cornerRadius = 5
            cell.contentView.layer.borderWidth = 1.0
            cell.contentView.layer.borderColor = UIColor.gray.cgColor
            cell.contentView.layer.masksToBounds = true
            
            return cell
        }
        else if collectionView == reviewList {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Review Cell", for: indexPath) as! ReviewCell

            cell.lbl_name.text = self.reviews[indexPath.row].actorName
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
            let date = dateFormatter.date(from: self.reviews[indexPath.row].bookStartTime)
            dateFormatter.dateFormat = "MMM dd, yyyy"
            cell.lbl_reviewDate.text = dateFormatter.string(from: date ?? Date())
//            cell.lbl_score.text = String(self.reviews[indexPath.row].readerScore)
            //prepare star
            cell.img_star1.tintColor = self.reviews[indexPath.row].readerScore >= 1 ? UIColor(rgb: 0xFFCC00) : UIColor(rgb: 0x9498AB)
            cell.img_star2.tintColor = self.reviews[indexPath.row].readerScore >= 2 ? UIColor(rgb: 0xFFCC00) : UIColor(rgb: 0x9498AB)
            cell.img_star3.tintColor = self.reviews[indexPath.row].readerScore >= 3 ? UIColor(rgb: 0xFFCC00) : UIColor(rgb: 0x9498AB)
            cell.img_star4.tintColor = self.reviews[indexPath.row].readerScore >= 4 ? UIColor(rgb: 0xFFCC00) : UIColor(rgb: 0x9498AB)
            cell.img_star5.tintColor = self.reviews[indexPath.row].readerScore >= 5 ? UIColor(rgb: 0xFFCC00) : UIColor(rgb: 0x9498AB)
            
            cell.text_review.text = self.reviews[indexPath.row].readerReview
            if self.reviews[indexPath.row].actorAvatarKey != nil{
                let url = "https://\(self.reviews[indexPath.row].actorBucketName!).s3.us-east-2.amazonaws.com/\(self.reviews[indexPath.row].actorAvatarKey!)"
                cell.img_avatar.imageFrom(url: URL(string: url)!)
            }
    //        cell.layer.masksToBounds = false
    //        cell.layer.shadowOffset = CGSizeZero
    //        cell.layer.shadowRadius = 8
    //        cell.layer.shadowOpacity = 0.2
            cell.contentView.layer.cornerRadius = 10
            cell.contentView.layer.borderWidth = 1.0
            cell.contentView.layer.borderColor = UIColor.gray.cgColor
            cell.contentView.layer.masksToBounds = true
            
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Skill Cell", for: indexPath) as! SkillCell

            cell.skillName.text = self.skills[indexPath.row]
            cell.btn_disselect.isHidden = true
    //        cell.layer.masksToBounds = false
    //        cell.layer.shadowOffset = CGSizeZero
    //        cell.layer.shadowRadius = 8
    //        cell.layer.shadowOpacity = 0.2
            cell.contentView.layer.cornerRadius = 10
            cell.contentView.layer.borderWidth = 1.0
            cell.contentView.layer.borderColor = UIColor.gray.cgColor
            cell.contentView.layer.masksToBounds = true
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // add the code here to perform action on the cell
        if collectionView == timeslotList {
            
            bookingInfo.readerUid = bookingInfo.uid
            bookingInfo.readerName = self.reader_name.text ?? "Reader"
            let controller = ActorBookAppointmentViewController(bookingInfo);
            controller.selectedDate = self.items[indexPath.row].date
            controller.timeSlotList = self.items
            controller.modalPresentationStyle = .fullScreen
            self.present(controller, animated: false)
        }
    }
    
    @IBAction func ShowOverview(_ sender: UIButton) {
        sender.tintColor = UIColor(rgb: 0x4063FF)
        btn_videointro.tintColor = .black
        btn_review.tintColor = .black
        line_overview.alpha = 1
        line_videointro.alpha = 0
        line_review.alpha = 0
        
        UIView.animate(withDuration: 0.5, animations: {
            self.view_overview.alpha = 1
            self.view_videointro.alpha = 0
            self.view_review.alpha = 0
            self.view_overview.frame.origin.x = 0
            self.view_videointro.frame.origin.x = self.view_container.frame.width
            self.view_review.frame.origin.x = self.view_container.frame.width
        })        
    }
    
    @IBAction func ShowVideoIntro(_ sender: UIButton) {
        sender.tintColor = UIColor(rgb: 0x4063FF)
        btn_overview.tintColor = .black
        btn_review.tintColor = .black
        line_overview.alpha = 0
        line_videointro.alpha = 1
        line_review.alpha = 0
        
        UIView.animate(withDuration: 0.5, animations: {
            self.view_overview.alpha = 0
            self.view_videointro.alpha = 1
            self.view_review.alpha = 0
            self.view_overview.frame.origin.x = -self.view_container.frame.width
            self.view_videointro.frame.origin.x = 0
            self.view_review.frame.origin.x = self.view_container.frame.width
        })
    }
    
    @IBAction func ShowReview(_ sender: UIButton) {
        sender.tintColor = UIColor(rgb: 0x4063FF)
        btn_overview.tintColor = .black
        btn_videointro.tintColor = .black
        line_overview.alpha = 0
        line_videointro.alpha = 0
        line_review.alpha = 1
        
        UIView.animate(withDuration: 0.5, animations: {
            self.view_overview.alpha = 0
            self.view_videointro.alpha = 0
            self.view_review.alpha = 1
            self.view_overview.frame.origin.x = -self.view_container.frame.width
            self.view_videointro.frame.origin.x = -self.view_container.frame.width
            self.view_review.frame.origin.x = 0
        })
    }
    @IBAction func BookAppointment(_ sender: UIButton) {
        bookingInfo.readerUid = bookingInfo.uid
        bookingInfo.readerName = self.reader_name.text ?? "Reader"
        let controller = ActorBookAppointmentViewController(bookingInfo);
        controller.timeSlotList = self.items
        controller.modalPresentationStyle = .fullScreen
     
//        let transition = CATransition()
//        transition.duration = 0.5 // Set animation duration
//        transition.type = CATransitionType.push // Set transition type to push
//        transition.subtype = CATransitionSubtype.fromRight // Set transition subtype to from right
//        self.view.window?.layer.add(transition, forKey: kCATransition) // Add transition to window layer
        self.present(controller, animated: false)
    }
    

    @IBAction func GoBack(_ sender: UIButton) {
//        _ = navigationController?.popViewController(animated: true)
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

extension ActorReaderDetailViewController: PlayerViewDelegate {
    func playerVideo(player: PlayerView, currentTime: Double) {
        slider.value = Float(currentTime)
    }

    func playerVideo(player: PlayerView, duration: Double) {
        slider.maximumValue =  Float(duration)
    }

    func playerVideo(player: PlayerView, statusItemPlayer: AVPlayer.Status, error: Error?) {
        //
    }

    func playerVideo(player: PlayerView, statusItemPlayer: AVPlayerItem.Status, error: Error?) {
        //
    }

    func playerVideoDidEnd(player: PlayerView) {
        isPlaying = false
    }
}
