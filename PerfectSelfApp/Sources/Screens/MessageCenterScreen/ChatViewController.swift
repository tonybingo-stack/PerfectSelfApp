//
//  ActorChatViewController.swift
//  PerfectSelf
//
//  Created by Kayan Mishra on 3/8/23.
//  Copyright © 2023 Stas Seldin. All rights reserved.
//

import UIKit
import WebRTC
import os.log

class ChatViewController: KUIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    private var url: String?
    private var name: String
    private var uid: String
    private var roomUid: String
    
    var muid = ""
    var mname = ""
    @IBOutlet weak var lbl_name: UILabel!
    @IBOutlet weak var img_avatar: UIImageView!
    @IBOutlet weak var modal_confirm_call: UIStackView!
    @IBOutlet weak var noMessage: UIStackView!
    let backgroundView = UIView()
    @IBOutlet weak var messageCollectionView: UICollectionView!
    @IBOutlet weak var messageTextField: UITextField!

    var messages: [PerfMessage] = []
    let cellsPerRow = 1
    private var signalClient: SignalingClient
    private var webRTCClient: WebRTCClient
    private let signalingClientStatus: SignalingClientStatus
    
    //MARK: WebRTC Conference Status
    private var speakerOn: Bool = false {
        didSet {
//REFME
//            let title = "Speaker: \(self.speakerOn ? "On" : "Off" )"
//            self.speakerButton?.setTitle(title, for: .normal)
        }
    }
    
    private var mute: Bool = false {
        didSet {
//REFME
//            let title = "Mute: \(self.mute ? "on" : "off")"
//            self.muteButton?.setTitle(title, for: .normal)
        }
    }
    
    init(roomUid: String, url: String?, name: String, uid: String) {
        self.signalClient = buildSignalingClient()
        self.webRTCClient = WebRTCClient(iceServers: signalingServerConfig.webRTCIceServers)
        self.signalingClientStatus = SignalingClientStatus(signalClient: &self.signalClient, webRTCClient: &self.webRTCClient)
        self.roomUid = roomUid
        self.url = url
        self.name = name
        self.uid = uid
        super.init(nibName: String(describing: ChatViewController.self), bundle: Bundle.main)
        self.speakerOn = false
        
        self.webRTCClient.delegate = self
        uiViewContoller = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if url != nil {
            img_avatar.imageFrom(url: URL(string: url!)!)
        }
        lbl_name.text = name
        modal_confirm_call.isHidden = true;
        noMessage.isHidden = false;
        
        let nib = UINib(nibName: "MessageCell", bundle: nil)
        messageCollectionView.register(nib, forCellWithReuseIdentifier: "Message Cell")
        messageCollectionView.dataSource = self
        messageCollectionView.delegate = self
        
        //Omitted self.webRTCClient.speakerOn()
        self.signalClient.sendRoomId(roomId: self.roomUid)
        if let userInfo = UserDefaults.standard.object(forKey: "USER") as? [String:Any] {
            // Use the saved data
            muid = userInfo["uid"] as! String
            mname = userInfo["userName"] as! String
        } else {
            // No data was saved
            print("No data was saved.")
        }
        fetchChatHistory()
        updateMessageReadState()
    }
    func updateMessageReadState() {
        // call API for update message read state
        webAPI.updateAllMessageReadState(suid: uid, ruid: muid) { data, response, error in
            guard let _ = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
        }
    }
    func fetchChatHistory() {
        // call API for chat history
        showIndicator(sender: nil, viewController: self)
        webAPI.getMessageHistoryByRoomId(roomId: roomUid) { data, response, error in
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
                let items = try JSONDecoder().decode([PerfMessage].self, from: data)
                //print(items)
                DispatchQueue.main.async {
                    self.noMessage.isHidden = !(items.count == 0)
                    self.messages.removeAll()
                    self.messages.append(contentsOf: items)
                    //UTC2local
                    for index in self.messages.indices {
                        self.messages[index].sendTime = utcToLocal(dateStr: self.messages[index].sendTime)!
                    }
                    
                    self.messageCollectionView.reloadData()
                }
            }
            catch {
                DispatchQueue.main.async {
                    Toast.show(message: "Something went wrong. try again later", controller: self)
                }
            }
        }
    }
    @IBAction func SendMessage(_ sender: UIButton) {
        
        guard let text = messageTextField.text, !text.isEmpty else {
            return // Don't send empty messages
        }
        noMessage.isHidden = true;
        messageTextField.text = ""
        let message = PerfMessage(id: 0, senderUid: muid, receiverUid: uid, roomUid: roomUid, sendTime: Date.getStringFromDate(date: Date()), hadRead: false, message: text)
        messages.append(message)

        messageCollectionView.reloadData() // Refresh the table view to display the new message
        // Scroll to the last item in collection view
        let lastItemIndex = messageCollectionView.numberOfItems(inSection: 0) - 1
        let lastIndexPath = IndexPath(item: lastItemIndex, section: 0)
        messageCollectionView.scrollToItem(at: lastIndexPath, at: .bottom, animated: true)
        let recStart: Data = text.data(using: .utf8)!
        self.webRTCClient.sendData(recStart)
        
        // TODO: Send the message to the server or save it to local storage
        // call API for message save
        webAPI.sendMessage(roomId: roomUid, sUid: muid, rUid: uid, message: text) { data, response, error in
            guard let _ = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                DispatchQueue.main.async {
                    Toast.show(message: "error while fetch chat history. try again later", controller: self)
                }
                return
            }
        }
    }
    // MARK: - Message List Delegate.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         // myData is the array of items
        return self.messages.count
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
            + (flowLayout.minimumInteritemSpacing * CGFloat(cellsPerRow - 1))
        let size = (collectionView.bounds.width - totalSpace) / CGFloat(cellsPerRow)
        
        let messageText = messages[indexPath.row].message
        let messageTextHeight = messageText.height(withConstrainedWidth: size-20, font: UIFont.systemFont(ofSize: 14))
        
        let totalHeight = messageTextHeight + 16 // add 56 for the height of the profile image and padding
        
        return CGSize(width: size, height: totalHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Message Cell", for: indexPath) as! MessageCell
//        cell.lbl_unviewednum.text = self.messages[indexPath.row];
        cell.messageLabel.text = self.messages[indexPath.row].message
        cell.messageType = self.messages[indexPath.row].senderUid == uid ? .received : .sent
        // return card
//        cell.layer.masksToBounds = false
//        cell.layer.shadowOffset = CGSizeZero
//        cell.layer.shadowRadius = 8
//        cell.layer.shadowOpacity = 0.2
//        cell.contentView.layer.cornerRadius = 12
//        cell.contentView.layer.borderWidth = 1.0
//        cell.contentView.layer.borderColor = UIColor.clear.cgColor
//        cell.contentView.layer.masksToBounds = true
//        cell.backgroundColor = .red
        
        return cell
    }
    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        // add the code here to perform action on the cell
