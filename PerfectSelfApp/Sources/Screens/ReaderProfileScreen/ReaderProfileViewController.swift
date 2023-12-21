//
//  ReaderProfileViewController.swift
//  PerfectSelf
//
//  Created by Kayan Mishra on 3/8/23.
//  Copyright © 2023 Stas Seldin. All rights reserved.
//

import UIKit
import Photos
import ReadMoreTextView

class ReaderProfileViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, PhotoDelegate {

    var isEditingMode = false
    var uploadType = "image"
    var id = ""
    var min15Rate: Float = 0
    var min30Rate: Float = 0
    var hourlyRate: Float = 0
    var photoType = 0//0: from lib, 1: from camera
    @IBOutlet weak var btn_edit_avatar: UIButton!
    @IBOutlet weak var btn_edit_userinfo: UIButton!
    @IBOutlet weak var btn_edit_experience: UIButton!
    @IBOutlet weak var btn_edit_about: UIButton!
    @IBOutlet weak var btn_edit_skills: UIButton!
    @IBOutlet weak var btn_edit_availability: UIButton!
    @IBOutlet weak var view_edit_hourly_rate: UIStackView!
    
    @IBOutlet weak var view_review: UIView!
    @IBOutlet weak var view_videointro: UIStackView!
    @IBOutlet weak var view_overview: UIStackView!
    @IBOutlet weak var view_container: UIView!
    
    @IBOutlet weak var btn_overview: UIButton!
    @IBOutlet weak var btn_videointro: UIButton!
    @IBOutlet weak var btn_review: UIButton!
    
    @IBOutlet weak var line_overview: UIImageView!
    @IBOutlet weak var line_videointro: UIImageView!
    @IBOutlet weak var line_review: UIImageView!
    
    @IBOutlet weak var readerAvatar: UIImageView!
    @IBOutlet weak var readerUsername: UILabel!
    @IBOutlet weak var readerTitle: UILabel!
    @IBOutlet weak var readerAbout: ReadMoreTextView!
    @IBOutlet weak var quarterHourlyPrice: UILabel!
    @IBOutlet weak var halfHourlyPrice: UILabel!
    @IBOutlet weak var hourlyPrice: UILabel!
    @IBOutlet weak var timeslotList: UICollectionView!
    
    @IBOutlet weak var sessionCounts: UILabel!
    var items = [TimeSlot]()
    let cellsPerRow = 1
    
    @IBOutlet weak var reviewList: UICollectionView!
    var reviews = [Review]()
    @IBOutlet weak var skillList: UICollectionView!
    var skills = [String]()
    var auditionType = 0
    var isExplicitRead = false
    
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
        // Do any additional setup after loading the view.
        line_videointro.alpha = 0
        line_review.alpha = 0
        self.view_videointro.alpha = 0
        self.view_review.alpha = 0
        self.view_overview.frame.origin.x = 0
        self.view_videointro.frame.origin.x = self.view_container.frame.width
        self.view_review.frame.origin.x = self.view_container.frame.width
        
//        btn_edit_avatar.isHidden = true;
//        btn_edit_userinfo.isHidden = true;
//        btn_edit_experience.isHidden = true;
//        btn_edit_about.isHidden = true;
//        btn_edit_skills.isHidden = true;
//        btn_edit_availability.isHidden = true;
//        view_edit_hourly_rate.isHidden = true;
        if let userInfo = UserDefaults.standard.object(forKey: "USER") as? [String:Any] {
            // Use the saved data
            id = userInfo["uid"] as! String
        } else {
            // No data was saved
            print("No data was saved.")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true);
        
