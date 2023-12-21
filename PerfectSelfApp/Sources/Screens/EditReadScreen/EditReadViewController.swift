//
//  EditReadViewController.swift
//  PerfectSelf
//
//  Created by Kayan Mishra on 2/23/23.
//  Copyright © 2023 Stas Seldin. All rights reserved.
//
import UIKit
import Foundation
import WebRTC
import AVFoundation

protocol UpdatedTapeDelegate {
    func updatedTape( aAudioURL: URL?, rAudioURL: URL?)
}

class EditReadViewController: UIViewController {
    var delegate: UpdatedTapeDelegate?
    var videoURL: URL
    var audioURL: URL?
    var readerVideoURL: URL
    var readerAudioURL: URL
    let movie = AVMutableComposition()
    var videoMTrack: AVMutableCompositionTrack?
    var audioMTrack: AVMutableCompositionTrack? = nil
    var audioMTrack2: AVMutableCompositionTrack? = nil
    var editRange: CMTimeRange?
    var editAudioTrack: AVAssetTrack?
    var editVideoTrack: AVAssetTrack?
    var onActorVideoEdit: Bool
    var editAudioAsset: AVURLAsset?
    var editMovieAsset: AVURLAsset?
    //Omitted var timeSpan: Int = 0
    var trackSegmentRepo: TrackSegmentRepo?
    var tmpVRotateOffset: Int  = videoRotateOffset
    var timePauseChanged: Bool = false
    var audioNoiseChanged: Bool = false
    var playerThumbView: UIImageView?
    var videoApplyDone = false
    var audioApplyDone = false
    var actorAudioUploadDone = false
    var readerAudioUploadDone = false
    var noiseRemovalTimer: Timer? = nil
    var noiseRemovalReaderTimer: Timer? = nil
    var noiseRemovalCount = 0
    
    @IBOutlet weak var editBar: UIStackView!
    @IBOutlet weak var playerView: PlayerView!
    @IBOutlet weak var slider: UISlider!
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var startTimerLabel: UILabel!
    @IBOutlet weak var endTimerLabel: UILabel!
    @IBOutlet weak var uiTitleLabel: UILabel!
    @IBOutlet weak var undoButton: UIButton!
    @IBOutlet weak var redoButton: UIButton!
    @IBOutlet weak var subtractTimePauseBtn: UIButton!
    @IBOutlet weak var addTimePauseBtn: UIButton!
    @IBOutlet weak var redoBtn: UIButton!    
    @IBOutlet weak var undoBtn: UIButton!
    
    init(videoUrl: URL, audioUrl: inout URL?,  readerVideoUrl: URL, readerAudioUrl: URL, isActorVideoEdit: Bool) {
        self.videoURL = videoUrl
        self.audioURL = audioUrl
        self.readerVideoURL = readerVideoUrl
        self.readerAudioURL = readerAudioUrl
        self.onActorVideoEdit = isActorVideoEdit
        
        super.init(nibName: String(describing: EditReadViewController.self), bundle: Bundle.main)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    var timer = Timer()
    var jobId = ""
    var videoId = ""
    override func viewDidLoad() {
        //print(audioURL, videoURL)
        
        //Omitted        let affineTransform = CGAffineTransform(rotationAngle: degreeToRadian(90))
        //Omitted        playerView.playerLayer.setAffineTransform(affineTransform)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if( !onActorVideoEdit ){
            uiTitleLabel.text = "Edit Read"
        }
        else
        {
            uiTitleLabel.text = "Edit Final"
            subtractTimePauseBtn.isHidden = true
            addTimePauseBtn.isHidden = true
            redoBtn.isHidden = true
            undoBtn.isHidden = true
        }
        
        editBar.isHidden = !self.onActorVideoEdit
        setupPlayer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        playerView.stop()
    }
    
