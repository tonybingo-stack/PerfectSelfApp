//
//  ReaderProfileEditSkillViewController.swift
//  PerfectSelf
//
//  Created by Kayan Mishra on 3/8/23.
//  Copyright © 2023 Stas Seldin. All rights reserved.
//

import UIKit
public enum TypeOfAccordianView {
    case Classic
    case Formal
}

class ReaderProfileEditSkillViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    var typeOfAccordianView = TypeOfAccordianView.Formal
    
    var uid = ""
    var auditionType = 0
    var isExplicitRead = false
    @IBOutlet weak var btn_extendedread: UIButton!
    @IBOutlet weak var btn_shortread: UIButton!
    @IBOutlet weak var btn_commercialread: UIButton!
    @IBOutlet weak var btn_explicit_no: UIButton!
    @IBOutlet weak var btn_explicit_yes: UIButton!
    @IBOutlet weak var skillView: UIStackView!
    @IBOutlet weak var selectedSkillList: UICollectionView!
    @IBOutlet weak var skillKeyword: UITextField!
    
    var isCommercialRead = true
    var isShortRead = false
    var isExtendedRead = false

    var items = [String]()
    let cellsPerRow = 1
    
    let headerLabel = ["Strong Storytelling Sense", "Comprehensive Script Analysis", "Writing and Communication Skills", "Industry Knowledge", "Analytical and Critical Thinking", "Time Management and Efficiency", "Adaptability and Flexibility", "Confidentiality and Professionalism", "Others"]
    let innerLabel = [
        [
            "Understanding Narrative Structure",
            "Character Development",
            "Pacing and Timing",
            "Dialogue Evaluation",
            "Theme Identification",
            "Visual Storytelling",
            "Genre Awareness",
            "Emotional Impact",
            "Originality and Creativity",
            "Audience Engagement"
        ],
        [
            "Identifying Theme and Subtext",
            "Evaluating Character Development",
            "Assessing Dialogue",
            "Analyzing Pacing and Tension",
            "Evaluating Plot and Conflict",
            "Considering Visual and Cinematic Elements",
            "Identifying Marketability and Audience Appeal"
        ],
        [
            "Clarity and Coherence",
            "Constructive Criticism",
            "Adaptability of Writing Style",
            "Attention to Detail",
            "Formatting and Presentation",
            "Empathy and Sensitivity",
            "Active Listening",
            "Adaptation to Different Audiences",
            "Professional Correspondence",
            "Collaboration and Teamwork"
        ],
        [
            "Familiarity with Film History",
            "Awareness of Current Film Trends",
            "Market Research",
            "Knowledge of Industry Players",
            "Understanding Distribution Platforms",
            "Insight into International Markets",
            "Knowledge of Legal and Copyright Issues",
            "Awareness of Industry Events and Festivals"
        ],
        [
            "Script Analysis",
            "Identifying Strengths and Weaknesses",
            "Recognizing Theme and Subtext",
            "Comparative Analysis",
            "Objective Evaluation",
            "Problem-Solving",
            "Contextual Understanding",
            "Constructive Feedback"
        ],
        [
            "Prioritization",
            "Organization",
            "Focus and Concentration",
            "Task Breakdown",
            "Time Blocking",
            "Deadline Management",
            "Minimizing Procrastination",
            "Delegation",
            "Effective Communication",
            "Continuous Learning and Improvement"
        ],
        [
            "Genre Familiarity",
            "Format Adaptation",
            "Style Variation",
            "Medium Consideration",
            "Cultural Sensitivity",
            "Feedback Customization",
            "Industry Trends and Evolution",
            "Collaborative Approach"
        ],
        [
            "Trustworthiness",
            "Non-Disclosure Agreements (NDAs)",
            "Data Security",
            "Professional Communication",
            "Ethical Guidelines",
            "Discretion",
            "Professional Boundaries",
            "Document Destruction"
        ],
        [
            "Fast Speaking",
            "Low voice"
        ]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName: "SkillCell", bundle: nil)
        selectedSkillList.register(nib, forCellWithReuseIdentifier: "Skill Cell")
        selectedSkillList.dataSource = self
        selectedSkillList.delegate = self
        selectedSkillList.allowsSelection = true
        
         let accordionView = MKAccordionView(frame: CGRect(x: 0, y: 0, width: skillView.bounds.width, height: skillView.bounds.height-50))
          
        accordionView.delegate = self;
        accordionView.dataSource = self;
        accordionView.isCollapsedAllWhenOneIsOpen = true
        skillView.addSubview(accordionView);
        
        if isExplicitRead {
            btn_explicit_yes.isSelected = true
            btn_explicit_no.isSelected = false
        } else {
            btn_explicit_yes.isSelected = false
            btn_explicit_no.isSelected = true
        }
        
        self.isExtendedRead = (self.auditionType & 1) != 0
        self.isShortRead = (self.auditionType & 2) != 0
        self.isCommercialRead = (self.auditionType & 4) != 0
        
        btn_commercialread.backgroundColor = self.isCommercialRead ? UIColor(rgb: 0x4865FF) : UIColor(rgb: 0xFFFFFF)
        btn_commercialread.setTitleColor(self.isCommercialRead ? .white : UIColor(rgb: 0x4865FF), for: .normal)
        btn_commercialread.tintColor = self.isCommercialRead ? .white : UIColor(rgb: 0x4865FF)
      
        btn_shortread.backgroundColor = self.isShortRead ? UIColor(rgb: 0x4865FF) : UIColor(rgb: 0xFFFFFF)
        btn_shortread.setTitleColor(self.isShortRead ? .white : UIColor(rgb: 0x4865FF), for: .normal)
        btn_shortread.tintColor = self.isShortRead ? .white : UIColor(rgb: 0x4865FF)
        
        btn_extendedread.backgroundColor = self.isExtendedRead ? UIColor(rgb: 0x4865FF) : UIColor(rgb: 0xFFFFFF)
        btn_extendedread.setTitleColor(self.isExtendedRead ? .white : UIColor(rgb: 0x4865FF), for: .normal)
        btn_extendedread.tintColor = self.isExtendedRead ? .white : UIColor(rgb: 0x4865FF)
    }
    // MARK: - Time Slot List Delegate.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         // myData is the array of items
        return self.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
