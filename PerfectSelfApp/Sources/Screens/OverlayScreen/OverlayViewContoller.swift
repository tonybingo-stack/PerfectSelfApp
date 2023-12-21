//
//  OverlayViewContoller.swift
//  PerfectSelf
//
//  Created by Kayan Mishra on 2/27/23.
//  Copyright © 2023 Stas Seldin. All rights reserved.
//
import UIKit
import AVFoundation
import Photos

class OverlayViewController: UIViewController {
    
    @IBOutlet var cameraView: CameraPreviewView!
    @IBOutlet var playerView: PlayerView!
    var uploadVideourl: URL?
    var uploadAudiourl: URL?
    @IBOutlet var activityMonitor: UIActivityIndicatorView!
    @IBOutlet var containerView: UIView!
    @IBOutlet var slider: UISlider!
    @IBOutlet var lblTimer: UILabel!
    @IBOutlet var btnTimer: UIButton!
    @IBOutlet var btnRecord: UIButton!
    @IBOutlet var btnStop: UIButton!
    @IBOutlet weak var timeSelectCtrl: UIPickerView!
    @IBOutlet weak var timeSelectPannel: UIView!
    @IBOutlet weak var btnBack: UIButton!
    var playerThumbView: UIImageView?
    var movie: AVMutableComposition?
    
    var count = 3
    var timer: Timer!
    var selectedCount = 3
    
    private var waitSecKey: String = "REC_WAIT_SEC"
    
    private var isOnRecording: Bool = false {
        didSet {
            DispatchQueue.main.async {
                if self.isOnRecording == false
                {
                    self.btnRecord.titleLabel?.text = "Start Recording"
                }
                else if self.isOnRecording == true
                {
                    self.btnRecord.titleLabel?.text = "Stop Recording"
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let waitSec = UserDefaults.standard.integer(forKey: self.waitSecKey)
        count = waitSec == 0 ? 3 : waitSec
        selectedCount = count
        self.timeSelectCtrl.delegate = self
        self.timeSelectCtrl.dataSource = self
        
        //Omitted self.containerView.isHidden = true
        cameraView.delegate = self
        guard let _ = uploadVideourl else { return }
        movie = getComposition(videoUrl:  uploadVideourl!, audioUrl:  uploadAudiourl!)
        playerView.mainavComposition = movie
        playerView.delegate = self
        //Omitted let affineTransform = CGAffineTransform(rotationAngle: degreeToRadian(90))
        //Omitted playerView.playerLayer.setAffineTransform(affineTransform)
        //Omitted slider.minimumValue = 0
        //Omitted btnStop.isEnabled = false
        btnRecord.isEnabled = true
        //Omitted btnTimer.isEnabled = true
        lblTimer.isHidden = true
    }
    
    func getComposition(videoUrl: URL, audioUrl: URL) -> AVMutableComposition{
        let videoAsset = AVAsset(url: videoUrl)
        let audioAsset = AVAsset(url: audioUrl)
        
        let mixComposition = AVMutableComposition()
        guard
            let videoTrack = mixComposition.addMutableTrack(
                withMediaType: .video,
                preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
        else { return mixComposition }

        do {
            videoTrack.preferredTransform = transformForTrack()
            try videoTrack.insertTimeRange(
                CMTimeRangeMake(start: .zero, duration: videoAsset.duration),
                of: videoAsset.tracks(withMediaType: .video)[0],
                at: .zero)
        } catch {
            print("Failed to load first track")
            return mixComposition
        }

        let audioTrack = mixComposition.addMutableTrack(
            withMediaType: .audio,
            preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
        do {
            print("Audio Count \(audioAsset.tracks(withMediaType: .audio).count)")
            try audioTrack?.insertTimeRange(
                CMTimeRangeMake(
                    start: .zero,
                    duration: audioAsset.duration),
                of: audioAsset.tracks(withMediaType: .audio)[0],
                at: .zero)
        } catch {
            print("Failed to load Audio track")
        }
        
        return mixComposition
    }

    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        lblTimer.isHidden = true
        log(meetingUid: "overlay-microhpone", log:"Overlay selectMicrophone testing:")
        selectMicrophone( 0 )
        
#if OVERLAY_TEST
        var count = 7
        _ = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { timer in
            count -= 1
            if count == 0 {
                timer.invalidate()
                self.startRecordClicked(UIButton())
            }
        })
        
        var count2 = count + 5
        _ = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { timer in
            count2 -= 1
            if count2 == 0 {
                timer.invalidate()
                self.startRecordClicked(UIButton())
            }
        })
#endif//OVERLAY_TEST
        
#if OVERLAY_UPLOAD_PROGRESS_TEST
        let vc: VideoCompositionViewController = VideoCompositionViewController()
        vc.videoUrl = uploadVideourl
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: false, completion: nil)
#endif//OVERLAY_UPLOAD_PROGRESS_TEST
        
//Omitted         if cameraView.captureSession.isRunning == true {
//            return
//        }
    }
    
    override func viewWillDisappear(_ animated: Bool){
        if(isOnRecording)
        {
            recordEnd()
        }
    }
    
    @IBAction func startRecordClicked(_ sender: UIButton)
    {
        if(!isOnRecording)
        {
            recordStart()
        }
        else
        {
            recordEnd()
        }
    }
    
    func startRecordAction()
    {
        if !cameraView.isVideoRecording {
            cameraView.startVideoRecording()
            //btnRecord.isEnabled = false
            //btnStop.isEnabled = true
            //btnTimer.isEnabled = false
        }
        playerView.play()
    }
    
    func stopRecordAction()
    {
        if cameraView.isVideoRecording {
            cameraView.stopVideoRecording()
            //Omitted btnRecord.isEnabled = true
            //Omitted btnStop.isEnabled = false
            //Omitted btnTimer.isEnabled = true
        }
        playerView.stop()
    }
    
    @IBAction func backDidTap(_ sender: UIButton) {
        if(isOnRecording)
        {
            recordEnd()
        }
        
        self.dismiss(animated: false)
    }
    
    @IBAction func timerAction(_ sender: UIButton) {
        btnTimer.isEnabled = false
        lblTimer.isHidden = false
        if timer != nil {
            timer.invalidate()
        }
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { timer in
            self.count -= 1
            self.lblTimer.text = "\(self.count)"
            if self.count == 0 {
                self.btnTimer.isEnabled = true
                self.lblTimer.isHidden = true
                timer.invalidate()
                self.startRecordClicked(sender)
            }
        })
    }