    func setupPlayer() {
        var initPlayer: Bool = true
        if audioMTrack != nil {
            initPlayer = false
            movie.removeTrack(audioMTrack!)
            movie.removeTrack(audioMTrack2!)
            movie.removeTrack(videoMTrack!)
        }
            
        videoMTrack = movie.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        audioMTrack = movie.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        audioMTrack2 = movie.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        editMovieAsset = AVURLAsset(url: videoURL) //1
        editAudioAsset = AVURLAsset(url: audioURL!)
        var editAudio2 = AVURLAsset(url: readerAudioURL)
        if( !onActorVideoEdit ){
            editMovieAsset = AVURLAsset(url: readerVideoURL)
            editAudioAsset = AVURLAsset(url: readerAudioURL)
            editAudio2 = AVURLAsset(url: audioURL!)
        }
        
        trackSegmentRepo = TrackSegmentRepo(range: CMTimeRange(start:.zero, duration: editAudioAsset!.duration))
        
        editRange = CMTimeRangeMake(start: CMTime.zero, duration: editMovieAsset!.duration) //3
        editAudioTrack = editAudioAsset!.tracks(withMediaType: .audio).first! //2
        let editAudioTrack2 = editAudio2.tracks(withMediaType: .audio).first! //2
        editVideoTrack = editMovieAsset!.tracks(withMediaType: .video).first!
        let rotateOffset = (onActorVideoEdit ? videoRotateOffset : 0)
        videoMTrack!.preferredTransform = transformForTrack(rotateOffset: CGFloat(rotateOffset))
        
        do{
            //Omitted videoMTrack?.insertEmptyTimeRange(CMTimeRangeMake(start: .zero, duration: CMTimeMake(value: 1, timescale: 1)))
            //Omitted try videoMTrack?.insertTimeRange(editRange!, of: editVideoTrack!, at: CMTimeMake(value: 1, timescale: 1)) //4
            try videoMTrack?.insertTimeRange(editRange!, of: editVideoTrack!, at: CMTime.zero)
            try audioMTrack?.insertTimeRange(editRange!, of: editAudioTrack!, at: CMTime.zero)
            
            if( onActorVideoEdit ){//Add other track in only case Edit Final
                try audioMTrack2?.insertTimeRange(editRange!, of: editAudioTrack2, at: CMTime.zero)
            }
        } catch {
            //handle error
            print(error)
        }
        
        //{{
        playerView.mainavComposition = movie
        //==
        //playerView.url = videoURL
        //==
        //playerView.avAsset = editMovie
        //}}
        if( initPlayer )
        {            
            //        playerView.playerItem?.videoComposition = videoComposition
            playerView.delegate = self
            slider.minimumValue = 0
            playerView.addObserver(self, forKeyPath: "status", context: nil)
        }
    }
    
    @IBAction func backDidTap(_ sender: UIButton) {
        //print(self.timeSpan)
        playerView.stop()
        
        if( !audioNoiseChanged
           && !timePauseChanged ){
            self.dismiss(animated: false)
            return
        }
        
        showConfirm(viewController: self, title: "Confirm", message: "Are you sure to apply changes?") { [self] UIAlertAction in
            videoRotateOffset = tmpVRotateOffset
            if( timePauseChanged || audioNoiseChanged)
            {
                videoApplyDone = true
                audioApplyDone = true
                if timePauseChanged {
                    videoApplyDone = false
                    audioApplyDone = false
                    self.applyTimePauseChange()
                }
                
                actorAudioUploadDone = true
                readerAudioUploadDone = true
                if audioNoiseChanged{
                    actorAudioUploadDone = false
                    readerAudioUploadDone = false
                    self.uploadBothAudios()
                }
                
                DispatchQueue.main.async {
                    showIndicator(sender: nil, viewController: self)
                }
                
                let _ = Timer.scheduledTimer(withTimeInterval: TimeInterval(200) / 1000, repeats: true, block: { timer in
                    if(self.videoApplyDone && self.audioApplyDone
                       && self.actorAudioUploadDone && self.readerAudioUploadDone ){
                        timer.invalidate()
                        self.delegate?.updatedTape(aAudioURL: self.audioURL!, rAudioURL: self.readerAudioURL)
                        DispatchQueue.main.async {
                            hideIndicator(sender: nil)
                            self.dismiss(animated: false)
                        }
                    }
                })
            }
            else{
                self.dismiss(animated: false)
            }
        } cancelHandler: { [self] UIAlertAction in
            self.dismiss(animated: false)
        }
    }
    
    @IBAction func playDidTap(_ sender: UIButton) {
        if playerView.rate > 0 {
            playerView.pause()
            //isPlaying = false
            playButton.setImage( UIImage(named: "play2")!, for: UIControl.State.normal)
        } else {
            playerView.play()
            //isPlaying = true
            playButton.setImage( UIImage(named: "pause.circle")!, for: UIControl.State.normal)
        }
    }
    
