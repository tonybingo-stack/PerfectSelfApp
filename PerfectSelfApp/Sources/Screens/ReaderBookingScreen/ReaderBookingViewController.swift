//
//  ReaderBookingViewController.swift
//  PerfectSelf
//
//  Created by user232392 on 3/22/23.
//  Copyright © 2023 Stas Seldin. All rights reserved.
//

import UIKit

class ReaderBookingViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, BookDelegate {
    func setBookId(controller: UICollectionViewCell, id: Int, name: String) {
        print(String(id) + ":" + name)
    }
    
    var uid = ""
    @IBOutlet weak var btn_upcoming: UIButton!
    @IBOutlet weak var btn_past: UIButton!
    @IBOutlet weak var btn_pending: UIButton!
    
    @IBOutlet weak var line_upcoming: UIImageView!
    @IBOutlet weak var line_pending: UIImageView!
    @IBOutlet weak var line_past: UIImageView!

    @IBOutlet weak var bookList: UICollectionView!
    var items = [BookingCard]()
    @IBOutlet weak var spin: UIActivityIndicatorView!
    
    let cellsPerRow = 1
    var bookType = 1 //for upcomming
    var searchText = ""
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
        // Retrieve the saved data from UserDefaults
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
    
    @IBAction func changeSearchText(_ sender: UITextField) {
        searchText = sender.text ?? ""
        fetchBookList()
    }
    func fetchBookList() {
        //call API to fetch booking list
        spin.isHidden = false
        spin.startAnimating()
        webAPI.getBookingsByUid(uid: uid, bookType: self.bookType, name: searchText) { data, response, error in
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
   
        let datestart = Date.getDateFromString(date: self.items[indexPath.row].bookStartTime)
        let dateend = Date.getDateFromString(date: self.items[indexPath.row].bookEndTime)
        
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = appDatetimeFormat
        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = "hh:mm a"
        
        cell.bookType = bookType
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
        
        cell.navigationController = self.navigationController
        cell.parentViewController = self
        cell.roomUid = roomUid
        cell.readerFCMDeviceToken = self.items[indexPath.row].readerFCMDeviceToken
        cell.actorFCMDeviceToken = self.items[indexPath.row].actorFCMDeviceToken
        cell.delegate = self
        if(bookType == 0){
            cell.btnViewScript.isHidden = true
        }
        else{
            cell.btnViewScript.isHidden = false
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        // add the code here to perform action on the cell
        print("didDeselectItemAt")
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