    @IBAction func audioInputs(_ sender: UIButton) {
        self.containerView.isHidden = false
    }
    
    @IBAction func okDidTap(_ sender: UIButton) {
        UserDefaults.standard.set(self.selectedCount, forKey: self.waitSecKey)
        self.count = selectedCount
        timeSelectPannel.isHidden = true
    }
    
    @IBAction func cancelDidTap(_ sender: UIButton) {
        timeSelectPannel.isHidden = true
    }
    
    
    @IBAction func setTimerDidTap(_ sender: UIButton) {
        timeSelectCtrl .selectRow( self.selectedCount-1, inComponent: 0, animated: true)
        timeSelectPannel.isHidden = false
    }
    
    @IBAction func selectMicDidTap(_ sender: UIButton) {
        let vc: MicrophoneListViewController = MicrophoneListViewController()
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: false, completion: nil)
    }
    
    func mergedVideos(recordUrl:URL, uploadUrl:URL, uploadAudioUrl: URL?) {
        let recordAsset = AVAsset(url: recordUrl)
        var uploadAsset = AVAsset(url: uploadUrl)
        if (uploadAudioUrl != nil) {
            uploadAsset = AVAsset(url: uploadAudioUrl!)
        }
        
        //Omitted activityMonitor.startAnimating()
        let mixComposition = AVMutableComposition()

        guard
            let recordTrack = mixComposition.addMutableTrack(
                withMediaType: .video,
                preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
        else { return }

        do {
            recordTrack.preferredTransform = transformForTrack()
            try recordTrack.insertTimeRange(
                CMTimeRangeMake(start: .zero, duration: recordAsset.duration),
                of: recordAsset.tracks(withMediaType: .video)[0],
                at: .zero)
        } catch {
            print("Failed to load first track")
            return
        }

        let audioTrack = mixComposition.addMutableTrack(
            withMediaType: .audio,
            preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
        do {
            try audioTrack?.insertTimeRange(
                CMTimeRangeMake(
                    start: .zero,
                    duration: recordAsset.duration),
                of: recordAsset.tracks(withMediaType: .audio)[0],
                at: .zero)
        } catch {
            print("Failed to load Audio track")
        }

        let uploadedAudioTrack = mixComposition.addMutableTrack(
            withMediaType: .audio,
            preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
        do {
            let duration = min(recordAsset.duration, uploadAsset.duration)
            try uploadedAudioTrack?.insertTimeRange(
                CMTimeRangeMake(
                    start: .zero,
                    duration: duration),
                of: uploadAsset.tracks(withMediaType: .audio)[0],
                at: .zero)
        } catch {
            print("Failed to load Audio track")
        }
        
        previewMergeResult(merged: mixComposition, recordURL: recordUrl, readerVURL: uploadUrl, readerAURL: uploadAudioUrl!)

//        // Not needed Uploaded video track here right now..
//        let mainInstruction = AVMutableVideoCompositionInstruction()
//        mainInstruction.timeRange = CMTimeRangeMake(
//            start: .zero,
//            duration: recordAsset.duration)
//
//        // only video of recorded track so not added time CMTimeAdd(recordAsset.duration, secondAsset.duration)
//        let firstInstruction = VideoHelper.videoCompositionInstruction(recordTrack, asset: recordAsset)
//        firstInstruction.setOpacity(0.0, at: recordAsset.duration)
//
//        mainInstruction.layerInstructions = [firstInstruction]
//        let mainComposition = AVMutableVideoComposition()
//        mainComposition.instructions = [mainInstruction]
//        mainComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
//        mainComposition.renderSize = VideoSize
//
//        guard
//            let documentDirectory = FileManager.default.urls(
//                for: .cachesDirectory,
//                in: .userDomainMask).first
//        else { return }
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateStyle = .long
//        dateFormatter.timeStyle = .short
//        var date = dateFormatter.string(from: Date())
//        date += UUID().uuidString
//        let url = documentDirectory.appendingPathComponent("mergeVideo-\(date).mov")
//
//        guard let exporter = AVAssetExportSession(
//            asset: mixComposition,
//            presetName: AVAssetExportPresetHighestQuality)
//        else { return }
//        exporter.outputURL = url
//        exporter.outputFileType = AVFileType.mov
//        exporter.shouldOptimizeForNetworkUse = true
//        exporter.videoComposition = mainComposition
//
//        exporter.exportAsynchronously {
//            DispatchQueue.main.async {
//                self.exportDidFinish(exporter)
//            }
//        }
    }
    
    func exportDidFinish(_ session: AVAssetExportSession) {
      // 1
      //Omitted activityMonitor.stopAnimating()

      // 2
      guard
        session.status == AVAssetExportSession.Status.completed,
        let outputURL = session.outputURL
        else { return }
        
        let vc: VideoCompositionViewController = VideoCompositionViewController()
        vc.videoUrl = outputURL
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: false, completion: nil)

//        guard let vc: VideoCompositionViewController = UIStoryboard.mainStoryboard?.instantiateVC() else {
//            return
//        }
//        vc.videoUrl = outputURL
//        self.navigationController?.show(vc, sender: nil)
    }
    
    func previewMergeResult(merged: AVMutableComposition, recordURL: URL, readerVURL: URL, readerAURL: URL) {
      activityMonitor.stopAnimating()
  
        let vc: VideoCompositionViewController = VideoCompositionViewController()
        vc.mergedResult = merged
        vc.recordURL = recordURL
        vc.readerAURL = readerAURL
        vc.readerVURL = readerVURL
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: false, completion: nil)
    }

//Omitted
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "containerViewSegue" {
//            guard let view = segue.destination as? AvailableAudioInputsViewController else {
//                return
//            }
//            view.delegate = self
//        }
//    }
    
    func recordStart(){
        self.count = self.selectedCount
        self.lblTimer.text = "\(self.count)"
        lblTimer.isHidden = false
        if timer != nil {
            timer.invalidate()
        }
        self.btnBack.isUserInteractionEnabled = false
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { timer in
            self.count -= 1
            self.lblTimer.text = "\(self.count)"
            if self.count == 0 {
                self.btnTimer.isEnabled = true
                self.lblTimer.isHidden = true
                timer.invalidate()
                self.startRecordAction()
                self.isOnRecording = true
                self.btnBack.isUserInteractionEnabled = true
            }
        })
    }
    
    func recordEnd(){
        stopRecordAction()
        self.isOnRecording = false
    }
}