        // call API for reader profile
        webAPI.getReaderById(id:self.id) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            do {
                let item = try JSONDecoder().decode(ReaderProfileDetail.self, from: data)
                print(item)
                DispatchQueue.main.async {
                    self.readerUsername.text = item.userName
                    self.readerTitle.text = item.title
                    self.scoreAndReviewCount.text = "\(item.score) (\(item.bookPassCount))"
                    self.readerAbout.text = item.about
                    let readMoreTextAttributes: [NSAttributedString.Key: Any] = [
                        NSAttributedString.Key.foregroundColor: self.view.tintColor!,
                        NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)
                    ]
                    let readLessTextAttributes = [
                        NSAttributedString.Key.foregroundColor: UIColor.red,
                        NSAttributedString.Key.font: UIFont.italicSystemFont(ofSize: 16)
                    ]
                    self.readerAbout.attributedReadMoreText = NSAttributedString(string: "... Read more", attributes: readMoreTextAttributes)
                    self.readerAbout.attributedReadLessText = NSAttributedString(string: " Read less", attributes: readLessTextAttributes)
                    self.readerAbout.maximumNumberOfLines = 7
                    self.readerAbout.shouldTrim = true
                    
                    self.quarterHourlyPrice.text = "$\(item.min15Price)"
                    self.halfHourlyPrice.text = "$\(item.min30Price)"
                    self.hourlyPrice.text = "$\(item.hourlyPrice)"
                    self.skills = item.skills.components(separatedBy: ",")
                    self.skills = self.skills.filter { !$0.isEmpty }
                    self.skillList.reloadData()
                    self.min15Rate = item.min15Price
                    self.min30Rate = item.min30Price
                    self.hourlyRate = item.hourlyPrice
                    self.auditionType = item.auditionType
                    self.isExplicitRead = item.isExplicitRead ?? false
                    self.sessionCounts.text = "\(String(describing: item.sessionCount)) sessions"
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
                        
                        let t = tf.string(from: Date.getDateFromString(date: utcToLocal(dateStr: availibility.fromTime)!)!)
                        
                        let slot = time2slotNo(t)
                        self.items[idx].time.append(Slot(id: availibility.id, slot: slot, duration: 0, isDeleted: false))
                    }
                    self.items = self.items.sorted(by: { Date.getDateFromString(date: $0.date)! < Date.getDateFromString(date: $1.date)! })
                    
