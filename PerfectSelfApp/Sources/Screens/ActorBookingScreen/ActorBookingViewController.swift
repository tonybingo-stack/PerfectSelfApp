//
//  ActorBookingViewController.swift
//  PerfectSelf
//
//  Created by Kayan Mishra on 3/8/23.
//  Copyright © 2023 Stas Seldin. All rights reserved.
//

import UIKit

class ActorBookingViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, BookDelegate {
    func setBookId(controller: UICollectionViewCell, id: Int, name:String) {
        bookId = id
        lbl_readerName.text = "How's your experience with \(name)?"
        view_rate.isHidden = false
        backView.isHidden = false
    }
    var uid = ""
    var bookId = 0
    var score:Float = 0.0
    var bookType = 1//upcoming
    var searchText = ""
    @IBOutlet weak var btn_upcoming: UIButton!
    @IBOutlet weak var btn_past: UIButton!
    @IBOutlet weak var btn_pending: UIButton!
    
    @IBOutlet weak var line_upcoming: UIImageView!
    @IBOutlet weak var line_pending: UIImageView!
    @IBOutlet weak var line_past: UIImageView!

    @IBOutlet weak var spin: UIActivityIndicatorView!
    @IBOutlet weak var bookList: UICollectionView!

    var items = [BookingCard]()

    @IBOutlet weak var lbl_readerName: UILabel!
    @IBOutlet weak var view_rate: UIStackView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var img_star1: UIImageView!
    @IBOutlet weak var img_star2: UIImageView!
    @IBOutlet weak var img_star3: UIImageView!
    @IBOutlet weak var img_star4: UIImageView!
    @IBOutlet weak var img_star5: UIImageView!
    @IBOutlet weak var text_feedback: UITextView!
    