//        let totalSpace = flowLayout.sectionInset.top
//        + flowLayout.sectionInset.bottom
//        + (flowLayout.minimumLineSpacing * CGFloat(cellsPerRow - 1))
//        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(cellsPerRow))
        let skill = self.items[indexPath.row]
        let font = UIFont.systemFont(ofSize: 14)
        let size = (skill as NSString).size(withAttributes: [.font: font])
        return CGSize(width: size.width + 40, height: 40)
//        return CGSize(width: 80, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Skill Cell", for: indexPath) as! SkillCell
        cell.skillName.text = items[indexPath.row]

        cell.contentView.layer.cornerRadius = 12
        cell.contentView.layer.borderWidth = 0
        cell.contentView.layer.borderColor = UIColor.gray.cgColor
        cell.contentView.layer.masksToBounds = true
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // add the code here to perform action on the cell
        items.remove(at: indexPath.row)
        selectedSkillList.reloadData()
        let lastItemIndex = selectedSkillList.numberOfItems(inSection: 0) - 1
        let lastIndexPath = IndexPath(item: lastItemIndex, section: 0)
        selectedSkillList.scrollToItem(at: lastIndexPath, at: .right, animated: true)
    }

    @IBAction func SelectComfortableWithExplicitRead(_ sender: UIButton) {
        sender.isSelected = true
        btn_explicit_no.isSelected = false
    }
    @IBAction func SelectNotCamfortableWithExplicitRead(_ sender: UIButton) {
        sender.isSelected = true
        btn_explicit_yes.isSelected = false
    }
    @IBAction func SaveChanges(_ sender: UIButton) {
        //call API for update reader's skill
        let skills = self.items.joined(separator: ",")
        let aType = (self.isExtendedRead ? 4:0) + (self.isShortRead ? 2 : 0) + (self.isCommercialRead ? 1:0)
        print(aType)
        showIndicator(sender: nil, viewController: self)
        webAPI.editReaderProfile(uid: uid, title: "", min15Price: -1, min30Price: -1, hourlyPrice: -1, about: "", introBucketName: "", introVideokey: "", skills: skills, auditionType: aType, isExplicitRead: btn_explicit_yes.isSelected) { data, response, error in
            DispatchQueue.main.async {
                hideIndicator(sender: nil);
            }
           
            guard let _ = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            DispatchQueue.main.async {
                let transition = CATransition()
                transition.duration = 0.5 // Set animation duration
                transition.type = CATransitionType.push // Set transition type to push
                transition.subtype = CATransitionSubtype.fromLeft // Set transition subtype to from right
                self.view.window?.layer.add(transition, forKey: kCATransition) // Add transition to window layer
                self.dismiss(animated: false)
            }
        }
        
 
    }
    @IBAction func SelectCommercialRead(_ sender: UIButton) {
        isCommercialRead = !isCommercialRead
        
        if isCommercialRead {
            sender.backgroundColor = UIColor(rgb: 0x4865FF)
            sender.setTitleColor(.white, for: .normal)
            sender.tintColor = .white
        }
        else {
            sender.backgroundColor = UIColor(rgb: 0xFFFFFF)
            sender.setTitleColor(UIColor(rgb: 0x4865FF), for: .normal)
            sender.tintColor = UIColor(rgb: 0x4865FF)
        }
    }
    
    @IBAction func SelectShortRead(_ sender: UIButton) {
        isShortRead = !isShortRead
        
        if isShortRead {
            sender.backgroundColor = UIColor(rgb: 0x4865FF)
            sender.setTitleColor(.white, for: .normal)
            sender.tintColor = .white
        }
        else {
            sender.backgroundColor = UIColor(rgb: 0xFFFFFF)
            sender.setTitleColor(UIColor(rgb: 0x4865FF), for: .normal)
            sender.tintColor = UIColor(rgb: 0x4865FF)
        }
    }
    
    @IBAction func SelectExtendedRead(_ sender: UIButton) {
        isExtendedRead = !isExtendedRead
        
        if isExtendedRead {
            sender.backgroundColor = UIColor(rgb: 0x4865FF)
            sender.setTitleColor(.white, for: .normal)
            sender.tintColor = .white
        }
        else {
            sender.backgroundColor = UIColor(rgb: 0xFFFFFF)
            sender.setTitleColor(UIColor(rgb: 0x4865FF), for: .normal)
            sender.tintColor = UIColor(rgb: 0x4865FF)
        }
    }
    
    @IBAction func GoBack(_ sender: UIButton) {
        let transition = CATransition()
        transition.duration = 0.5 // Set animation duration
        transition.type = CATransitionType.push // Set transition type to push
        transition.subtype = CATransitionSubtype.fromLeft // Set transition subtype to from right
        self.view.window?.layer.add(transition, forKey: kCATransition) // Add transition to window layer
        self.dismiss(animated: true)
    }
    
    @IBAction func onBeginSkillInput(_ sender: UITextField) {
    }
    
    @IBAction func onChangeSkillInput(_ sender: UITextField) {
        //let skill = self.skillKeyword.text
        //print("onChangeSkillInput \(skill!)")
    }
    
    @IBAction func onEndSkillInput(_ sender: UITextField) {
        let skill = self.skillKeyword.text
        guard let skill = skill, skill.count > 0 else{
            return
        }
        //print("onEndSkillInput \(skill!)")
        appendNewSkill(skill)
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

// MARK: - Implemention of MKAccordionViewDelegate method
extension ReaderProfileEditSkillViewController : MKAccordionViewDelegate {
    
  func accordionView(_ accordionView: MKAccordionView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch typeOfAccordianView {
            case .Classic :
                 return 50
            case .Formal :
                 return 40
        }
    }
    
    func accordionView(_ accordionView: MKAccordionView, heightForHeaderIn section: Int) -> CGFloat {
        switch typeOfAccordianView {
        case .Classic :
            return 50
        case .Formal :
            return 40
        }
    }
    
    func accordionView(_ accordionView: MKAccordionView, heightForFooterIn section: Int) -> CGFloat {
        switch typeOfAccordianView {
        case .Classic :
            return 0
        case .Formal :
            return 12
        }
    }
    
    func accordionView(_ accordionView: MKAccordionView, viewForHeaderIn section: Int, isSectionOpen sectionOpen: Bool) -> UIView? {
     
        return getHeaderViewForAccordianType(typeOfAccordianView, accordionView: accordionView, section: section,  isSectionOpen: sectionOpen);
        
    }
    
    func accordionView(_ accordionView: MKAccordionView, viewForFooterIn section: Int, isSectionOpen sectionOpen: Bool) -> UIView? {
        
        switch typeOfAccordianView {
        case .Classic :
            
          let view  = UIView(frame: CGRect(x: 0, y:0, width: accordionView.bounds.width, height: 0))
          view.backgroundColor = UIColor.clear
          return view
            
        case .Formal :
          let view : UIView! = UIView(frame: CGRect(x: 0, y:0, width: accordionView.bounds.width, height:12))
          view.backgroundColor = UIColor.white
          return view
        }
        
    }
    
    func getHeaderViewForAccordianType(_ type : TypeOfAccordianView, accordionView: MKAccordionView, section: Int, isSectionOpen sectionOpen: Bool) -> UIView {
        switch type {
        case .Classic :
          let view : UIView! = UIView(frame: CGRect(x: 0, y:0, width: accordionView.bounds.width, height: 50))
            
            // Background Image
            let bgImageView : UIImageView = UIImageView(frame: view.bounds)
            bgImageView.image = UIImage(named: ( sectionOpen ? "grayBarSelected" : "grayBar"))!
            view.addSubview(bgImageView)
            
            // Arrow Image
          let arrowImageView : UIImageView = UIImageView(frame: CGRect(x: 15, y:15, width:20, height:20))
            arrowImageView.image = UIImage(named: ( sectionOpen ? "close" : "open"))!
            view.addSubview(arrowImageView)
            
            // Title Label
          let titleLabel : UILabel = UILabel(frame: CGRect(x:50, y:0, width: view.bounds.width - 120, height: view.bounds.height ))
            titleLabel.text = headerLabel[section]
            titleLabel.textColor = UIColor.white
            view.addSubview(titleLabel)
            
            return view
            
        case .Formal :
            
          let view : UIView! = UIView(frame: CGRect(x:0, y:0, width: accordionView.bounds.width , height: 40))
            view.backgroundColor = UIColor(rgb: 0xE5E5E5)
            view.cornerRadius = 10
            view.clipsToBounds = false
            
            // Image before Home
          let bgImageView : UIImageView = UIImageView(frame: CGRect(x: 10, y:12, width:16, height:16))
//          let bgImageView : UIImageView = UIImageView(frame: CGRect(x: 5, y:16, width:11, height:8))
            bgImageView.image = UIImage(systemName: ( sectionOpen ? "record.circle" : "circle"))!
            bgImageView.tintColor = .black
//            bgImageView.image = UIImage(named: ( sectionOpen ? "favorites-pointer" : "favorites-pointer"))!
            view.addSubview(bgImageView)
            
            // Arrow Image
//          let arrowImageView : UIImageView = UIImageView(frame: CGRect( x: view.bounds.width - 12 - 10 , y: 15, width: 12, height: 6))
//            arrowImageView.image = UIImage(named: ( sectionOpen ? "arrow-down" : "arrow-up"))!
//            view.addSubview(arrowImageView)
            
            
            // Title Label
          let titleLabel : UILabel = UILabel(frame: CGRect(x: 36, y: 0, width: view.bounds.width - 120, height: view.bounds.height))
          titleLabel.text = headerLabel[section]
          titleLabel.textColor = UIColor.black
          titleLabel.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular)
            view.addSubview(titleLabel)
            
          return view
        }
    }
    
}

