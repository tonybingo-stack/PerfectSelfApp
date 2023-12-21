//
//  ProjectViewController.swift
//  PerfectSelf
//
//  Created by Kayan Mishra on 2/26/23.
//  Copyright © 2023 Stas Seldin. All rights reserved.
//

import Foundation
import UIKit
import Photos
import HGCircularSlider
import SwiftUI

class ProjectViewController: UIViewController {
    
    @IBOutlet weak var playerBar: UISlider!
    @IBOutlet var startTime: UILabel!
    @IBOutlet var endTime: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var projectName: UILabel!
        
    @IBOutlet weak var editReadButton: UIButton!
    @IBOutlet weak var newTakeButton: UIButton!
    @IBOutlet weak var editFinalButton: UIButton!
    var savedVideoUrl: URL? = nil
    var savedAudioUrl: URL? = nil
    var savedReaderVideoUrl: URL? = nil
    var savedReaderAudioUrl: URL? = nil
    var doneReaderAVDownload: Bool = false
    @IBOutlet weak var playerView: PlayerView!
    @IBOutlet weak var actorPlayerView: PlayerView!
    var mainPlayerView: PlayerView? = nil//Will be player that duration is more long than other.
    var mainDuration: Double = -1.0
    //Omitted let awsUpload = AWSMultipartUpload()
    var startElapseTime: Date?
    var endElapseTime: Date?
    var actorVTrack: AVMutableCompositionTrack?
    var aPlayerThumbView: UIImageView? = nil
    var avdownloadProgress: Float = 0
    var aadownloadProgress: Float = 0
    var rvdownloadProgress: Float = 0
    var radownloadProgress: Float = 0
    @IBOutlet weak var rPlayerThumbView: UIImageView!
    let semaphore = DispatchSemaphore(value: 1)
    var noiseRemovalTimer: Timer? = nil
    var noiseRemovalReaderTimer: Timer? = nil
    var noiseRemovalCount = 0
    
    @IBOutlet weak var downloadProgressView: CircularSlider!
    @IBOutlet weak var downloadProgressLabel: UILabel!
    let actorAV = AVMutableComposition()
    let readerAV = AVMutableComposition()
    