    let cellsPerRow = 1
    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName: "BookingCollectionViewCell", bundle: nil)
        bookList.register(nib, forCellWithReuseIdentifier: "Booking Collection View Cell")
        bookList.dataSource = self
        bookList.delegate = self
        bookList.allowsSelection = true
        // Do any additional setup after loading the view.
        line_pending.isHidden = true
        line_past.isHidden = true
        
        view_rate.isHidden = true
        backView.isHidden = true
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
        fetchBookList()
    }
    
    @IBAction func Search(_ sender: UITextField) {
        self.searchText = sender.text ?? ""
        fetchBookList()
    }
    func fetchBookList() {
        //call API to fetch booking list
        spin.isHidden = false
        spin.startAnimating()
         
        webAPI.getBookingsByUid(uid: uid, bookType: self.bookType, name: self.searchText) { data, response, error in
            DispatchQueue.main.async {
                self.spin.stopAnimating()
                self.spin.isHidden = true
            }
            
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            do {
                let respItems = try JSONDecoder().decode([BookingCard].self, from: data)
                //print(items)
                DispatchQueue.main.async {
                    self.items.removeAll()
                    self.items.append(contentsOf: respItems)
                    
                    //UTC2local
                    for index in self.items.indices {
                        self.items[index].bookStartTime = utcToLocal(dateStr: self.items[index].bookStartTime)!
                        self.items[index].bookEndTime = utcToLocal(dateStr: self.items[index].bookEndTime)!
                    }
 //                    for (i, reader) in items.enumerated() {
 //                    }
                    self.bookList.reloadData()
                }

            } catch {
                print(error)
                DispatchQueue.main.async {
                    Toast.show(message: "Fetching reader list failed! please try again.", controller: self)
                }
            }
        }
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
        let height = Int(Double(size) * 0.45)
        return CGSize(width: size, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Booking Collection View Cell", for: indexPath) as! BookingCollectionViewCell
        let roomUid = self.items[indexPath.row].roomUid
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let datestart = dateFormatter.date(from: self.items[indexPath.row].bookStartTime)
        let dateend = dateFormatter.date(from: self.items[indexPath.row].bookEndTime)
        
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = "MMM dd, yyyy"
        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = "hh:mm a zzz"
        
        cell.bookType = bookType
        cell.readerType = "actor"
        cell.projectName = self.items[indexPath.row].projectName
        cell.name = self.items[indexPath.row].readerName
        cell.selfName = self.items[indexPath.row].actorName
        cell.uid = self.items[indexPath.row].readerUid
        cell.muid = self.items[indexPath.row].actorUid
        var url: String?
        if self.items[indexPath.row].readerBucketName != nil {
            url = "https://\(self.items[indexPath.row].readerBucketName!).s3.us-east-2.amazonaws.com/\(self.items[indexPath.row].readerAvatarKey!)"
        }
        cell.url = url
        cell.review = self.items[indexPath.row].readerReview
        cell.script = self.items[indexPath.row].scriptFile ?? ""
        cell.scriptBucketName = self.items[indexPath.row].scriptBucket ?? ""
        cell.scriptKey = self.items[indexPath.row].scriptKey ?? ""
        cell.id = self.items[indexPath.row].id
        cell.lbl_name.text = self.items[indexPath.row].readerName;
        cell.lbl_date.text = dateFormatter1.string(from: datestart ?? Date())
        cell.lbl_time.text = dateFormatter2.string(from: datestart ?? Date()) + "-" + dateFormatter2.string(from: dateend ?? Date())
        
        cell.navigationController = self.navigationController
        cell.parentViewController = self
        cell.roomUid = roomUid
        cell.readerFCMDeviceToken = self.items[indexPath.row].readerFCMDeviceToken
        cell.actorFCMDeviceToken = self.items[indexPath.row].actorFCMDeviceToken
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        // add the code here to perform action on the cell
        print("didDeselectItemAt: \(self.items[indexPath.row].id)")
        
//        let cell = collectionView.cellForItem(at: indexPath) as? LibraryCollectionViewCell
    }
    
    @IBAction func ShowUpcomingBookings(_ sender: UIButton) {
        bookType = 1
        sender.tintColor = UIColor(rgb: 0x4063FF)
        btn_pending.tintColor = .black
        btn_past.tintColor = .black
        line_upcoming.isHidden = false
        line_pending.isHidden = true
        line_past.isHidden = true
        fetchBookList()
    }
    
    @IBAction func ShowPendingBookings(_ sender: UIButton) {
        bookType = 2
        sender.tintColor = UIColor(rgb: 0x4063FF)
        btn_upcoming.tintColor = .black
        btn_past.tintColor = .black
        line_upcoming.isHidden = true
        line_pending.isHidden = false
        line_past.isHidden = true
        fetchBookList()
    }
    
    @IBAction func ShowPastBookings(_ sender: UIButton) {
        bookType = 0
        sender.tintColor = UIColor(rgb: 0x4063FF)
        btn_upcoming.tintColor = .black
        btn_pending.tintColor = .black
        line_upcoming.isHidden = true
        line_pending.isHidden = true
        line_past.isHidden = false
        fetchBookList()
    }
    
    @IBAction func CloseRateView(_ sender: UIButton) {
        view_rate.isHidden = true
        backView.isHidden = true
    }
    
    @IBAction func RateWithStar1(_ sender: UITapGestureRecognizer) {
        score = 1.0
        img_star1.tintColor = UIColor(rgb: 0xFFCC00)
        img_star2.tintColor = UIColor(rgb: 0x9498AB)
        img_star3.tintColor = UIColor(rgb: 0x9498AB)
        img_star4.tintColor = UIColor(rgb: 0x9498AB)
        img_star5.tintColor = UIColor(rgb: 0x9498AB)
    }
    @IBAction func RateWithStar2(_ sender: UITapGestureRecognizer) {
        score = 2.0
        img_star1.tintColor = UIColor(rgb: 0xFFCC00)
        img_star2.tintColor = UIColor(rgb: 0xFFCC00)
        img_star3.tintColor = UIColor(rgb: 0x9498AB)
        img_star4.tintColor = UIColor(rgb: 0x9498AB)
        img_star5.tintColor = UIColor(rgb: 0x9498AB)
    }
    
    @IBAction func RateWithStar3(_ sender: UITapGestureRecognizer) {
        score = 3.0
        img_star1.tintColor = UIColor(rgb: 0xFFCC00)
        img_star2.tintColor = UIColor(rgb: 0xFFCC00)
        img_star3.tintColor = UIColor(rgb: 0xFFCC00)
        img_star4.tintColor = UIColor(rgb: 0x9498AB)
        img_star5.tintColor = UIColor(rgb: 0x9498AB)
    }
    
    @IBAction func RateWithStar4(_ sender: UITapGestureRecognizer) {
        score = 4.0
        img_star1.tintColor = UIColor(rgb: 0xFFCC00)
        img_star2.tintColor = UIColor(rgb: 0xFFCC00)
        img_star3.tintColor = UIColor(rgb: 0xFFCC00)
        img_star4.tintColor = UIColor(rgb: 0xFFCC00)
        img_star5.tintColor = UIColor(rgb: 0x9498AB)
    }
    
    @IBAction func RateWithStar5(_ sender: UITapGestureRecognizer) {
        score = 5.0
        img_star1.tintColor = UIColor(rgb: 0xFFCC00)
        img_star2.tintColor = UIColor(rgb: 0xFFCC00)
        img_star3.tintColor = UIColor(rgb: 0xFFCC00)
        img_star4.tintColor = UIColor(rgb: 0xFFCC00)
        img_star5.tintColor = UIColor(rgb: 0xFFCC00)
    }
    
    @IBAction func SubmitFeedback(_ sender: UIButton) {
        //call rate API

        webAPI.giveFeedback(id: bookId, score: score, review: text_feedback.text) { data, response, error in
            
            guard let _ = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                DispatchQueue.main.async {
                    Toast.show(message: "Submitting review failed! please try again later.", controller: self)
                }
                return
            }
            DispatchQueue.main.async {
                Toast.show(message: "Review submitted!", controller: self)
                // stop giving more review
                self.view_rate.isHidden = true
                self.backView.isHidden = true
                self.text_feedback.text = ""
                self.fetchBookList()
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