// MARK: - Implemention of MKAccordionViewDatasource method
extension ReaderProfileEditSkillViewController : MKAccordionViewDatasource {
    
    func numberOfSectionsInAccordionView(_ accordionView: MKAccordionView) -> Int {
        return self.headerLabel.count //TODO: count of section array
    }
    
    func accordionView(_ accordionView: MKAccordionView, numberOfRowsIn section: Int) -> Int {
        
        return innerLabel[section].count
    }
    
    func accordionView(_ accordionView: MKAccordionView , cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        return getCellForAccordionType(typeOfAccordianView, accordionView: accordionView, cellForRowAt: indexPath)
    }
    
    func accordionView(_ accordionView: MKAccordionView, didSelectRowAt indexPath: IndexPath) {
        
//        print("accordionView \(indexPath.section) \(indexPath.item)")
        appendNewSkill(innerLabel[indexPath.section][indexPath.item])
//Omitted
//        if items.contains(innerLabel[indexPath.section][indexPath.item]) {
//            return
//        }
//
//        items.append(innerLabel[indexPath.section][indexPath.item])
//        selectedSkillList.reloadData()
//        let lastItemIndex = selectedSkillList.numberOfItems(inSection: 0) - 1
//        let lastIndexPath = IndexPath(item: lastItemIndex, section: 0)
//        selectedSkillList.scrollToItem(at: lastIndexPath, at: .right, animated: true)
    }
    