    @IBAction func playerSeekValueChanged(_ sender: UISlider) {
        showViewBy(currentTime: Double(sender.value), view: playerThumbView)
        playerView.currentTime = Double( sender.value )
    }
    
    
    @IBAction func settingDidTap(_ sender: UIButton)
    {
        playerView.pause()
    }
    
    @IBAction func addTimePause(_ sender: UIButton) {
        let controller = TimePauseViewController()
        controller.delegate = self
        controller.isAdding = true
        controller.modalPresentationStyle = .overFullScreen
        
        self.present(controller, animated: true)
    }
    
    
    @IBAction func removeTimePause(_ sender: UIButton) {
        let controller = TimePauseViewController()
        controller.delegate = self
        controller.isAdding = false
        controller.modalPresentationStyle = .overFullScreen
        
        self.present(controller, animated: true)
    }
    
    @IBAction func rotateDidTap(_ sender: UIButton)
    {
        playerView.pause()
        tmpVRotateOffset += 90
        tmpVRotateOffset %=  360
        
        videoMTrack!.preferredTransform = transformForTrack(rotateOffset: CGFloat(tmpVRotateOffset))
        playerView.mainavComposition = nil
        playerView.mainavComposition = movie
    }
    
    @IBAction func audioEditDidTap(_ sender: UIButton)
    {
        playerView.pause()
        
        guard let _ = audioURL else {
            return
        }
        
        //
        //{{do audio enhancement
        getJobIdForRemovalAudioNoise(uiCtrl: self, audioURL: self.audioURL!) { jobId in
            DispatchQueue.main.async {
                self.noiseRemovalTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(500) / 1000, repeats: true, block: { timer in
                    downloadClearAudio(uiCtrl: self, jobId: jobId) { [self] error, audioUrl in
                        if( self.noiseRemovalTimer!.isValid ){
                            self.noiseRemovalTimer!.invalidate()
                            if error == nil, audioUrl != nil{
                                self.audioURL = audioUrl
                                self.noiseRemovalCount += 1
//                                DispatchQueue.main.async {[self] in
//                                }
                            }
                        }
                    }
                })
            }
        }
        