    private var isOnPlay: Bool = true {
        didSet {
            DispatchQueue.main.async {
                if self.isOnPlay
                {
                    self.playButton.setBackgroundImage( UIImage(named: "pause.circle")!.withRenderingMode(.alwaysTemplate), for: UIControl.State.normal)
                    self.playButton.tintColor = UIColor.white
                    self.playButton.imageView?.tintColor = UIColor.white
                    self.playerView.play()
                    self.actorPlayerView.play()
                }
                else
                {
                    self.playButton.setBackgroundImage( UIImage(named: "play.circle")!.withRenderingMode(.alwaysTemplate), for: UIControl.State.normal)
                    self.playButton.tintColor = UIColor.white
                    self.playButton.imageView?.tintColor = UIColor.white
                    self.playerView.pause()
                    self.actorPlayerView.pause()
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        actorVTrack?.preferredTransform = transformForTrack(rotateOffset: CGFloat(videoRotateOffset))
    }
    
    override func  viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let actorThumb = "https://video-thumbnail-bucket-123456789.s3.us-east-2.amazonaws.com/\(selectedTape!.actorTapeKey)-0.jpg"
        let readerTapeKey = (selectedTape!.readerTapeKey == nil ? "" : selectedTape!.readerTapeKey)
        let readerThumb = "https://video-thumbnail-bucket-123456789.s3.us-east-2.amazonaws.com/\(readerTapeKey!)-0.jpg"
        
        aPlayerThumbView = initPlayerThumbEx(playerView: self.actorPlayerView, url: URL(string: actorThumb), thumbImgView: aPlayerThumbView)
        _ = initPlayerThumbEx(playerView: self.playerView, url: URL(string: readerThumb), thumbImgView: rPlayerThumbView)
        //print("viewDidLayoutSubviews")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        guard let _ = selectedTape!.readerUid else{
            editReadButton.isEnabled = false
            newTakeButton.isEnabled = false
            editFinalButton.isEnabled = false
            Toast.show(message:  "Can't find reader video.", controller:  self)
            return
        }
        
        editReadButton.isEnabled = true
        newTakeButton.isEnabled = true
        editFinalButton.isEnabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool){
        isOnPlay = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.playerView.delegate = self
        self.actorPlayerView.delegate = self
        self.projectName.text = getProjectName(tape: selectedTape!)
        
        let tapGesture = UITapGestureRecognizer(target: self, action:  #selector(didTapIndicatorView(_:)))
        downloadProgressView.addGestureRecognizer(tapGesture)
        
        downloadProgressView.minimumValue = 0.0
        downloadProgressView.maximumValue = 1.0
        downloadProgressView.endPointValue = 0.00 // the progress
        downloadProgressView.isUserInteractionEnabled = false
        downloadProgressView.thumbLineWidth = 0.0
        downloadProgressView.thumbRadius = 0.0
        downloadProgressView.diskColor = UIColor(rgb: 0xc2deff)
        downloadProgressLabel.text="  0%"
        
        ConferenceViewController.clearTempFolder()
        
        downloadLibraryTape {
#if AUTO_NOISE_REMOVAL
            self.noiseRemovalCount = 0
            DispatchQueue.main.async {
                showIndicator(sender: nil, viewController: self, color: UIColor.white)
                Toast.show(message: "On processing noise-removal for actor and reader audios.", controller: self)
            }
            //{{Removal noise from audio
            getJobIdForRemovalAudioNoise(uiCtrl: self, audioURL: self.savedAudioUrl!) { jobId in
                DispatchQueue.main.async {
                    self.noiseRemovalTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(500) / 1000, repeats: true, block: { timer in
                        downloadClearAudio(uiCtrl: self, jobId: jobId) { [self] error, audioUrl in
                            if( self.noiseRemovalTimer!.isValid ){
                                self.noiseRemovalTimer!.invalidate()
                                if error == nil, audioUrl != nil{
                                    self.savedAudioUrl = audioUrl
                                    DispatchQueue.main.async {[self] in
                                        actorVTrack = initAVMutableComposition(avMComp: actorAV, videoURL: self.savedVideoUrl!, audioURL: self.savedAudioUrl!, rotate: videoRotateOffset)
                                        self.actorPlayerView.mainavComposition = actorAV
                                        
                                        self.noiseRemovalCount += 1
                                    }
                                }
                            }
                        }
                    })
                }
            }
            
            if(self.savedReaderAudioUrl == nil){
                DispatchQueue.main.async {
                    hideIndicator(sender: nil)
                    Toast.show(message: "Reader Tape Error.", controller: self)
                }
                return
            }
            
            getJobIdForRemovalAudioNoise(uiCtrl: self, audioURL: self.savedReaderAudioUrl!) { jobId in
                DispatchQueue.main.async {
                    self.noiseRemovalReaderTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(500) / 1000, repeats: true, block: { timer in
                        downloadClearAudio(uiCtrl: self, jobId: jobId) {[self] error, audioUrl in
                            if( self.noiseRemovalReaderTimer!.isValid ){
                                self.noiseRemovalReaderTimer!.invalidate()
                                if error == nil, audioUrl != nil{
                                    self.savedReaderAudioUrl = audioUrl
                                    DispatchQueue.main.async {[self] in
                                        _ = initAVMutableComposition(avMComp: readerAV, videoURL: self.savedReaderVideoUrl!, audioURL: self.savedReaderAudioUrl!)
                                        self.playerView.mainavComposition = readerAV
                                        
                                        self.noiseRemovalCount += 1
                                    }
                                }
                            }
                        }
                    })
                }
            }
            //}}Removal noise from audio
#else
            self.noiseRemovalCount = 2
            DispatchQueue.main.async {[self] in
                actorVTrack = initAVMutableComposition(avMComp: actorAV, videoURL: self.savedVideoUrl!, audioURL: self.savedAudioUrl!, rotate: videoRotateOffset)
                self.actorPlayerView.mainavComposition = actorAV
                
                if(self.savedReaderAudioUrl != nil && self.savedReaderVideoUrl != nil){
                    _ = initAVMutableComposition(avMComp: readerAV, videoURL: self.savedReaderVideoUrl!, audioURL: self.savedReaderAudioUrl!)
                    self.playerView.mainavComposition = readerAV
                }
            }
#endif
            
            _ = Timer.scheduledTimer(withTimeInterval: TimeInterval(100) / 1000, repeats: true, block: { timer in
                if(self.noiseRemovalCount >= 2
                   && self.playerView.player?.status == AVPlayer.Status.readyToPlay
                   && self.actorPlayerView.player?.status == AVPlayer.Status.readyToPlay){
                    timer.invalidate()
                    DispatchQueue.main.async {
#if AUTO_NOISE_REMOVAL
                        hideIndicator(sender: nil)
                        Toast.show(message: "Audio noise-removal processing is done.", controller: self)
#endif
                        self.actorPlayerView.play()
                        self.playerView.play()
                        
#if OVERLAY_TEST
                        var count = 2
                        _ = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { timer in
                            count -= 1
                            if count == 0 {
                                timer.invalidate()
                                self.recordNewTakeDidTapped(UIButton())
                            }
                        })
#endif//OVERLAY_TEST
                    }
                }
            })
        }
    }
    
    @IBAction func deleteDidTap(_ sender: UIButton) {
        showConfirm(viewController: self, title: "Confirm", message: "Are you sure to delete?") { [self] UIAlertAction in
            //print("Ok button tapped")
            webAPI.getTapeCountByKey( tapeKey: selectedTape!.actorTapeKey ){ data, response, error in
                guard let data = data, error == nil else {
                    print(error?.localizedDescription ?? "No data")
                    return
                }
                do {
                    let resp = try JSONDecoder().decode(TapeCount.self, from: data)
                    print(resp.tapeCount)
                    if(resp.tapeCount == 1){
                        awsUpload.deleteFile(bucket: selectedTape!.bucketName, key: "\(selectedTape!.actorTapeKey).mp4")
                        awsUpload.deleteFile(bucket: selectedTape!.bucketName, key: "\(selectedTape!.actorTapeKey).m4a")
                    }
                } catch {
                    print(error)
                }
            }
            
            webAPI.getTapeCountByKey( tapeKey: selectedTape!.readerTapeKey ){ data, response, error in
                guard let data = data, error == nil else {
                    print(error?.localizedDescription ?? "No data")
                    return
                }
                do {
                    let resp = try JSONDecoder().decode(TapeCount.self, from: data)
                    print(resp.tapeCount)
                    if(resp.tapeCount == 1){
                        awsUpload.deleteFile(bucket: selectedTape!.bucketName, key: "\(String(describing: selectedTape!.readerTapeKey)).mp4")
                        awsUpload.deleteFile(bucket: selectedTape!.bucketName, key: "\(String(describing: selectedTape!.readerTapeKey)).m4a")
                    }
                } catch {
                    print(error)
                }
            }
            
            webAPI.deleteTapeByUid(uid: selectedTape!.actorUid, tapeKey: selectedTape!.actorTapeKey, roomUid: selectedTape!.roomUid, tapeId: selectedTape!.tapeId) { data, urlResponse, error in
            }
            webAPI.deleteTapeByUid(uid: selectedTape!.readerUid, tapeKey: selectedTape!.readerTapeKey, roomUid: selectedTape!.roomUid, tapeId: selectedTape!.tapeId) { data, urlResponse, error in
            }
            
            backDidTapped(UIButton())
        } cancelHandler: { UIAlertAction in
            //print("Cancel button tapped")
        }
    }
    
    @IBAction func didTapIndicatorView(_ sender: UITapGestureRecognizer) {
        //print("did tap view", sender)
        awsUpload.cancelDownload()
        hideIndicator(sender: nil)
        downloadProgressView.isHidden = true
    }
    
    @IBAction func backDidTapped(_ sender: UIButton?) {
        isOnPlay = false
        self.dismiss(animated: false)
    }
    
    @IBAction func recordNewTakeDidTapped(_ sender: UIButton) {
        if(  AVCaptureDevice.authorizationStatus(for: .video) != .authorized ||
               AVCaptureDevice.authorizationStatus(for: .audio) != .authorized ){
            requestCameraAndAudioPermission{ [self] in
                DispatchQueue.main.async { [self] in
                    showOverlayUI()
                }
            }
           return
        }
        showOverlayUI()
    }
    
    /// Marker: Edit Final
    @IBAction func editDidTapped(_ sender: UIButton) {
        guard self.savedVideoUrl != nil else {
            return
        }
        isOnPlay = false
        
        downloadReaderVideoAsync(silent: false, completionHandler: { () in
            guard  let _ = self.savedReaderVideoUrl, let  _ = self.savedReaderAudioUrl else{
                return
            }
            
            let editReadViewController = EditReadViewController(videoUrl: self.savedVideoUrl!, audioUrl: &self.savedAudioUrl, readerVideoUrl: self.savedReaderVideoUrl!, readerAudioUrl: self.savedReaderAudioUrl!, isActorVideoEdit: true)
            editReadViewController.modalPresentationStyle = .fullScreen
            editReadViewController.delegate = self
            self.present(editReadViewController, animated: false, completion: nil)
        })
    }
    
    /// Marker: Edit Read
    @IBAction func editReadDidTapped(_ sender: UIButton)
    {
        guard self.savedVideoUrl != nil else{
            return
        }
        isOnPlay = false
        
        downloadReaderVideoAsync(silent: false, completionHandler: { () in
            guard  let _ = self.savedReaderVideoUrl, let  _ = self.savedReaderAudioUrl else{
                return
            }
            
            let editReadViewController = EditReadViewController(videoUrl: self.savedVideoUrl!, audioUrl: &self.savedAudioUrl, readerVideoUrl: self.savedReaderVideoUrl!, readerAudioUrl: self.savedReaderAudioUrl!, isActorVideoEdit: false)
            editReadViewController.modalPresentationStyle = .fullScreen
            editReadViewController.delegate = self
            self.present(editReadViewController, animated: false, completion: nil)
        })
    }
    
    @IBAction func sliderValueChanged(_ sender: Any) {
        playerView.currentTime = Double( playerBar.value )
        actorPlayerView.currentTime = Double( playerBar.value )
        
        showViewBy(currentTime: Double(playerBar.value), view: aPlayerThumbView)
        showViewBy(currentTime: Double(playerBar.value), view: rPlayerThumbView)
    }
    
    @IBAction func playDidTapped(_ sender: UIButton) {
        self.isOnPlay = !self.isOnPlay
    }
    
    @IBAction func shareDidTap(_ sender: UIButton) {
    }
    
    @IBAction func exportDidTap(_ sender: UIButton?) {
        print("exportDidTap")
        self.isOnPlay = false
        
        if(savedVideoUrl == nil
           || savedAudioUrl == nil
           || savedReaderVideoUrl == nil
           || savedReaderAudioUrl == nil)
        {
            showConfirm(viewController: self, title: "Confirm", message: "You need to download tapes from library. Are you sure to download?") { [self] UIAlertAction in
                //print("Ok button tapped")
                self.downloadLibraryTape {
                    self.exportToLocalGallery()
                }
            } cancelHandler: { UIAlertAction in
                //print("Cancel button tapped")
            }
            return
        }
        
        self.exportToLocalGallery()
    }
    
    func showOverlayUI(){
        guard AVCaptureDevice.authorizationStatus(for: .video) == .authorized, AVCaptureDevice.authorizationStatus(for: .audio) == .authorized else{
            Toast.show(message: "Can't gain the permission to use camera and microphoen.", controller:  self)
            return
        }
        
        guard self.savedVideoUrl != nil else{
            return
        }
        isOnPlay = false
        
        downloadReaderVideoAsync(silent: false, completionHandler: { () in
            guard  let _ = self.savedReaderVideoUrl, let  _ = self.savedReaderAudioUrl else{
                return
            }
            
            let overlayViewController = OverlayViewController()
            overlayViewController.uploadVideourl = self.savedReaderVideoUrl
            overlayViewController.uploadAudiourl = self.savedReaderAudioUrl
            overlayViewController.modalPresentationStyle = .fullScreen
            self.present(overlayViewController, animated: false, completion: nil)
        })
    }
    
    func downloadReaderVideoAsync(silent: Bool, completionHandler: @escaping () -> Void )-> Void
    {
        guard let _ = self.savedReaderVideoUrl, let _ = self.savedReaderAudioUrl else{
            let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
            let filePath = URL(fileURLWithPath: "\(documentsPath)/tempReaderFile.mp4")
            do {
                try FileManager.default.removeItem(at: filePath)
                //print("File deleted successfully")
            } catch {
                //print("Error deleting file: \(error.localizedDescription)")
            }
            
            awsUpload.downloadEx(filePath: filePath, bucketName: selectedTape!.bucketName, key: "\(selectedTape!.readerTapeKey ?? "").mp4") { (error) -> Void in
                if error != nil {
                    //print(error!.localizedDescription)
                    self.savedReaderVideoUrl = nil
                    DispatchQueue.main.async {
                        if( !silent ){hideIndicator(sender: nil)}
                        Toast.show(message: "Faild to download reader video from library", controller: self)
                    }
                    completionHandler()
                }
                else{
                    self.savedReaderVideoUrl = filePath
                    
                    //Download audio file
                    var filePath = URL(fileURLWithPath: "\(documentsPath)/tempReaderFile.m4a")
                    do {
                        try FileManager.default.removeItem(at: filePath)
                        //print("File deleted successfully")
                    } catch {
                        //print("Error deleting file: \(error.localizedDescription)")
                    }
                    awsUpload.downloadEx(filePath: filePath, bucketName: selectedTape!.bucketName, key: "\(selectedTape!.readerTapeKey ?? "").m4a") { (error) -> Void in
                        DispatchQueue.main.async {
                            if( !silent ){hideIndicator(sender: nil)}
                        }
                        
                        if error != nil {
                            //print(error!.localizedDescription)
                            self.savedReaderAudioUrl = nil
                            DispatchQueue.main.async {
                                Toast.show(message: "Faild to download reader audio from library", controller: self)
                            }
                        }
                        else{
                            checkMP3( audioFile: &filePath )
                            self.savedReaderAudioUrl = filePath
//                            let overlayViewController = OverlayViewController()
//                            overlayViewController.uploadVideourl = self.savedReaderVideoUrl
//                            overlayViewController.uploadAudiourl = self.savedReaderAudioUrl
//                            overlayViewController.modalPresentationStyle = .fullScreen
//                            self.present(overlayViewController, animated: false, completion: nil)
                        }
                        completionHandler()
                    }progressHandler:{(prog) -> Void in
                        self.radownloadProgress = prog
                        self.progressHandler()
                    }
                }
            }progressHandler:{(prog) -> Void in
                self.rvdownloadProgress = prog
                self.progressHandler()
            }
            
            Toast.show(message: "Start to download reader video and audio...", controller: self)
            DispatchQueue.main.async {
                if( !silent ){showIndicator(sender: nil, viewController: self, color:UIColor.white)}
            }
            return
        }
        
        completionHandler()
    }
    
    func exportToLocalGallery(){
//        guard let _=savedVideoUrl,  let _=savedAudioUrl, let _=savedReaderVideoUrl, let _=savedReaderAudioUrl else{
//            return
//        }
        DispatchQueue.global(qos: .background).async {
            exportMergedVideo(avUrl: self.savedVideoUrl!, aaUrl: self.savedAudioUrl!
                              , rvUrl: self.savedReaderVideoUrl!, raUrl: self.savedReaderAudioUrl!
                              , vc: self) { url in
                DispatchQueue.main.async {
                    guard let _ = url else{
                        Toast.show(message: "Failed during export result video.", controller: self)
                        return
                    }
                    
                    //let textToShare = "Share this awesome video."
                    let activityViewController = UIActivityViewController(activityItems: [url!/*, textToShare*/], applicationActivities: nil)
                    
                    // If you want to exclude certain activities, you can set excludedActivityTypes
                    activityViewController.excludedActivityTypes = [
                        //.addToReadingList,
                        //.assignToContact,
                        //.print,
                        // Add any other activity types you want to exclude
                    ]
                    
                    //Omitted activityViewController.popoverPresentationController?.sourceView = sender// If your app is iPad-compatible, this line will set the source view for the popover
                    self.present(activityViewController, animated: true, completion: nil)
                }
            }
        }
    }
    
    func downloadLibraryTape(completionHandler: @escaping () -> Void)-> Void
    {
        downloadProgressView.isHidden = false
        avdownloadProgress = 0
        aadownloadProgress = 0
        rvdownloadProgress = 0
        radownloadProgress = 0
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
        let filePath = URL(fileURLWithPath: "\(documentsPath)/tempFile.mp4")
        do {
            try FileManager.default.removeItem(at: filePath)
            //print("File deleted successfully")
        } catch {
            //print("Error deleting file: \(error.localizedDescription)")
        }
        
        //Omitted startElapseTime = Date()
        //Omitted showIndicator(sender: nil, viewController: self, color:UIColor.white)
        awsUpload.downloadEx(filePath: filePath, bucketName: selectedTape!.bucketName, key: "\(selectedTape!.actorTapeKey).mp4") { [self] (error) -> Void in
            if error != nil {
                 //print(error!.localizedDescription)
                self.savedVideoUrl = nil
                DispatchQueue.main.async {
                    hideIndicator(sender: nil)
                    Toast.show(message: "Faild to download video from library", controller: self)
                }
            }
            else{
                //Omitted self.endElapseTime = Date()
                //Omitted let elapsed = self.endElapseTime!.timeIntervalSince(self.startElapseTime!)
                //Omitted print("Elapsed time: \(elapsed) seconds")
                
                self.savedVideoUrl = filePath
                
                //Download audio file
                var filePath = URL(fileURLWithPath: "\(documentsPath)/tempFile.m4a")
                do {
                    try FileManager.default.removeItem(at: filePath)
                    //print("File deleted successfully")
                } catch {
                    //print("Error deleting file: \(error.localizedDescription)")
                }
                
                awsUpload.downloadEx(filePath: filePath, bucketName: selectedTape!.bucketName, key: "\(selectedTape!.actorTapeKey).m4a") { [self] (error) -> Void in
                    if error != nil {
                         //print(error!.localizedDescription)
                        self.savedAudioUrl = nil
                        hideIndicator(sender: nil)
                        DispatchQueue.main.async {
                            Toast.show(message: "Faild to download audio from library", controller: self)
                        }
                    }
                    else{
                        checkMP3( audioFile: &filePath )
                        self.savedAudioUrl = filePath
                        DispatchQueue.main.async { [self] in
//                            actorVTrack = initAVMutableComposition(avMComp: actorAV, videoURL: self.savedVideoUrl!, audioURL: self.savedAudioUrl!, rotate: videoRotateOffset)
//                            self.actorPlayerView.mainavComposition = actorAV
                            //Omitted self.actorPlayerView.play()
                            
                            //{{Wait until download both
                            DispatchQueue.main.async {
                                _ = Timer.scheduledTimer(withTimeInterval: TimeInterval(100) / 1000, repeats: true, block: { timer in
                                    guard self.doneReaderAVDownload == true else{
                                        return
                                    }
                                    timer.invalidate()
                                    hideIndicator(sender: nil)
                                    self.downloadProgressView.isHidden = true
                                    completionHandler()
                                })
                            }
                            //}}Wait until download both
                        }
                    }
                }progressHandler:{(prog) -> Void in
                    self.aadownloadProgress = prog
                    self.progressHandler()
                }
            }
        }progressHandler:{(prog) -> Void in
            self.avdownloadProgress = prog
            self.progressHandler()
        }
        
        doneReaderAVDownload = false
        downloadReaderVideoAsync(silent: true) {
            self.doneReaderAVDownload = true
            guard  let _ = self.savedReaderVideoUrl, let  _ = self.savedReaderAudioUrl else{
                return
            }
            
            DispatchQueue.main.async {
//                _ = initAVMutableComposition(avMComp: readerAV, videoURL: self.savedReaderVideoUrl!, audioURL: self.savedReaderAudioUrl!)
//                self.playerView.mainavComposition = readerAV
                //Omitted self.playerView.play()
            }
        }
        
        DispatchQueue.main.async { [self] in
            //Omitted showIndicator(sender: nil, viewController: self, color:UIColor.white)
            let tapGesture = UITapGestureRecognizer(target: self, action:  #selector(didTapIndicatorView(_:)))
            backgroundView!.addGestureRecognizer(tapGesture)
            Toast.show(message: "To cancel download from library, please tap screen.", controller: self)
        }
    }
    
    func progressHandler(){
        self.semaphore.wait()
        self.downloadProgressView.endPointValue = CGFloat(((self.avdownloadProgress + self.aadownloadProgress + self.rvdownloadProgress + self.radownloadProgress)/4.0))
        let value = self.downloadProgressView.endPointValue
        self.downloadProgressLabel.text = String(format: "%3 d%%", Int(value*100))
        self.semaphore.signal()
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

extension ProjectViewController: PlayerViewDelegate{
    func playerVideo(player: PlayerView, currentTime: Double) {
        //player.pause()
        //self.playerView.updateFocusIfNeeded()
        DispatchQueue.main.async {[self] in
            if(self.playerView == player){
                //print("Reader Player")
                showViewBy(currentTime: currentTime, view: rPlayerThumbView)
            }
            else if(self.actorPlayerView == player){
                //print("Actor Player")
                showViewBy(currentTime: currentTime, view: aPlayerThumbView)
            }
            
            if(mainPlayerView == player){
                playerBar.value =  Float(currentTime)
            }
        }
    }
    
    func playerVideo(player: PlayerView, duration: Double) {
        //player.currentTime = duration/100
        //player.player!.seek(to: CMTime(value: 1, timescale: 600))
        DispatchQueue.main.async {[self] in
            if(mainPlayerView == nil){
                mainPlayerView = player
                mainDuration = duration
            }
            else{
                if(mainDuration < duration){
                    mainPlayerView = player
                    mainDuration = duration
                }
                
                playerBar.minimumValue = Float(0)
                playerBar.maximumValue =  Float(mainDuration)
                self.startTime.text = getCurrentTime(second:  0)
                self.endTime.text = getCurrentTime(second: mainDuration)
                playerBar.value = 0.0
            }
        }
    }
    
    func playerVideo(player: PlayerView, statusItemPlayer: AVPlayer.Status, error: Error?) {
    }
    
    func playerVideo(player: PlayerView, statusItemPlayer: AVPlayerItem.Status, error: Error?) {
    }
    
    func playerVideoDidEnd(player: PlayerView) {
//        if(self.playerView == player){
//            //print("Reader Player")
//        }
//        else if(self.actorPlayerView == player){
//            //print("Actor Player")
//        }
        if(mainPlayerView == player){
            isOnPlay = false
        }
    }
}

extension ProjectViewController: UpdatedTapeDelegate {
    func updatedTape(aAudioURL: URL?, rAudioURL: URL?){
        mainPlayerView = nil
        mainDuration = -1.0
        
        if aAudioURL != nil && rAudioURL != nil{
            self.savedAudioUrl = aAudioURL
            self.savedReaderAudioUrl = rAudioURL
        }
        
        DispatchQueue.main.async {[self] in
            actorVTrack = initAVMutableComposition(avMComp: actorAV, videoURL: self.savedVideoUrl!, audioURL: self.savedAudioUrl!, rotate: videoRotateOffset)
            self.actorPlayerView.mainavComposition = actorAV

            if(self.savedReaderAudioUrl != nil && self.savedReaderVideoUrl != nil){
                _ = initAVMutableComposition(avMComp: readerAV, videoURL: self.savedReaderVideoUrl!, audioURL: self.savedReaderAudioUrl!)
                self.playerView.mainavComposition = readerAV
            }
        }
    }
}