    func appendNewSkill(_ skill: String){
        if items.contains(skill) {
            return
        }
        
        items.append(skill)
        selectedSkillList.reloadData()
        let lastItemIndex = selectedSkillList.numberOfItems(inSection: 0) - 1
        let lastIndexPath = IndexPath(item: lastItemIndex, section: 0)
        selectedSkillList.scrollToItem(at: lastIndexPath, at: .right, animated: true)
    }
    
    func getCellForAccordionType(_ accordionType: TypeOfAccordianView, accordionView: MKAccordionView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch accordionType {
            
            case .Classic :
              let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
              //cell?.imageView = UIImageView(image: UIImage(named: "lightGrayBarWithBluestripe"))
              
              // Background view
              let bgView : UIView? = UIView(frame: CGRect(x:0, y:0, width: accordionView.bounds.width, height: 50))
              let bgImageView : UIImageView! = UIImageView(image: UIImage(named: "lightGrayBarWithBluestripe"))
              bgImageView.frame = (bgView?.bounds)!
              bgImageView.contentMode = .scaleToFill
              bgView?.addSubview(bgImageView)
              cell.backgroundView = bgView
              
              // You can assign cell.selectedBackgroundView also for selected mode
              
              cell.textLabel?.text = innerLabel[indexPath.section][indexPath.item]
              return cell
          
            case .Formal :
              let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
                
                
                // You can assign cell.selectedBackgroundView also for selected mode
                
            cell.textLabel?.text = innerLabel[indexPath.section][indexPath.item]
              cell.textLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.thin)
              return cell
        }
        
    }
}