//        print("didDeselectItemAt" + String(indexPath.row))
//        let controller = ChatViewController();
//        self.navigationController?.pushViewController(controller, animated: true);
////        let cell = collectionView.cellForItem(at: indexPath) as? LibraryCollectionViewCell
//    }
  
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        let message = messages[indexPath.row]
//        let messageText = message
//
//        let messageTextWidth = tableView.bounds.width - 16 // subtract 16 for padding
//        let messageTextHeight = messageText.height(withConstrainedWidth: messageTextWidth, font: UIFont.systemFont(ofSize: 17))
//
//        let totalHeight = messageTextHeight + 56 // add 56 for the height of the profile image and padding
//
//        return totalHeight
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return messages.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "Table View Cell", for: indexPath) as! TableViewCell
//
//        let message = messages[indexPath.row]
//        cell.messageLabel.text = message
//        cell.timestampLabel.text = Date().description // or format the date string as desired
//        cell.messageType = message == "hi" ? .sent : .received
//        return cell
//    }
       
    @IBAction func CancelCall(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: {
            //use if you wish to darken the background
            //self.viewDim.alpha = 0
            self.modal_confirm_call.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
            
        }) { (success) in
            self.backgroundView.removeFromSuperview()
            self.self.modal_confirm_call.isHidden = true;
        }
    }
    @IBAction func ConfirmCall(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: {
            //use if you wish to darken the background
            //self.viewDim.alpha = 0
            self.modal_confirm_call.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
            
        }) { (success) in
            self.backgroundView.removeFromSuperview()
            self.self.modal_confirm_call.isHidden = true;
        }
    }
    @IBAction func DoVoiceCall(_ sender: UIButton) {
        view.endEditing(true)
        modal_confirm_call.isHidden = false;
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        backgroundView.frame = view.bounds
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(backgroundView, belowSubview: modal_confirm_call)
 
        modal_confirm_call.transform = CGAffineTransform(scaleX: 0.8, y: 1.2)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: {
            self.modal_confirm_call.transform = .identity
        })
    }
    
    @IBAction func DoVideoCall(_ sender: UIButton) {
        view.endEditing(true)
        modal_confirm_call.isHidden = false;
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        backgroundView.frame = view.bounds
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(backgroundView, belowSubview: modal_confirm_call)
        
        modal_confirm_call.transform = CGAffineTransform(scaleX: 0.8, y: 1.2)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: {
            self.modal_confirm_call.transform = .identity
        })
    }
    
    @IBAction func GoBack(_ sender: UIButton) {

        let transition = CATransition()
        transition.duration = 0.5 // Set animation duration
        transition.type = CATransitionType.push // Set transition type to push
        transition.subtype = CATransitionSubtype.fromLeft // Set transition subtype to from right
        self.view.window?.layer.add(transition, forKey: kCATransition) // Add transition to window layer
    
        self.dismiss(animated: false)
        self.signalClient.sendRoomIdClose(roomId: self.roomUid)
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


//MARK: SignalClientDelegate
//extension ChatViewController: SignalClientDelegate {
//    func signalClientDidConnect(_ signalClient: SignalingClient) {
//        //REFME self.signalingConnected = true
//    }
//    
//    func signalClientDidDisconnect(_ signalClient: SignalingClient) {
//        //REFME self.signalingConnected = false
//    }
//    
//    func signalClient(_ signalClient: SignalingClient, didReceiveRemoteSdp sdp: RTCSessionDescription) {
//        print("Received remote sdp")
//        self.webRTCClient.set(remoteSdp: sdp) { (error) in
//            //REFME self.hasRemoteSdp = true
//        }
//    }
//    
//    func signalClient(_ signalClient: SignalingClient, didReceiveCandidate candidate: RTCIceCandidate) {
//        self.webRTCClient.set(remoteCandidate: candidate) { error in
//            print("Received remote candidate")
//            //REFME self.remoteCandidateCount += 1
//        }
//    }
//}

//MARK: WebRTCClientDelegate
extension ChatViewController: WebRTCClientDelegate {
    
    func webRTCClient(_ client: WebRTCClient, didDiscoverLocalCandidate candidate: RTCIceCandidate) {
        print("discovered local candidate")
        //REFME self.localCandidateCount += 1
        self.signalClient.send(candidate: candidate, roomId: self.roomUid)
    }
    
    func webRTCClient(_ client: WebRTCClient, didChangeConnectionState state: RTCIceConnectionState) {
//REFME
//        let textColor: UIColor
//        switch state {
//        case .connected, .completed:
//            textColor = .green
//        case .disconnected:
//            textColor = .orange
//        case .failed, .closed:
//            textColor = .red
//        case .new, .checking, .count:
//            textColor = .black
//        @unknown default:
//            textColor = .black
//        }
        DispatchQueue.main.async {
            //REFME self.webRTCStatusLabel?.text = state.description.capitalized
            //REFME self.webRTCStatusLabel?.textColor = textColor
        }
    }
    
    func webRTCClient(_ client: WebRTCClient, didReceiveData data: Data) {
        DispatchQueue.main.async {
            let message = String(data: data, encoding: .utf8) ?? "(Binary: \(data.count) bytes)"
            let messageWrap = PerfMessage(id: 0, senderUid: self.uid, receiverUid: self.muid, roomUid: self.roomUid, sendTime: Date.getStringFromDate(date: Date()), hadRead: false, message: message)
            self.messages.append(messageWrap) // Add the new message to the messages array
            self.messageCollectionView.reloadData() // Refresh the table view to display the new message
            // Scroll to the last item in collection view
            let lastItemIndex = self.messageCollectionView.numberOfItems(inSection: 0) - 1
            let lastIndexPath = IndexPath(item: lastItemIndex, section: 0)
            self.messageCollectionView.scrollToItem(at: lastIndexPath, at: .bottom, animated: true)
        }
    }
}