        //Omitted if(self.readerAudioURL != nil){
        getJobIdForRemovalAudioNoise(uiCtrl: self, audioURL: self.readerAudioURL) { jobId in
            DispatchQueue.main.async {
                self.noiseRemovalReaderTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(500) / 1000, repeats: true, block: { timer in
                    downloadClearAudio(uiCtrl: self, jobId: jobId) {[self] error, audioUrl in
                        if( self.noiseRemovalReaderTimer!.isValid ){
                            self.noiseRemovalReaderTimer!.invalidate()
                            if error == nil, audioUrl != nil{
                                self.readerAudioURL = audioUrl!
                                self.noiseRemovalCount += 1
//                                DispatchQueue.main.async {[self] in
//                                }
                            }
                        }
                    }
                })
            }
        }
        //Omitted }
        //}}do audio enhancement
        showIndicator(sender:  nil, viewController: self, color: UIColor.white)
        _ = Timer.scheduledTimer(withTimeInterval: TimeInterval(100) / 1000, repeats: true, block: { timer in
            if(self.noiseRemovalCount >= 2){
                timer.invalidate()
                self.audioNoiseChanged = true
                
                self.setupPlayer()
                self.playerView.currentTime = Double(0)
                
                DispatchQueue.main.async {
                    hideIndicator(sender: nil)
                    Toast.show(message: "Audio noise-removal processing is done.", controller: self)
                }
            }
        })
    }
    
    @IBAction func gotoFirstDidTap(_ sender: UIButton) {
        slider.setValue(0, animated: false)
        playerView.currentTime = Double( 0)
        playerThumbView?.isHidden = false
    }
    
    @IBAction func backwardDidTap(_ sender: UIButton) {
        var curVal = slider.value
        curVal = curVal - 5
        if(curVal < 0) {curVal = 0}
        slider.setValue(curVal, animated: false)
        playerView.currentTime = Double( curVal)
    }
    
    @IBAction func forwardDidTap(_ sender: UIButton) {
        var curVal = slider.value
        curVal = curVal + 5
        if(curVal > slider.maximumValue) {curVal = slider.maximumValue}
        slider.setValue(curVal, animated: false)
        playerView.currentTime = Double( curVal)
    }
    
    @IBAction func gotoEndDidTap(_ sender: UIButton) {
        slider.setValue(slider.maximumValue, animated: false)
        playerView.currentTime = Double( slider.maximumValue)
    }
    
    @IBAction func redoDidTap(_ sender: UIButton) {
        self.undoManager?.redo()
        updateUndoButtons()
    }
    
    @IBAction func undoDidTap(_ sender: Any) {
        self.undoManager?.undo()
        updateUndoButtons()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if(object as? NSObject == playerView && keyPath == "status")
        {
            print(playerView.player?.status as Any)
        }
    }
    
    //new function
    @objc func timerAction(){
        audoAPI.getJobStatus(jobId: self.jobId) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    hideIndicator(sender: nil)
                    Toast.show(message: "Audio Enhancement failed. Unable to get job status.", controller: self)
                    return
                }
                return
            }
            do {
                struct JobStatus: Codable {
                    let state: String
                }
                let respItem = try JSONDecoder().decode(JobStatus.self, from: data)
                print("Job status ====> \(respItem.state)")
                if respItem.state == "succeeded" {
                    DispatchQueue.main.async {
                        self.timer.invalidate()
                    }
                    
                    struct JobStatusSucceed: Codable {
                        let state: String
                        let downloadPath: String
                    }
                    
                    do {
                        let res = try JSONDecoder().decode(JobStatusSucceed.self, from: data)
                        // download file
                        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
                        let saveFilePath = URL(fileURLWithPath: "\(documentsPath)/tmpAudio.mp3")
                        do {
                            try FileManager.default.removeItem(at: saveFilePath)
                            print("File deleted successfully")
                        } catch {
                            print("Error deleting file: \(error.localizedDescription)")
                        }
                        
                        audoAPI.getResultFile(downloadPath: res.downloadPath) { (tempLocalUrl, response, error) in
                            if let tempLocalUrl = tempLocalUrl, error == nil {
                                // Success
                                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                                    DispatchQueue.main.async {[self] in
                                        hideIndicator(sender: nil)
                                        Toast.show(message: "Audio Enhancement completed", controller: self)
                                        self.audioURL = saveFilePath
                                        //                                        self.mergeAudioWithVideo(videoUrl: self.videoURL, audioUrl: self.audioURL)
                                        editAudioAsset = AVURLAsset(url: audioURL!)
                                    }
                                    print("Successfully downloaded. Status code: \(statusCode)")
                                }
                                
                                do {
                                    try FileManager.default.copyItem(at: tempLocalUrl, to: saveFilePath)
                                } catch (let writeError) {
                                    DispatchQueue.main.async {
                                        hideIndicator(sender: nil)
                                        Toast.show(message: "Audio Enhancement failed while copying file to save.", controller: self)
                                    }
                                    print("Error creating a file \(saveFilePath) : \(writeError)")
                                }
                                
                            } else {
                                DispatchQueue.main.async {
                                    hideIndicator(sender: nil)
                                    Toast.show(message: "Audio Enhancement failed while downloading.", controller: self)
                                }
                                print("Error took place while downloading a file. Error description:", error?.localizedDescription as Any);
                            }
                        }
                    } catch {
                        DispatchQueue.main.async {
                            hideIndicator(sender: nil)
                            Toast.show(message: "Audio Enhancement failed. Unable to parse download path", controller: self)
                        }
                    }
                } else if respItem.state == "failed" {
                    DispatchQueue.main.async {
                        self.timer.invalidate()
                        hideIndicator(sender: nil)
                        Toast.show(message: "Audio Enhancement failed. Job status failed.", controller: self)
                    }
                    
                } else {
                    return
                }
                
            } catch {
                DispatchQueue.main.async {
                    hideIndicator(sender: nil)
                    Toast.show(message: "Audio Enhancement failed. Unable to parse job status.", controller: self)
                    return
                }
            }
        }
    }
    
    @IBAction func backgroundRemovalDidTap(_ sender: UIButton) {
        print("Edit Read Backgournd Removal func")
        playerView.pause()
        showIndicator(sender: nil, viewController: self, color: UIColor.white)
        backgroundAPI.uploadFile(filePath: videoURL) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    hideIndicator(sender: nil)
                    Toast.show(message: "Audio Enhancement failed. Unable to upload file.", controller: self)
                }
                return
            }
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("statusCode: \(httpResponse.statusCode)")
                // parse data
                do {
                    let res = try JSONDecoder().decode(BackRemoveResult.self, from: data)
                    DispatchQueue.main.async {
                        self.videoId = res.data.id
                        self.timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(self.timerActionForBackRemove), userInfo: nil, repeats: true)
                    }
                }
                catch {
                    DispatchQueue.main.async {
                        hideIndicator(sender: nil)
                        Toast.show(message: "Background Removal API response parse error!", controller: self)
                    }
                }
            }
        }
    }
    
    @objc func timerActionForBackRemove() {
        backgroundAPI.getFileStatus(videoId: self.videoId) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    hideIndicator(sender: nil)
                    Toast.show(message: "Audio Enhancement failed. Unable to upload file.", controller: self)
                }
                return
            }
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("statusCode: \(httpResponse.statusCode)")
                // parse data
                do {
                    let res = try JSONDecoder().decode(BackRemoveResult.self, from: data)
                    DispatchQueue.main.async {
                        if res.data.attributes.status == "done" {
                            //                            hideIndicator(sender: nil)
                            self.timer.invalidate()
                            // download file
                            let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
                            let saveFilePath = URL(fileURLWithPath: "\(documentsPath)/tmpVideo.mp4")
                            do {
                                try FileManager.default.removeItem(at: saveFilePath)
                                print("File deleted successfully")
                            } catch {
                                print("Error deleting file: \(error.localizedDescription)")
                            }
                            
                            audoAPI.getResultFile(downloadPath: res.data.attributes.result_url) { (tempLocalUrl, response, error) in
                                
                                if let tempLocalUrl = tempLocalUrl, error == nil {
                                    // Success
                                    if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                                        DispatchQueue.main.async {
                                            //                                            hideIndicator(sender: nil)
                                            //                                            Toast.show(message: "Audio Enhancement completed", controller: self)
                                            self.videoURL = saveFilePath
                                            self.mergeAudioWithVideo(videoUrl: self.videoURL, audioUrl: self.audioURL!)
                                        }
                                        print("Successfully downloaded. Status code: \(statusCode)")
                                    }
                                    
                                    do {
                                        try FileManager.default.copyItem(at: tempLocalUrl, to: saveFilePath)
                                    } catch (let writeError) {
                                        DispatchQueue.main.async {
                                            hideIndicator(sender: nil)
                                            Toast.show(message: "Audio Enhancement failed while copying file to save.", controller: self)
                                        }
                                        print("Error creating a file \(saveFilePath) : \(writeError)")
                                    }
                                    
                                } else {
                                    DispatchQueue.main.async {
                                        hideIndicator(sender: nil)
                                        Toast.show(message: "Audio Enhancement failed while downloading.", controller: self)
                                    }
                                    print("Error took place while downloading a file. Error description:", error?.localizedDescription as Any);
                                }
                            }
                        }
                    }
                }
                catch {
                    DispatchQueue.main.async {
                        hideIndicator(sender: nil)
                        Toast.show(message: "Background Removal file status API response parse error!", controller: self)
                    }
                }
            }
        }
    }
    
    @IBAction func cropDidTap(_ sender: Any) {
        playerView.pause()
    }
    
    @IBAction func shareDidTap(_ sender: UIButton) {
        playerView.pause()
        
        DispatchQueue.global(qos: .background).async {
            exportMergedVideo(avUrl: self.videoURL, aaUrl: self.audioURL!
                              , rvUrl: self.readerVideoURL, raUrl: self.readerAudioURL
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
                    
                    activityViewController.popoverPresentationController?.sourceView = sender// If your app is iPad-compatible, this line will set the source view for the popover
                    self.present(activityViewController, animated: true, completion: nil)
                }
            }
        }
    }
    
    func mergeAudioWithVideo(videoUrl: URL, audioUrl: URL) {
        let videoAsset = AVAsset(url: videoUrl)
        let audioAsset = AVAsset(url: audioUrl)
        let mainComposition = AVMutableComposition()
        
        let videoTrack = mainComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        let videoAssetTrack = videoAsset.tracks(withMediaType: .video).first!
        try? videoTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: videoAsset.duration), of: videoAssetTrack, at: CMTime.zero)
        videoTrack?.preferredTransform = videoAssetTrack.preferredTransform // THIS LINE IS IMPORTANT
        
        let audioMTrack = mainComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        let audioAssetTrack = audioAsset.tracks(withMediaType: .audio).first!
        try? audioMTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: audioAsset.duration), of: audioAssetTrack, at: CMTime.zero)
        
        let exportSession = AVAssetExportSession(asset: mainComposition, presetName: AVAssetExportPresetHighestQuality)
        guard
            let documentDirectory = FileManager.default.urls(
                for: .cachesDirectory,
                in: .userDomainMask).first
        else {
            DispatchQueue.main.async {
                hideIndicator(sender: nil)
                Toast.show(message: "Audio Enhancement failed while merging enhanced audio with video", controller: self)
            }
            return
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        var date = dateFormatter.string(from: Date())
        date += UUID().uuidString
        let mergedVideoURL = documentDirectory.appendingPathComponent("mergeVideo-\(date).mov")
        
        exportSession?.outputURL = mergedVideoURL
        exportSession?.outputFileType = .mov
        exportSession?.shouldOptimizeForNetworkUse = true
        
        exportSession?.exportAsynchronously {
            switch exportSession?.status {
            case .completed:
                print("Merged video saved to: \(mergedVideoURL)")
                self.videoURL = mergedVideoURL
                self.setupPlayer()
                DispatchQueue.main.async {
                    hideIndicator(sender: nil)
                    Toast.show(message: "Audio Enhancement completed", controller: self)
                }
            case .failed, .cancelled:
                print("Error merging video: \(String(describing: exportSession?.error.debugDescription))")
                DispatchQueue.main.async {
                    hideIndicator(sender: nil)
                    Toast.show(message: "Audio Enhancement failed while merging enhanced audio with video", controller: self)
                }
            default:
                break
            }
        }
    }
    
    func updateUndoButtons(){
        redoButton.isEnabled = undoManager!.canRedo
        undoButton.isEnabled = undoManager!.canUndo
    }
    
    func addTimePauseModule(pos: Float64, timeSpan: Int){
        let atTime: CMTime = CMTimeMakeWithSeconds( Float64(pos), preferredTimescale: 12000 )
        let timeDur: CMTime = CMTimeMakeWithSeconds( Float64(timeSpan), preferredTimescale: 1 )
        trackSegmentRepo!.addEmptySegment(range: CMTimeRange(start: atTime, duration: timeDur))
        applyTrackChange()
    }
    
    func substractimePauseModule(pos: Float64, timeSpan: Int){
        let atTime: CMTime = CMTimeMakeWithSeconds( Float64(pos), preferredTimescale: 12000 )
        let timeDur: CMTime = CMTimeMakeWithSeconds( Float64(-timeSpan), preferredTimescale: 1 )
        trackSegmentRepo!.deleteEmptySegment(range: CMTimeRange(start: atTime, duration: timeDur))
        applyTrackChange()
    }
    
    func applyTrackChange(){
        if( onActorVideoEdit ){
            trackSegmentRepo!.buildTrack(compositionVTrack: &videoMTrack!, vURL: videoURL, compositionATrack: &audioMTrack!, aURL: audioURL!)
        }
        else{
            trackSegmentRepo!.buildTrack(compositionVTrack: &videoMTrack!, vURL: readerVideoURL, compositionATrack: &audioMTrack!, aURL: readerAudioURL)
        }

        let curTime = playerView.currentTime
        playerView.currentTime = 0
        playerView.currentTime = curTime
    }
    
    func applyTimePauseChange(){
        let onlyVideo =  movie.mutableCopy() as! AVMutableComposition
        onlyVideo.tracks(withMediaType: .audio)[0].isEnabled = false
        onlyVideo.tracks(withMediaType: .audio)[1].isEnabled = false
        
        //{{ Apply to audio
        movie.removeTrack(videoMTrack!)//videoMTrack!.isEnabled = false//Omitted
        movie.removeTrack(audioMTrack2!)//audioMTrack2!.isEnabled = false//Omitted
        exportAudioWithTimeSpan(uiCtrl:  self, composition: movie
                                , audioMixInputParam:
                                    trackSegmentRepo!.getMixInputParams(compositionTrack: audioMTrack!)) { [self] (m4aUrl: URL?) in
            if(m4aUrl != nil) {
                //print(m4aUrl!)
                var userName = "Anymous"
                if let userInfo = UserDefaults.standard.object(forKey: "USER") as? [String:Any] {
                    // Use the saved data
                    userName = userInfo["userName"] as! String
                }
                
                var tapeKey = "\(selectedTape!.actorTapeKey).m4a"
                //Omitted audioURL = m4aUrl
                if( !onActorVideoEdit ){
                    //Omitted readerAudioURL = m4aUrl!
                    replaceOrgWithResult(org: readerAudioURL, result: m4aUrl!)
                    tapeKey = "\(selectedTape!.readerTapeKey!).m4a"
                }
                else{
                    replaceOrgWithResult(org: audioURL!, result: m4aUrl!)
                }
                
                DispatchQueue.main.async {
                    //Omitted showIndicator(sender: nil, viewController: self)
                    Toast.show(message: "Uploading audio file...", controller: self)
                }
                awsUpload.multipartUpload(filePath: m4aUrl!, bucketName: "video-client-upload-123456798", prefixKey: tapeKey, forceKey: true){ (error: Error?) -> Void in
                    self.audioApplyDone = true
                    DispatchQueue.main.async {
                        //Omitted hideIndicator(sender: nil)
                    }
                    
                    if(error == nil)
                    {//Then Upload video
                        log(meetingUid: "editread-save", log:"\(userName) audio upload end successfully.")
                        DispatchQueue.main.async {
                            //Omitted hideIndicator(sender: nil)
                            Toast.show(message: "Completed to upload audio file.", controller: self)
                        }
                    }
                    else
                    {
                        log(meetingUid: "editread-save", log:"\(userName) audio upload failed: \(error!.localizedDescription)")
                        DispatchQueue.main.async {
                            //Omitted hideIndicator(sender: nil)
                            Toast.show(message: "Failed to upload audio file", controller: self)
                        }
                    }
                }
            progressHandler: { (progressVal)->Void in
                print("progressHandler", progressVal)
                //Toast.show(message: "Upload progress", controller: uiViewContoller!)
            }
            }
        }
        //}} Apply to audio
        
        //{{Apply to video
        exportVideoWithTimeSpan(uiCtrl:  self, composition: onlyVideo ) { [self] (movUrl: URL?) in
            if(movUrl != nil) {
                //print(m4aUrl!)
                var userName = "Anymous"
                if let userInfo = UserDefaults.standard.object(forKey: "USER") as? [String:Any] {
                    // Use the saved data
                    userName = userInfo["userName"] as! String
                }
                
                var tapeKey = "\(selectedTape!.actorTapeKey).mp4"
                //Omitted videoURL = movUrl!
                if( !onActorVideoEdit ){
                    //Omitted readerVideoURL = movUrl!
                    replaceOrgWithResult(org: readerVideoURL, result: movUrl!)
                    tapeKey = "\(selectedTape!.readerTapeKey!).mp4"
                }
                else{
                    replaceOrgWithResult(org: videoURL, result: movUrl!)
                }
                
                DispatchQueue.main.async {
                    //Omitted showIndicator(sender: nil, viewController: self)
                    Toast.show(message: "Uploading video file...", controller: self)
                }
                awsUpload.multipartUpload(filePath: movUrl!, bucketName: "video-client-upload-123456798", prefixKey: tapeKey, forceKey: true){ (error: Error?) -> Void in
                    self.videoApplyDone = true
                    DispatchQueue.main.async {
                        //Omitted hideIndicator(sender: nil)
                    }
                    
                    if(error == nil)
                    {//Then Upload video
                        log(meetingUid: "editread-save", log:"\(userName) video upload end successfully.")
                        DispatchQueue.main.async {
                            //Omitted hideIndicator(sender: nil)
                            Toast.show(message: "Completed to upload video file.", controller: self)
                        }
                    }
                    else
                    {
                        log(meetingUid: "editread-save", log:"\(userName) video upload failed: \(error!.localizedDescription)")
                        DispatchQueue.main.async {
                            //Omitted hideIndicator(sender: nil)
                            Toast.show(message: "Failed to upload video file", controller: self)
                        }
                    }
                }
            progressHandler: { (progressVal)->Void in
                print("progressHandler", progressVal)
                Toast.show(message: "Upload progress", controller: uiViewContoller!)
            }
            }
        }
        //}}Apply to video
    }
    
    func uploadBothAudios(){
        //{{ Apply to audio
        let actorTapeKey = "\(selectedTape!.actorTapeKey).m4a"
        let readerTapeKey = "\(selectedTape!.readerTapeKey!).m4a"
        
        DispatchQueue.main.async {
            //Omitted showIndicator(sender: nil, viewController: self)
            Toast.show(message: "Uploading the best audio files...", controller: self)
        }
        
        awsUpload.multipartUpload(filePath: self.audioURL!, bucketName: "video-client-upload-123456798", prefixKey: actorTapeKey, forceKey: true){ (error: Error?) -> Void in
            self.actorAudioUploadDone = true
            DispatchQueue.main.async {
                //Omitted hideIndicator(sender: nil)
            }
            
            if(error == nil)
            {//Then Upload video
                print("actor audio upload done!")
            }
            else
            {
                print("aFailed to upload audio file!")
            }
        }progressHandler: { (progressVal)->Void in
            //print("progressHandler", progressVal)
            //Toast.show(message: "Upload progress", controller: uiViewContoller!)
        }
        
        awsUpload.multipartUpload(filePath: self.readerAudioURL, bucketName: "video-client-upload-123456798", prefixKey: readerTapeKey, forceKey: true){ (error: Error?) -> Void in
                    self.readerAudioUploadDone = true
                    DispatchQueue.main.async {
                        //Omitted hideIndicator(sender: nil)
                    }
                    
                    if(error == nil)
                    {//Then Upload video
                        print("actor audio upload done!")
                    }
                    else
                    {
                        print("aFailed to upload audio file!")
                    }
                }progressHandler: { (progressVal)->Void in
                    //print("progressHandler", progressVal)
                    //Toast.show(message: "Upload progress", controller: uiViewContoller!)
                }
        //}} Apply to audio
    }
}