                    self.timeslotList.reloadData()
                    self.reviews.removeAll()
                    self.reviews.append(contentsOf: item.reviewLists)
                    self.reviewList.reloadData()
                    self.lbl_noreview.isHidden = !(item.reviewLists.count == 0)
                    if !item.avatarBucketName.isEmpty {
                        let url = "https://\(item.avatarBucketName).s3.us-east-2.amazonaws.com/\(item.avatarKey)"
                        self.readerAvatar.imageFrom(url: URL(string: url)!)
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
                                 DispatchQueue.main.async {
                                     Toast.show(message: "Faild to download video", controller: self)
                                 }
                             }
                             else {
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
            
                DispatchQueue.main.async {
                    hideIndicator(sender: nil);
                    Toast.show(message: "Something went wrong. try again later", controller: self)
                }
            }
        }
        
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
        print("didDeselectItemAt")
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

    @IBAction func EditUserAvatar(_ sender: UIButton) {
        uploadType = "image"
        let controller = TakePhotoViewController()
        controller.modalPresentationStyle = .overFullScreen
        controller.delegate = self
        self.present(controller, animated: true)
    }
    func chooseFromLibrary() {
        photoType = 0
        DispatchQueue.main.async {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    func takePhoto() {
        photoType = 1
        DispatchQueue.main.async {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    func removeCurrentPicture() {
        // call API for remove picture
        //update user profile
        webAPI.updateUserInfo(uid: self.id, userType: -1, bucketName: "", avatarKey: "", username: "", email: "", password: "", firstName: "", lastName: "", dateOfBirth: "", gender: -1, currentAddress: "", permanentAddress: "", city: "", nationality: "", phoneNumber: "", isLogin: true, fcmDeviceToken: "", deviceKind: -1) { data, response, error in
            if error == nil {
                // update local
                // Retrieve the saved data from UserDefaults
                if var userInfo = UserDefaults.standard.object(forKey: "USER") as? [String:Any] {
                    // Use the saved data
                    userInfo["avatarBucketName"] = ""
                    userInfo["avatarKey"] = ""
                    UserDefaults.standard.removeObject(forKey: "USER")
                    UserDefaults.standard.set(userInfo, forKey: "USER")
                    
                    DispatchQueue.main.async {
                        self.readerAvatar.image = UIImage(systemName: "person.fill")
                    }
                    
                } else {
                    // No data was saved
                    print("No data was saved.")
                }
            }
        }
    }
    @IBAction func UploadVideo(_ sender: UIButton) {
        uploadType = "video"
        let videoPicker = UIImagePickerController()
        videoPicker.delegate = self
        videoPicker.sourceType = .photoLibrary
        videoPicker.mediaTypes = ["public.movie"]
        present(videoPicker, animated: true, completion: nil)
    }
    @IBAction func EditUserInfo(_ sender: UIButton) {
        let controller = ReaderProfileEditPersonalInfoViewController()
        controller.username = readerUsername.text ?? ""
        controller.usertitle = readerTitle.text ?? ""
        controller.uid = id
        controller.modalPresentationStyle = .fullScreen
//        let transition = CATransition()
//        transition.duration = 0.5 // Set animation duration
//        transition.type = CATransitionType.push // Set transition type to push
//        transition.subtype = CATransitionSubtype.fromRight // Set transition subtype to from right
//        self.view.window?.layer.add(transition, forKey: kCATransition) // Add transition to window layer
        present(controller, animated: false, completion: nil)
    }
    @IBAction func EditExperience(_ sender: UIButton) {
        let controller = ReaderProfileEditExperienceViewController()
        
        controller.modalPresentationStyle = .fullScreen
//        let transition = CATransition()
//        transition.duration = 0.5 // Set animation duration
//        transition.type = CATransitionType.push // Set transition type to push
//        transition.subtype = CATransitionSubtype.fromRight // Set transition subtype to from right
//        self.view.window?.layer.add(transition, forKey: kCATransition) // Add transition to window layer
        present(controller, animated: false, completion: nil)
    }
    @IBAction func EditAbout(_ sender: UIButton) {
        let controller = ReaderProfileEditAboutViewController() // Instantiate View Controller B
        controller.uid = id
        controller.about = readerAbout.text
        controller.modalPresentationStyle = .fullScreen
//        let transition = CATransition()
//        transition.duration = 0.5 // Set animation duration
//        transition.type = CATransitionType.push // Set transition type to push
//        transition.subtype = CATransitionSubtype.fromRight // Set transition subtype to from right
//        self.view.window?.layer.add(transition, forKey: kCATransition) // Add transition to window layer
        present(controller, animated: false, completion: nil)

    }
    @IBAction func EditSkills(_ sender: UIButton) {
        let controller = ReaderProfileEditSkillViewController()
        
        controller.modalPresentationStyle = .fullScreen
        controller.items = self.skills
        controller.uid = self.id
        controller.auditionType = self.auditionType
        controller.isExplicitRead = self.isExplicitRead
//        let transition = CATransition()
//        transition.duration = 0.5 // Set animation duration
//        transition.type = CATransitionType.push // Set transition type to push
//        transition.subtype = CATransitionSubtype.fromRight // Set transition subtype to from right
//        self.view.window?.layer.add(transition, forKey: kCATransition) // Add transition to window layer
        present(controller, animated: false, completion: nil)
    }
    @IBAction func EditAvailability(_ sender: UIButton) {
        let controller = ReaderProfileEditAvailabilityViewController()
        controller.uid = id
        controller.timeSlotList = self.items
        controller.modalPresentationStyle = .fullScreen
//        let transition = CATransition()
//        transition.duration = 0.5 // Set animation duration
//        transition.type = CATransitionType.push // Set transition type to push
//        transition.subtype = CATransitionSubtype.fromRight // Set transition subtype to from right
//        self.view.window?.layer.add(transition, forKey: kCATransition) // Add transition to window layer
        present(controller, animated: false, completion: nil)
    }
    @IBAction func EditHourlyRate(_ sender: UIButton) {
        let controller = ReaderProfileEditHourlyRateViewController()
        controller.min15rate = min15Rate
        controller.min30rate = min30Rate
        controller.hourlyrate = hourlyRate
        controller.uid = id
        controller.modalPresentationStyle = .fullScreen
//        let transition = CATransition()
//        transition.duration = 0.5 // Set animation duration
//        transition.type = CATransitionType.push // Set transition type to push
//        transition.subtype = CATransitionSubtype.fromRight // Set transition subtype to from right
//        self.view.window?.layer.add(transition, forKey: kCATransition) // Add transition to window layer
        present(controller, animated: false, completion: nil)
    }
    
    @IBAction func EditHourlyRate1(_ sender: UIButton) {
        let controller = ReaderProfileEditHourlyRateViewController()
        controller.min15rate = min15Rate
        controller.min30rate = min30Rate
        controller.hourlyrate = hourlyRate
        controller.uid = id
        controller.modalPresentationStyle = .fullScreen
//        let transition = CATransition()
//        transition.duration = 0.5 // Set animation duration
//        transition.type = CATransitionType.push // Set transition type to push
//        transition.subtype = CATransitionSubtype.fromRight // Set transition subtype to from right
//        self.view.window?.layer.add(transition, forKey: kCATransition) // Add transition to window layer
        present(controller, animated: false, completion: nil)
    }
    @IBAction func EditProfile(_ sender: UIButton) {

        if isEditingMode {
            isEditingMode = false;
            btn_edit_avatar.isHidden = true;
            btn_edit_userinfo.isHidden = true;
            btn_edit_experience.isHidden = true;
            btn_edit_about.isHidden = true;
            btn_edit_skills.isHidden = true;
            btn_edit_availability.isHidden = true;
            view_edit_hourly_rate.isHidden = true;
        }
        else {
            isEditingMode = true;
            btn_edit_avatar.isHidden = false;
            btn_edit_userinfo.isHidden = false;
            btn_edit_experience.isHidden = false;
            btn_edit_about.isHidden = false;
            btn_edit_skills.isHidden = false;
            btn_edit_availability.isHidden = false;
            view_edit_hourly_rate.isHidden = false;
        }
    }
    
    @IBAction func SignOut(_ sender: UIButton) {
        // Optional: Dismiss the tab bar controller
        // Delete localstorage
        showIndicator(sender: nil, viewController: self)
        webAPI.updateOnlineState(uid: self.id, newState: false) { data, response, error in
            DispatchQueue.main.async {
                hideIndicator(sender: nil)
            }
            guard error == nil else {
                return
            }
            DispatchQueue.main.async {
                UserDefaults.standard.removeObject(forKey: "USER")
                UserDefaults.standard.removeObject(forKey: "USER_EMAIL")
                UserDefaults.standard.removeObject(forKey: "USER_PWD")

                let controller = LoginViewController()
                controller.modalPresentationStyle = .fullScreen
                self.present(controller, animated: false)
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

/// Mark:https://perfectself-avatar-bucket.s3.us-east-2.amazonaws.com/{room-id-000-00}/{647730C6-5E86-483A-859E-5FBF05767018.jpeg}
extension ReaderProfileViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate  {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            //Omitted let awsUpload = AWSMultipartUpload()
            DispatchQueue.main.async {
                showIndicator(sender: nil, viewController: self, color:UIColor.white)
            }
         
            if self.uploadType == "image" {
                // Get the URL of the selected image
                var avatarUrl: URL? = nil
                //Upload audio at first
                guard let image = (self.photoType == 0 ? info[.originalImage] : info[.editedImage]) as? UIImage else {
                    //dismiss(animated: true, completion: nil)
                    DispatchQueue.main.async {
                        hideIndicator(sender: nil)
                    }
                    return
                }
                // save to local and get URL
                if self.photoType == 1 {
                    let imgName = UUID().uuidString
                    let documentDirectory = NSTemporaryDirectory()
                    let localPath = documentDirectory.appending(imgName)

                    let data = image.jpegData(compressionQuality: 0.3)! as NSData
                    data.write(toFile: localPath, atomically: true)
                    avatarUrl = URL.init(fileURLWithPath: localPath)
                }
                else {
                    avatarUrl = info[.imageURL] as? URL
                }
                
                uploadAvatar(prefix: self.id, avatarUrl: avatarUrl, imgControl: self.readerAvatar, controller: self)
            }
            else if self.uploadType == "video" {
                if let videoURL = info[.mediaURL] as? URL {
                    //Then Upload video
                    awsUpload.multipartUpload(filePath: videoURL, bucketName: "video-client-upload-123456798", prefixKey: "intro-video/\(self.id)/") { (error: Error?) -> Void in
                        if(error == nil)
                        {
                            DispatchQueue.main.async {
                                hideIndicator(sender: nil)
                                Toast.show(message: "file upload completed.", controller: self)
                                // update avatar
                                let url = "https://video-client-upload-123456798.s3.us-east-2.amazonaws.com/intro-video/\(self.id)/\(String(describing: videoURL.lastPathComponent))"
                                let downloadImageURL = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)! as NSString
                                
                                let requestURL: NSURL = NSURL(string: downloadImageURL as String)!
                                
                                let request = URLRequest(url: requestURL as URL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
                                let config = URLSessionConfiguration.default
                                let session = URLSession(configuration: config)
                                let task = session.dataTask(with: request, completionHandler: {(data, response, error) in
                                    
                                     if error != nil {
                                         DispatchQueue.main.async {
                                             Toast.show(message: "Faild to download video", controller: self)
                                         }
                                     }
                                     else {
                                         let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
                                         let filePath = URL(fileURLWithPath: "\(documentsPath)/tempFile.mp4")
                                         DispatchQueue.main.async {
                                             do{
                                                 try data!.write(to: filePath)
                                                 self.setupPlayer(videoUrl: filePath)
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
                                //update user profile
                                webAPI.uploadUserIntroVideo(uid: self.id, bucketName: "video-client-upload-123456798", videoKey: "intro-video/\(self.id)/\(videoURL.lastPathComponent)") { data, response, error in
                                    if error == nil {
                                        // successfully update db
                                    }
                                }
                                
                            }
                        }
                        else
                        {
                            DispatchQueue.main.async {
                                hideIndicator(sender: nil)
                                Toast.show(message: "Failed to upload file, Try again later!", controller: self)
                            }
                        }
                    }
                }
            }
            else {
                print("Oops!, unknown upload")
            }
            
               
        }//DispatchQueue.global
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension ReaderProfileViewController: PlayerViewDelegate {
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