extension OverlayViewController: CameraPreviewDelegate {
    func captureSessionDidStartRunning() {
       //
    }

    func captureSessionDidStopRunning() {
        //
    }

    func videoDidBeginRecording() {
        //
    }

    func videoDidEndRecording(with url: URL?, error: Error?) {
        guard let url = url, let uploadurl = self.uploadVideourl else {
            return
        }
        self.mergedVideos(recordUrl: url, uploadUrl: uploadurl, uploadAudioUrl: uploadAudiourl)
    }
}

//Omitted
//extension OverlayViewController: AvailableAudioInputsViewControllerDelegate {
//    func didFinishedAudioInput() {
//        self.containerView.isHidden = true
//    }
//}

////MARK: UIPickerViewDelegate
extension OverlayViewController: UIPickerViewDelegate, UIPickerViewDataSource  {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 10
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(row+1)"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            // This method is triggered whenever the user makes a change to the picker selection.
            // The parameter named row and component represents what was selected.
        self.selectedCount = row+1
    }
}

extension OverlayViewController: PlayerViewDelegate {
    func playerVideo(player: PlayerView, currentTime: Double) {
        //Omitted slider.value = Float(currentTime)
        showViewBy(currentTime: currentTime, view: playerThumbView)
    }

    func playerVideo(player: PlayerView, duration: Double) {
        //Omitted slider.maximumValue = Float(duration)
    }

    func playerVideo(player: PlayerView, statusItemPlayer: AVPlayer.Status, error: Error?) {
        //
    }

    func playerVideo(player: PlayerView, statusItemPlayer: AVPlayerItem.Status, error: Error?) {
        //
        initPlayerThumb(playerView: playerView, movie: movie!) { view in
            self.playerThumbView = view
        }
    }
    
    func playerVideoDidEnd(player: PlayerView) {
        //
        //print("End")
        stopRecordAction()
        isOnRecording = false
    }
}
