//
//  CameraPreviewView.swift
//  VIdeoAudioOverLay
//
//  Created by Jatin Kathrotiya on 06/09/22.
//

import UIKit
import AVFoundation

protocol CameraPreviewDelegate {
    func captureSessionDidStartRunning()
    func captureSessionDidStopRunning()
    func videoDidBeginRecording()
    func videoDidEndRecording(with url: URL?, error: Error?)
}

class CameraPreviewView: UIView {
    var captureSession: AVCaptureSession!
    var delegate: CameraPreviewDelegate?
    var previewLayer : AVCaptureVideoPreviewLayer {
        return self.layer as! AVCaptureVideoPreviewLayer
    }

    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }

    var frontCamera: AVCaptureDevice? {
        return AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
    }

    fileprivate var movieFileOutput              : AVCaptureMovieFileOutput?

    public var videoCodecType: AVVideoCodecType? = nil

    fileprivate var sessionRunning = false

    fileprivate let sessionQueue = DispatchQueue(label: "session queue", attributes: [])

    public var outputFolder: String = NSTemporaryDirectory()

    private(set) public var isVideoRecording = false

    fileprivate var backgroundRecordingID        : UIBackgroundTaskIdentifier? = nil

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonSetup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonSetup()
    }

    /// Called when Notification Center registers session starts running

    @objc private func captureSessionDidStartRunning() {
        sessionRunning = true
        DispatchQueue.main.async {
            self.delegate?.captureSessionDidStartRunning()
        }
    }

    /// Called when Notification Center registers session stops running

    @objc private func captureSessionDidStopRunning() {
        sessionRunning = false
        DispatchQueue.main.async {
            self.delegate?.captureSessionDidStopRunning()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func commonSetup() {
        self.setupAndStartCaptureSession()
        self.registerObserver()
    }

    func registerObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(captureSessionDidStartRunning), name: .AVCaptureSessionDidStartRunning, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(captureSessionDidStopRunning),  name: .AVCaptureSessionDidStopRunning,  object: nil)
    }

    func setupAndStartCaptureSession() {
        DispatchQueue.global(qos: .userInteractive).async {
            self.captureSession = AVCaptureSession()
            self.captureSession.beginConfiguration()
            self.captureSession.automaticallyConfiguresCaptureDeviceForWideColor = true
            self.setupInputs()
            self.setupPreviewLayer()
            self.configureVideoOutput()
            
            if( self.captureSession.canSetSessionPreset(AVCaptureSession.Preset.hd1280x720) )
            {
                self.captureSession.sessionPreset = AVCaptureSession.Preset.hd1280x720
            }
            self.captureSession.commitConfiguration()
            self.captureSession.startRunning()
        }
    }

    func setupInputs() {
        self.addVideoInput()
        self.addAudioInput()
    }

    func addVideoInput() {
        guard let frontCamera = frontCamera else {
            return
        }
        guard let frontInput = try? AVCaptureDeviceInput(device: frontCamera) else {
            fatalError("")
        }

        if !captureSession.canAddInput(frontInput) {
            fatalError("")
        }
        captureSession.addInput(frontInput)
    }

    func addAudioInput() {
        captureSession.usesApplicationAudioSession = true
        captureSession.automaticallyConfiguresApplicationAudioSession = false

//{{
        guard let audioDevice = AVCaptureDevice.default(for: AVMediaType.audio) else {
            return
        }
//==
//        let session = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInMicrophone],
//                                                       mediaType: .audio,
//                                                       position: .unspecified)
//
//        guard let microphone = session.devices.first else {
//            print("Microphone not available")
//            return
//        }
//}}
        
        guard let audioDeviceInput = try? AVCaptureDeviceInput(device: audioDevice) else {
            fatalError("")
        }
        
        if !captureSession.canAddInput(audioDeviceInput) {
            fatalError("")
        }
        
        captureSession.addInput(audioDeviceInput)
    }

    func setupPreviewLayer() {
        DispatchQueue.main.async {
            self.previewLayer.session = self.captureSession
            self.previewLayer.videoGravity = .resizeAspectFill
            self.previewLayer.masksToBounds = true
        }
    }

    fileprivate func configureVideoOutput() {
        let movieFileOutput = AVCaptureMovieFileOutput()
        if self.captureSession.canAddOutput(movieFileOutput) {
            self.captureSession.addOutput(movieFileOutput)
            if let connection = movieFileOutput.connection(with: AVMediaType.video) {
                if connection.isVideoStabilizationSupported {
                    connection.preferredVideoStabilizationMode = .auto
                }

                if #available(iOS 11.0, *) {
                    if let videoCodecType = videoCodecType {
                        if movieFileOutput.availableVideoCodecTypes.contains(videoCodecType) == true {
                            // Use the H.264 codec to encode the video.
                            movieFileOutput.setOutputSettings([AVVideoCodecKey: videoCodecType], for: connection)
                        }
                    }
                }
            }
            self.movieFileOutput = movieFileOutput
        }
    }

    public func startVideoRecording() {
        guard captureSession.isRunning == true else {
            print("[SwiftyCam]: Cannot start video recoding. Capture session is not running")
            return
        }
        
        guard let movieFileOutput = self.movieFileOutput else {
            return
        }

        //Must be fetched before on main thread
        sessionQueue.async { [unowned self] in
            if !movieFileOutput.isRecording {
                if UIDevice.current.isMultitaskingSupported {
                    self.backgroundRecordingID = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
                }
                // Update the orientation on the movie file output video connection before starting recording.
                let movieFileOutputConnection = self.movieFileOutput?.connection(with: AVMediaType.video)

                movieFileOutputConnection?.videoOrientation = .portrait

                // Start recording to a temporary file.
                let outputFileName = UUID().uuidString
                let outputFilePath = (self.outputFolder as NSString).appendingPathComponent((outputFileName as NSString).appendingPathExtension("mov")!)
                
#if !targetEnvironment(simulator)
                movieFileOutput.startRecording(to: URL(fileURLWithPath: outputFilePath), recordingDelegate: self)
#endif
                
                self.isVideoRecording = true
                DispatchQueue.main.async {[self] in
                    //Omitted setInputGain(gain: 1.0)
                    self.delegate?.videoDidBeginRecording()
                }
            } else {
                movieFileOutput.stopRecording()
            }
        }
    }

    public func stopVideoRecording() {
        if self.isVideoRecording == true {
            self.isVideoRecording = false
            movieFileOutput!.stopRecording()
        }
    }
    
    func setInputGain(gain: Float){
        let audioSession = AVAudioSession.sharedInstance()
        if audioSession.isInputGainSettable{
            do{
                try audioSession.setInputGain(gain)
            }catch{}
        }
        else{
            print("Can't set input gain")
        }
    }
}

extension CameraPreviewView: AVCaptureFileOutputRecordingDelegate {
    public func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let currentBackgroundRecordingID = backgroundRecordingID {
            backgroundRecordingID = UIBackgroundTaskIdentifier.invalid

            if currentBackgroundRecordingID != UIBackgroundTaskIdentifier.invalid {
                UIApplication.shared.endBackgroundTask(currentBackgroundRecordingID)
            }
        }

        if let currentError = error {
            print("[SwiftyCam]: Movie file finishing error: \(currentError)")
            DispatchQueue.main.async {
                self.delegate?.videoDidEndRecording(with: nil, error: currentError)
            }
        } else {
            //Call delegate function with the URL of the outputfile
            DispatchQueue.main.async {
                self.delegate?.videoDidEndRecording(with: outputFileURL, error: nil)
            }
        }
    }

}