extension EditReadViewController: PlayerViewDelegate {
    func playerVideo(player: PlayerView, currentTime: Double) {
        showViewBy(currentTime: currentTime, view: playerThumbView)
        slider.value = Float(currentTime)
    }
    
    func playerVideo(player: PlayerView, duration: Double) {
        slider.minimumValue = Float(0)
        slider.maximumValue =  Float(duration)//as seconds
        //        self.startTimerLabel.text = getCurrentTime(second:  0)
        //        self.endTimerLabel.text = getCurrentTime(second: duration)
        
        slider.value = 0.0
        playerView.currentTime = Double( 0 )
    }
    
    func playerVideo(player: PlayerView, statusItemPlayer: AVPlayer.Status, error: Error?) {
        
    }
    
    func playerVideo(player: PlayerView, statusItemPlayer: AVPlayerItem.Status, error: Error?) {
        initPlayerThumb(playerView: playerView, movie: movie) { view in
            if self.playerThumbView != nil{
                self.playerThumbView?.isHidden = true
            }
            
            self.playerThumbView = view
        }
    }
    
    func playerVideoDidEnd(player: PlayerView) {
        
    }
}

extension EditReadViewController: TimeSpanSelectDelegate{
    func addTimePause(timeSpan: Int) {
        print("addTimePause span=\(timeSpan) slider=\(slider.value)")
        timePauseChanged = true
        let backup = trackSegmentRepo!.backupSegments()
        addTimePauseModule(pos: Float64(slider.value), timeSpan: timeSpan)
        let cur = trackSegmentRepo!.backupSegments()
        applyTimePauseUndoActionRegister(backup: backup, cur: cur)
        updateUndoButtons()
    }
    
