//
//  ActorFindReaderViewController.swift
//  PerfectSelf
//
//  Created by Kayan Mishra on 3/8/23.
//  Copyright © 2023 Stas Seldin. All rights reserved.
//

import UIKit

class ActorFindReaderViewController: UIViewController , UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, SortDelegate, FilterDelegate{
    func fetchReadersWithFilter(viewController: UIViewController) {
        fetchReaderList()
    }
    
    func setSortType(viewController: UIViewController, sortType: Int) {
        self.sortType = sortType
        fetchReaderList()
    }
    
    var sortType = 0
    
    @IBOutlet weak var numberOfReader: UILabel!
    @IBOutlet weak var readerList: UICollectionView!
    @IBOutlet weak var spin: UIActivityIndicatorView!
    
    var items = [ReaderProfileCard]()
    let cellsPerRow = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName: "ReaderCollectionViewCell", bundle: nil)
        readerList.register(nib, forCellWithReuseIdentifier: "Reader Collection View Cell")
        readerList.dataSource = self
        readerList.delegate = self
        readerList.allowsSelection = true
        // Do any additional setup after loading the view.
        self.navigationItem.setHidesBackButton(true, animated: false)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true);
        fetchReaderList()
    }
    func fetchReaderList() {
        spin.isHidden = false
        spin.startAnimating()
        // call API to fetch reader list
        var gender = [Int]()
        if Filter["isMale"] as! Bool {
            gender.append(0)
        }
        if Filter["isFemale"] as! Bool {
            gender.append(1)
        }
        if Filter["isNonBinary"] as! Bool {
            gender.append(2)
        }
        if Filter["isGenderqueer"] as! Bool {
            gender.append(3)
        }
        if Filter["isGenderfluid"] as! Bool {
            gender.append(4)
        }
        if Filter["isTransgender"] as! Bool {
            gender.append(5)
        }
        if Filter["isAgender"] as! Bool {
            gender.append(6)
        }
        if Filter["isBigender"] as! Bool {
            gender.append(7)
        }
        if Filter["isTwoSpirit"] as! Bool {
            gender.append(8)
        }
        if Filter["isAndrogynous"] as! Bool {
            gender.append(9)
        }
        if Filter["isUnknown"] as! Bool {
            gender.append(10)
        }
        webAPI.getReaders(readerName: nil,isSponsored: nil, isAvailableSoon: (Filter["isAvailableSoon"] as? Bool), isTopRated: nil, isOnline: Filter["isonlineNow"] as? Bool, availableTimeSlotType: (Filter["timeSlotType"] as? Int), availableFrom: (Filter["isDateSelected"] as! Bool) ? Date.getStringFromDate(date: Filter["fromDate"] as! Date) : nil, availableTo: (Filter["isDateSelected"] as! Bool) ? Date.getStringFromDate(date: Filter["toDate"] as! Date) : nil, minPrice: (Filter["priceMinVal"] as? Float), maxPrice: (Filter["priceMaxVal"] as? Float), gender: gender, sortBy: sortType) { data, response, error in
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
                //print(items)
                DispatchQueue.main.async {
                    self.items.removeAll()
                    self.items.append(contentsOf: respItems)
                    //UTC2local
                    for index in self.items.indices {
                        self.items[index].fromTime = utcToLocal(dateStr: self.items[index].fromTime)!
                        self.items[index].toTime = utcToLocal(dateStr: self.items[index].toTime)!
                    }
                    
                    self.readerList.reloadData()
                    self.numberOfReader.text = "\(self.items.count) Readers Listed"
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
    func collectionView(_ collectionView: UICollectionView,        numberOfItemsInSection section: Int) -> Int {
         // myData is the array of items
        return self.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
            + (flowLayout.minimumInteritemSpacing * CGFloat(cellsPerRow - 1))
        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(cellsPerRow))
        return CGSize(width: size, height: 120)
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
        cell.score.text = String(self.items[indexPath.row].score)
        cell.review.text = "(\(self.items[indexPath.row].reviewCount))"
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
        let controller = ActorReaderDetailViewController()
        controller.bookingInfo.uid = self.items[indexPath.row].uid
        controller.modalPresentationStyle = .fullScreen
 
//        let transition = CATransition()
//        transition.duration = 0.5 // Set animation duration
//        transition.type = CATransitionType.push // Set transition type to push
//        transition.subtype = CATransitionSubtype.fromRight // Set transition subtype to from right
//        self.view.window?.layer.add(transition, forKey: kCATransition) // Add transition to window layer
        self.present(controller, animated: false)
    }
    @IBAction func ShowFilterModal(_ sender: UIButton) {
        let controller = FilterViewController()
        controller.originType = 1
        controller.modalPresentationStyle = .overFullScreen
        controller.fd = self
        self.present(controller, animated: true)
        
    }
    
    @IBAction func SortReaders(_ sender: UIButton) {
        let controller = SortViewController()
        controller.sd = self
        controller.sortType = self.sortType
        controller.modalPresentationStyle = .overFullScreen
        self.present(controller, animated: true)
    }
    
    @IBAction func GoBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
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
