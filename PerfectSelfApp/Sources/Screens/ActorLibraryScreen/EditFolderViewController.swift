//
//  EditFolderViewController.swift
//  PerfectSelf
//
//  Created by user237184 on 8/3/23.
//  Copyright © 2023 Stas Seldin. All rights reserved.
//

import UIKit

class EditFolderViewController: UIViewController {
    
    @IBOutlet weak var tapeTable: UITableView!
    @IBOutlet weak var FolderTable: UITableView!
    let folderList: [VideoCard]
    let tapeList: [VideoCard]
    
//    var tapeList: [String] = ["1", "2", "3"]
//    var folderList: [String] = ["a", "b", "c", "d"]
    var tapeSelIdx: Int = -1
    var folderSelIdx: Int = -1
    
    init(tapeLst: [VideoCard], folderLst: [VideoCard]) {
        self.tapeList = tapeLst
        self.folderList = folderLst
        super.init(nibName: String(describing: EditFolderViewController.self), bundle: Bundle.main)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let nibName = UINib(nibName: "TapeItemViewCell", bundle: nil)
        tapeTable.register(nibName, forCellReuseIdentifier: "Tape Item View Cell")
        FolderTable.register(nibName, forCellReuseIdentifier: "Tape Item View Cell")
        
        tapeTable.delegate = self
        tapeTable.dataSource = self
        tapeTable.reloadData()
        
        FolderTable.delegate = self
        FolderTable.dataSource = self
        FolderTable.reloadData()
    }
        
    @IBAction func backBtnDidTap(_ sender: UIButton) {
        self.dismiss(animated: false)
    }
    
    @IBAction func okBtnDidTap(_ sender: UIButton) {
        var inputCheck: String = ""
        
        if( tapeSelIdx == -1 ){
            inputCheck += "- Please select tape to move.\n"
        }
//        if( folderSelIdx == -1 ){
//            inputCheck += "- Please select target folder.\n"
//        }
        
        if(!inputCheck.isEmpty){
            showAlert(viewController: self, title: "Confirm", message: inputCheck) { UIAlertAction in
            }
            return
        }
        var parentId = ""
        if folderSelIdx != -1{
            parentId = folderList[folderSelIdx].roomUid
        }
        webAPI.updateTapeFolder(tapeId: tapeList[tapeSelIdx].tapeId, parentId: parentId){ data, response, error in
            DispatchQueue.main.async {
                //hideIndicator(sender: nil)
                self.dismiss(animated: false)
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

extension EditFolderViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView == tapeTable){
            return tapeList.count
        }
        else if(tableView == FolderTable){
            return folderList.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Tape Item View Cell", for: indexPath) as? TapeItemViewCell else {
            fatalError("")
        }
        
        if(tableView == tapeTable){
            cell.itemTxt.text = tapeList[indexPath.row].tapeName
            let thumb = "https://video-thumbnail-bucket-123456789.s3.us-east-2.amazonaws.com/\(self.tapeList[indexPath.row].actorTapeKey)-0.jpg"
            cell.selectMark.imageFrom(url: URL(string:thumb )!)
            cell.selectMark.transform = CGAffineTransformMakeRotation(degreeToRadian(CGFloat(mainRotateDegree)))
            cell.selectMark.isHidden = false
        }
        else if(tableView == FolderTable){
            cell.itemTxt.text = folderList[indexPath.row].tapeName
            cell.selectMark.isHidden = true
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! TapeItemViewCell
        cell.selectMark.isHidden = false
        
        if(tableView == tapeTable){
            if tapeSelIdx != -1{
                //let _ = tableView.cellForRow(at: IndexPath(row: tapeSelIdx, section: 0)) as! TapeItemViewCell
                //cellPre.selectMark.isHidden = true
            }
            tapeSelIdx = indexPath.row
        }
        else if(tableView == FolderTable){
            if folderSelIdx != -1{
                //let _ = tableView.cellForRow(at: IndexPath(row: folderSelIdx, section: 0)) as! TapeItemViewCell
                //cellPre.selectMark.isHidden = true
            }
            
            folderSelIdx = indexPath.row
        }
    }
}