    func substractimePause(timeSpan: Int) {
        print("substractTimePause span=\(timeSpan) slider=\(slider.value)")
        timePauseChanged = true
        let backup = trackSegmentRepo!.backupSegments()
        substractimePauseModule(pos: Float64(slider.value), timeSpan: timeSpan)
        let cur = trackSegmentRepo!.backupSegments()
        applyTimePauseUndoActionRegister(backup: backup, cur: cur)
        updateUndoButtons()
    }
}

extension EditReadViewController {
    func applyTimePauseUndoActionRegister(backup: [TrackSegment], cur: [TrackSegment]){
        self.undoManager?.registerUndo(withTarget: self, handler: { (selfTarget) in
            selfTarget.trackSegmentRepo!.restoreSegments(backup: backup)
            selfTarget.applyTrackChange()
            selfTarget.applyTimePauseRedoActionRegister(backup: backup, cur: cur)
            selfTarget.updateUndoButtons()
        })
    }
    
    func applyTimePauseRedoActionRegister(backup: [TrackSegment], cur: [TrackSegment]){
        self.undoManager?.registerUndo(withTarget: self, handler: { (selfTarget) in
            selfTarget.trackSegmentRepo!.restoreSegments(backup: cur)
            selfTarget.applyTrackChange()
            selfTarget.applyTimePauseUndoActionRegister(backup: backup, cur: cur)
            selfTarget.updateUndoButtons()
        })
    }
}
