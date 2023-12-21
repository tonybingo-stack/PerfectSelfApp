//
//  Global.swift
//  PerfectSelf
//
//  Created by Kayan Mishra on 3/1/23.
//  Copyright © 2023 Stas Seldin. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer
import Photos
import GoogleSignIn

let signalingServerConfig = Config.default
let webAPI = PerfectSelfWebAPI()
let audoAPI = AudioEnhancementAPI()
let backgroundAPI = BackgroundRemovalAPI()
let ACTOR_UTYPE = 3
let READER_UTYPE = 4
let SCRIPT_BUCKET = "perfectself-script-bucket"
var fcmDeviceToken: String = ""
var backgroundView: UIView? = nil
var activityIndicatorView: UIActivityIndicatorView? = nil
var uiViewContoller: UIViewController? = nil
var selectedTape: VideoCard?
var rootTabbar: UITabBarController? = nil
let awsUpload = AWSMultipartUpload()
let GoogleAuthClientID = "669216550945-mgc5slqbok7j5ubp8255loi7hkoe7mj3.apps.googleusercontent.com"
let signInConfig = GIDConfiguration(clientID: GoogleAuthClientID)
let videoWidth = 1280//720
let videoHeight = 720//1280
let VideoSize = CGSize(width: videoHeight, height: videoWidth)
var videoRotateOffset: Int = 0
var mainRotateDegree: Int = 90
var appDatetimeFormat = "MMM dd, yyyy"
var sharingPolicyLink = "https://perfectself.s3.us-east-2.amazonaws.com/script-policy.html"
var policyLink = "https://perfectself.s3.us-east-2.amazonaws.com/privacy.html"
var termsLink = "https://perfectself.s3.us-east-2.amazonaws.com/terms-cond.html"
var actorHomeView: ActorHomeViewController? = nil
var parentFolderId: String = ""
var parentFolderKey: String = ""

var availableTime: [String] = [
    "T09", "T10", "T11",
    "T12", "T13", "T14",
    "T15", "T16", "T17",
    "T18", "T19", "T20",
    "T21", "T22"
]

var availableDuration: [String] = [
    "15", "30", "45", "00"
]

var Filter: [String: Any] = [
    "isAvailableSoon": false,
    "isOnlineNow": true,
    "timeSlotType": 0,
    "isDateSelected": false,
    "fromDate": Date(),
    "toDate": Date(),
    "priceMinVal": 0,
    "priceMaxVal": 100,
    "isMale": false,
    "isFemale": false,
    "isNonBinary": false,
    "isGenderqueer": false,
    "isGenderfluid": false,
    "isTransgender": false,
    "isAgender": false,
    "isBigender": false,
    "isTwoSpirit": false,
    "isAndrogynous": false,
    "isUnknown": false,
    "isAll": false,
    "isCommercialRead": true,
    "isShortRead": false,
    "isExtendedRead": false,
    "isExplicitRead": false
]

enum Gender: Int {
    case Male = 0
    case Female
    case NonBinary
    case Genderqueer
    case Genderfluid
    case Transgender
    case Agender
    case Bigender
    case TwoSpirit
    case Androgynous
    case Unkown
    case Nothing
}

let genderAry = ["Male",  "Female", "NonBinary",  "Transgender",  "Genderqueer"]//["Male",  "Female", "NonBinary",  "Genderqueer", "Genderfluid",  "Transgender",   "Agender",  "Bigender",  "TwoSpirit",  "Androgynous",   "Unkown", ""]
let ageRangeAry = ["", "10-20", "21-30", "31-40", "41-50", "over 50"]

//{{For uploading to AWS.
var audioUrl: URL?
var userName: String?
var userUid: String?
var gRoomUid: String?
//}}For uploading to AWS.

#if RECORDING_TEST
var onAWSUploading = false
#endif//RECORDING_TEST

//var webRTCClient: WebRTCClient?
//var signalClient: SignalingClient?
//var signalingClientStatus: SignalingClientStatus?

//struct Message: Codable {
//    let text: String
//    let timestamp: String
//}
enum MessageType {
    case sent
    case received
}

struct UserInfo: Codable {
    let userName: String
    let userType: Int
    let avatarBucketName: String?
    let avatarKey: String?
    let email: String
    let password: String?
    let firstName: String?
    let lastName: String?
    let dateOfBirth: String?
    let gender:Int?
    let currentAddress: String?
    let permanentAddress: String?
    let city: String?
    let nationality: String?
    let phoneNumber: String?
    let isLogin: Bool
    let token: String?
    let fCMDeviceToken: String?
    let deviceKind: Int
    let createdTime: String
    let updatedTime: String?
    let deletedTime: String?
}

struct ActorProfile: Codable {
    let title: String
    let actorUid: String
    let ageRange: String
    let height: Float
    let weight: Float
    let country: String
    let state: String
    let city: String
    let agency: String
    let reviewCount: Int
    let score: Float
    let vaccinationStatus: Int
}

struct ReaderProfileDetail: Codable {
    let uid: String
    let userName: String
    let avatarBucketName: String
    let avatarKey: String
    let title: String
    let min15Price: Float
    let min30Price: Float
    let hourlyPrice: Float
    let others: Int
    let voiceType: Int
    let about: String
    let skills: String
    let score: Float
    let auditionType: Int
    let isExplicitRead: Bool?
    let introBucketName: String
    let introVideoKey: String
    let bookPassCount: Int
    let allAvailability: [Availability]
    let reviewLists: [Review]
    let sessionCount: Int
}
struct Availability: Codable {
    let readerUid: String
    let isStandBy: Bool
    let repeatFlag: Int
    let date: String
    let fromTime: String
    let toTime: String
    let id: Int
}
struct Review: Codable {
    let actorUid: String
    let readerUid: String
    let roomUid: String
    let actorName: String
    let actorBucketName: String?
    let actorAvatarKey: String?
    let bookStartTime: String
    let bookEndTime: String
    let scriptFile: String
    let readerScore: Int
    let readerReview: String
}
struct ReaderProfileCard: Codable {
    let uid: String
    let userName: String
    let userType: Int
    let email: String
    let firstName: String
    let lastName: String
    let avatarBucketName: String?
    let avatarKey: String?
    let title: String?
    let gender: Int
    let fcmDeviceToken: String?
    let deviceKind: Int
    let isLogin: Bool
    let isSponsored: Bool
    let reviewCount: Int
    let score: Float
    let min15Price: Float?
    let min30Price: Float?
    let hourlyPrice: Float?
    let isStandBy: Bool?
    let date: String?
    var fromTime: String?
    var toTime: String?
}
struct UnreadState: Codable {
    let uid: String
    let unreadCount: Int
}
struct BookingCard: Codable {
    let id: Int
    let roomUid: String
    let actorUid: String
    let readerUid: String
    let actorFCMDeviceToken: String
    let readerFCMDeviceToken: String
    let projectName: String
    let readerName: String
    let actorName: String
    let scriptFile: String?
    let scriptBucket: String?
    let scriptKey: String?
    var bookStartTime: String
    var bookEndTime: String
    let readerReview: String?
    let actorBucketName: String?
    let actorAvatarKey: String?
    let readerBucketName: String?
    let readerAvatarKey: String?
}

struct SoonBooking: Codable {
    let id: Int
    let actorUid: String
    let readerUid: String
    let roomUid: String
    let projectName: String
    let bookStartTime: String
    let bookEndTime: String
    let scriptFile: String
    let scriptBucket: String
    let scriptKey: String
    let isAccept: Bool
    let readerScore: Double
    let readerReview: String
    let readerReviewDate: String
    let isDeleted: Bool
}

struct VideoCard: Codable {
    let actorId: Int
    let actorUid: String
    let readerUid: String?
    let tapeName: String
    let bucketName: String
    let actorTapeKey: String
    let readerTapeKey: String?
    let readerName: String?
    let roomUid: String
    let tapeId: String
    var createdTime: String
    var updatedTime: String
    var deletedTime: String
}

struct TapeCount: Codable {
    let tapeCount: Int
}

struct TimeSlot: Codable {
    var date: String
    var time: [Slot]
    var repeatFlag: Int
    var isStandBy: Bool
}

struct Slot: Codable {
    var id: Int
    var slot: Int
    var duration: Int
    var isDeleted: Bool
}

struct ChatChannel: Codable {
    let id: Int
    let senderUid: String
    let senderName: String
    let receiverUid: String
    let receiverName: String
    let roomUid: String
    var sendTime: String
    let hadRead: Bool
    let message: String
    let senderAvatarBucket: String?
    let senderAvatarKey: String?
    let receiverAvatarBucket: String?
    let receiverAvatarKey: String?
    let senderIsOnline: Bool
    let receiverIsOnline: Bool
    let unreadCount: Int
}

struct PerfMessage: Codable {
    let id: Int
    let senderUid: String
    let receiverUid: String
    let roomUid: String
    var sendTime: String
    let hadRead: Bool
    let message: String
}
struct BackRemoveResult: Codable {
    let data: BackRemoveData
}
struct BackRemoveData: Codable {
    let id: String
    let type: String
    let attributes: BackRemoveAttribute
    let links: BackLinks
}
struct BackRemoveAttribute: Codable {
    let status: String
    let progress: String
    let result_url: String
    let error_code: String
    let error_detail: String
}
struct BackLinks: Codable {
    let `self`: String
}

struct RoomInfo: Codable {
    let roomUid: String
}

//        showAlert(viewController: self, title: "Confirm", message: "Please input") { UIAlertAction in
//            print("Ok button tapped")
//        }
func showAlert(viewController: UIViewController, title: String, message: String, okHandler: @escaping ((UIAlertAction)->Void) )
{
    // Create new Alert
    let dialogMessage = UIAlertController(title: title, message: message, preferredStyle: .alert)
    
    // Create OK button with action handler
    let ok = UIAlertAction(title: "OK", style: .default, handler: okHandler)
    dialogMessage.addAction(ok)
    viewController.present(dialogMessage, animated: true, completion: nil)
}

//        showConfirm(viewController: self, title: "Confirm", message: "PleaseIn") { UIAlertAction in
//            print("Ok button tapped")
//        } cancelHandler: { UIAlertAction in
//            print("Cancel button tapped")
//        }
func showConfirm(viewController: UIViewController
                 , title: String
                 , message: String
                 , okHandler: @escaping((UIAlertAction)->Void)
                 , cancelHandler: @escaping((UIAlertAction)->Void))
{
    // Create new Alert
    let dialogMessage = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let ok = UIAlertAction(title: "OK", style: .default, handler: okHandler)
    let cancel = UIAlertAction(title: "Cancel", style: .default, handler: cancelHandler)

    //Add OK button to a dialog message
    dialogMessage.addAction(ok)
    dialogMessage.addAction(cancel)
    viewController.present(dialogMessage, animated: true, completion: nil)
}

func showIndicator(sender: UIControl?, viewController: UIViewController, color: UIColor=UIColor.black)
{
    if(sender != nil){
        sender!.isEnabled = false
    }
    backgroundView = UIView()
    backgroundView!.backgroundColor = UIColor.black.withAlphaComponent(0.5)
    backgroundView!.frame = viewController.view.bounds
    backgroundView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    viewController.view.addSubview(backgroundView!)
    
    activityIndicatorView = UIActivityIndicatorView(style: .large)
    activityIndicatorView?.color = color
    activityIndicatorView!.center = viewController.view.center
    viewController.view.addSubview(activityIndicatorView!)
    activityIndicatorView!.startAnimating()
}

func hideIndicator(sender: UIControl?)
{
    activityIndicatorView?.stopAnimating()
    activityIndicatorView?.removeFromSuperview()
    backgroundView?.removeFromSuperview()
    
    if(sender != nil){
        sender!.isEnabled = true
    }
}

func isValidEmail(email: String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

    let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    let ret = emailPred.evaluate(with: email)
    return ret
}

func buildSignalingClient() -> SignalingClient {
    // iOS 13 has native websocket support. For iOS 12 or lower we will use 3rd party library.
    let webSocketProvider: WebSocketProvider
    
    if #available(iOS 13.0, *) {
        webSocketProvider = NativeWebSocket(url: signalingServerConfig.signalingServerUrl)
    } else {
        webSocketProvider = StarscreamWebSocket(url: signalingServerConfig.signalingServerUrl)
    }
    
    return SignalingClient(webSocket: webSocketProvider)
}

func getDateString() -> String{
    let now = Date()
    let formatter = DateFormatter()
    formatter.timeZone = TimeZone.current
    formatter.dateFormat = "yyyy-MM-dd"//"yyyy-MM-dd-HHmmss"
    let dateString = formatter.string(from: now)
    return dateString
}

func getTapeIdString() -> String{
    let now = Date()
    let formatter = DateFormatter()
    formatter.timeZone = TimeZone.current
    formatter.dateFormat = "HHmmssS"//"yyyy-MM-dd-HHmmss"
    let dateString = formatter.string(from: now)
    let subfix = UUID().uuidString
    return "\(dateString)-\(subfix)"
}

func getCurrentTime(milisecond: Float64) -> String{
    let seconds = (UInt) (milisecond / 1000) % 60
    let  minutes = (UInt) (((UInt)(milisecond / (1000*60))) % 60)
    let hours   = (UInt) ((UInt)(milisecond / (1000*60*60)))
    let curTimeText: String = String.localizedStringWithFormat("%i:%02i:%02i", hours, minutes, seconds)
    return curTimeText
}

func getCurrentTime(second: Float64) -> String{
    let seconds = (UInt)((Int(second)) % 60)
    let  minutes = (UInt) (((UInt)(second / (60))) % 60)
    let hours   = (UInt) ((UInt)(second / (60*60)))
    let curTimeText: String = String.localizedStringWithFormat("%i:%02i:%02i", hours, minutes, seconds)
    return curTimeText
}

func requestPushAuthorization() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
        if success {
            print("Push notifications allowed")
        } else if let error = error {
            print(error.localizedDescription)
        }
    }
}

func registerForNotifications() {
    UIApplication.shared.registerForRemoteNotifications()
}

func localToUTCEx(dateStr: String?) -> String? {
    guard let dateStr = dateStr, dateStr.count > 0 else{
        return ""
    }
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    dateFormatter.calendar = Calendar.current
    dateFormatter.timeZone = TimeZone.current
    
    if let date = dateFormatter.date(from: dateStr) {
        return dateFormatter.string(from: date.toGlobalTime())
    }
    return nil
}

func localToUTC(dateStr: String?) -> String? {
    guard let dateStr = dateStr, dateStr.count > 0 else{
        return ""
    }
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    dateFormatter.calendar = Calendar.current
    dateFormatter.timeZone = TimeZone.current
    
    if let date = dateFormatter.date(from: dateStr) {
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    
        return dateFormatter.string(from: date)
    }
    return nil
}

func localToUTC(dateStr: String?, dtFormat: String) -> String? {
    guard let dateStr = dateStr, dateStr.count > 0 else{
        return ""
    }
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = dtFormat
    dateFormatter.calendar = Calendar.current
    dateFormatter.timeZone = TimeZone.current
    
    if let date = dateFormatter.date(from: dateStr) {
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = dtFormat
    
        return dateFormatter.string(from: date)
    }
    return nil
}

func utcToLocalEx(dateStr: String?) -> String? {
    guard let dateStr = dateStr, dateStr.count > 0 else{
        return ""
    }
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
    
    if let date = dateFormatter.date(from: dateStr) {
        return dateFormatter.string(from: date.toLocalTime())
    }
    else
    {
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        if let date = dateFormatter.date(from: dateStr) {
            return dateFormatter.string(from: date.toLocalTime())
        }
    }
    return nil
}

func utcToLocal(dateStr: String?) -> String? {
    guard let dateStr = dateStr, dateStr.count > 0 else{
        return ""
    }
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
    
    if let date = dateFormatter.date(from: dateStr) {
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    
        return dateFormatter.string(from: date)
    }
    else
    {
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        if let date = dateFormatter.date(from: dateStr) {
            dateFormatter.timeZone = TimeZone.current
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
            return dateFormatter.string(from: date)
        }
    }
    return nil
}

func utcToLocal(dateStr: String?, dtFormat: String) -> String? {
    guard let dateStr = dateStr, dateStr.count > 0 else{
        return ""
    }
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = dtFormat
    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
    
    if let date = dateFormatter.date(from: dateStr) {
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = dtFormat
    
        return dateFormatter.string(from: date)
    }
    else
    {
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        if let date = dateFormatter.date(from: dateStr) {
            dateFormatter.timeZone = TimeZone.current
            dateFormatter.dateFormat = dtFormat
        
            return dateFormatter.string(from: date)
        }
    }
    return nil
}

func setSpeakerVolume(_ volume: Float) {
    let audioSession = AVAudioSession.sharedInstance()
    do {
        try audioSession.setActive(true)
        try audioSession.setCategory(.playback, mode: .default, options: [])
        try audioSession.setMode(.default)
        
        let volumeView = MPVolumeView()
        if let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider {
            slider.value = volume
        }
    } catch {
        print("Failed to set speaker volume: \(error.localizedDescription)")
    }
}

func degreeToRadian(_ x: CGFloat) -> CGFloat {
    return .pi * x / 180.0
}

func getVideoTransform() -> CGAffineTransform {
    switch UIDevice.current.orientation {
    case .portrait:
        return .identity
    case .portraitUpsideDown:
        return CGAffineTransform(rotationAngle: .pi)
    case .landscapeLeft:
        return CGAffineTransform(rotationAngle: .pi/2)
    case .landscapeRight:
        return CGAffineTransform(rotationAngle: -.pi/2)
    default:
        return .identity
    }
}

func getVideoTransformStatus() -> String {
    switch UIDevice.current.orientation {
    case .portrait:
        return "portrait"
    case .portraitUpsideDown:
        return "portraitUpsideDown"
    case .landscapeLeft:
        return "landscapeLeft"
    case .landscapeRight:
        return "landscapeRight"
    default:
        return "default"
    }
}

func initAVMutableComposition(avMComp: AVMutableComposition, videoURL: URL, audioURL: URL, rotate: Int=0) -> AVMutableCompositionTrack{
    if( avMComp.tracks.count >= 2 ){
        let oldVideoTrack = avMComp.tracks(withMediaType: .video).first
        let oldAudioTrack = avMComp.tracks(withMediaType: .audio).first
        avMComp.removeTrack(oldVideoTrack!)
        avMComp.removeTrack(oldAudioTrack!)
    }
    
    print(avMComp.tracks.count)
    
    let videoTrack = avMComp.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
    let audioTrack = avMComp.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
            
    let videoAsset = AVURLAsset(url: videoURL)
    let audioAsset = AVURLAsset(url: audioURL)
        
    let dur = CMTimeRangeMake(start: CMTime.zero, duration: videoAsset.duration)
    let vTrack = videoAsset.tracks(withMediaType: .video).first!
    videoTrack!.preferredTransform = transformForTrack(rotateOffset: CGFloat(rotate))
    
    do{
        try videoTrack?.insertTimeRange(dur, of: vTrack,  at: CMTime.zero)
        if(audioAsset.tracks(withMediaType: .audio).count > 0){
            try audioTrack?.insertTimeRange(dur, of: audioAsset.tracks(withMediaType: .audio).first!, at: CMTime.zero)
        }
    } catch {
        //handle error
        print(error)
    }
    
    return videoTrack!
}

func saveOnlyAudioFrom(url: URL, completion: @escaping (URL) -> Void) {
    let asset = AVAsset(url: url)
    
    // Check if the asset has both video and audio tracks
    guard asset.tracks(withMediaType: .audio).count > 0 else {
        print("The asset does not have both video and audio tracks.")
        return
    }
    
    // Create a composition with the asset
    let composition = AVMutableComposition()
    
    // Add audio track to the composition
    guard let audioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid) else {
        print("Failed to add audio track to the composition.")
        return
    }

    do {
        try audioTrack.insertTimeRange(CMTimeRangeMake(start: .zero, duration: asset.duration),
                                       of: asset.tracks(withMediaType: .audio)[0],
                                       at: .zero)
    } catch {
        print("Failed to insert audio track into the composition: \(error)")
        return
    }
    
    // Export the composition with video and audio tracks separated
    guard let exportSession = AVAssetExportSession(asset: composition, presetName:  AVAssetExportPresetAppleM4A) else {
        print("Failed to create export session.")
        return
    }
    
//        let fileManager = FileManager.default
//        guard let filePaths = try? fileManager.contentsOfDirectory(at: URL(fileURLWithPath: NSTemporaryDirectory()), includingPropertiesForKeys: nil, options: []) else { return }
//        for filePath in filePaths {
//            try? fileManager.removeItem(at: filePath)
//        }
    
    let outputURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("self-tape.m4a")
    let fileManager = FileManager.default
    try? fileManager.removeItem(at: outputURL)
    
    exportSession.outputURL = outputURL
    exportSession.outputFileType = .m4a
    
    exportSession.exportAsynchronously {
        switch exportSession.status {
        case .completed:
            print("Video and audio tracks separated successfully. Output URL: \(outputURL)")
            // Access the output URL and perform further operations
            completion(outputURL)
        case .failed:
            print("Failed to separate video and audio tracks: \(exportSession.error?.localizedDescription ?? "")")
            
        case .cancelled:
            print("Separating video and audio tracks operation cancelled.")
            
        default:
            break
        }
    }
}

func saveOnlyVideoFrom(url: URL, completion: @escaping (URL) -> Void) {
//        let fileManager = FileManager.default
//        guard let filePaths = try? fileManager.contentsOfDirectory(at: URL(fileURLWithPath: NSTemporaryDirectory()), includingPropertiesForKeys: nil, options: []) else { return }
//        for filePath in filePaths {
//            try? fileManager.removeItem(at: filePath)
//        }
    
    let asset = AVAsset(url: url)
    
    // Check if the asset has both video and audio tracks
    guard asset.tracks(withMediaType: .video).count > 0  else {
        print("The asset does not have both video and audio tracks.")
        return
    }
    
    // Create a composition with the asset
    let composition = AVMutableComposition()
    
    // Add video track to the composition
    guard let videoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid) else {
        print("Failed to add video track to the composition.")
        return
    }

    do {
        try videoTrack.insertTimeRange(CMTimeRangeMake(start: .zero, duration: asset.duration),
                                       of: asset.tracks(withMediaType: .video)[0],
                                       at: .zero)
    } catch {
        print("Failed to insert video track into the composition: \(error)")
        return
    }
    
    // Export the composition with video and audio tracks separated
    guard let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
        print("Failed to create export session.")
        return
    }
    
    let outputURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("self-tape.mp4")
    let fileManager = FileManager.default
    try? fileManager.removeItem(at: outputURL)
    
    exportSession.outputURL = outputURL
    exportSession.outputFileType = .mp4
    exportSession.audioMix = nil
    exportSession.shouldOptimizeForNetworkUse = true
    
    exportSession.exportAsynchronously {
        switch exportSession.status {
        case .completed:
            print("Video and audio tracks separated successfully. Output URL: \(outputURL)")
            completion(outputURL)
            // Access the output URL and perform further operations
        case .failed:
            print("Failed to separate video and audio tracks: \(exportSession.error?.localizedDescription ?? "")")
            
        case .cancelled:
            print("Separating video and audio tracks operation cancelled.")
            
        default:
            break
        }
    }
}

func transformForTrack(rotateOffset: CGFloat=0) -> CGAffineTransform{
    let affineTransform = CGAffineTransform(rotationAngle: degreeToRadian(CGFloat(mainRotateDegree)+rotateOffset))
    return affineTransform
}

func uploadAvatar(prefix: String, avatarUrl: URL?, imgControl: UIImageView, controller: UIViewController){
    guard let avatarUrl = avatarUrl else{
        DispatchQueue.main.async {
            hideIndicator(sender: nil)
            Toast.show(message: "Image Url invalid, Try again later!", controller:  controller)
        }
        return
    }
    
    //Then Upload image
    awsUpload.uploadImage(filePath: avatarUrl, bucketName: "perfectself-avatar-bucket", prefix: prefix) { (error: Error?) -> Void in
        var uploadResult = "Avatar Image upload completed."
        if(error == nil)
        {
            DispatchQueue.main.async {
                // update avatar
                let url = "https://perfectself-avatar-thumb-bucket.s3.us-east-2.amazonaws.com/\(prefix)/\(String(describing: avatarUrl.lastPathComponent))"
                
                var count = 100
                _ = Timer.scheduledTimer(withTimeInterval: TimeInterval(100) / 1000, repeats: true, block: { timer in
                    count-=1
                    if(count == 0){
                        timer.invalidate()
                        return
                    }
                    else{
                        DispatchQueue.global().async {
                            if let data = try? Data(contentsOf: URL(string: url)!){
                                if let image = UIImage(data:data){
                                    timer.invalidate()
                                    DispatchQueue.main.async{
                                        imgControl.image = image
                                        //update user profile
                                        webAPI.updateUserInfo(uid: prefix, userType: -1, bucketName: "perfectself-avatar-thumb-bucket", avatarKey: "\(prefix)/\(avatarUrl.lastPathComponent)", username: "", email: "", password: "", firstName: "", lastName: "", dateOfBirth: "", gender: -1, currentAddress: "", permanentAddress: "", city: "", nationality: "", phoneNumber: "", isLogin: true, fcmDeviceToken: "", deviceKind: -1) { data, response, error in
                                            if error == nil {
                                                // successfully update db
                                                DispatchQueue.main.async {
                                                    if var userInfo = UserDefaults.standard.object(forKey: "USER") as? [String:Any] {
                                                        // Use the saved data
                                                        userInfo["avatarBucketName"] = "perfectself-avatar-thumb-bucket"
                                                        userInfo["avatarKey"] = "\(prefix)/\(avatarUrl.lastPathComponent)"
                                                        UserDefaults.standard.removeObject(forKey: "USER")
                                                        UserDefaults.standard.set(userInfo, forKey: "USER")
                                                        
                                                    } else {
                                                        // No data was saved
                                                        print("No data was saved.")
                                                    }
                                                }
                                                print("update db completed")
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }})
            }
        }
        else
        {
            uploadResult = "Failed to upload avatar image, Try again later!"
        }
        
        DispatchQueue.main.async {
            hideIndicator(sender: nil)
            Toast.show(message: uploadResult, controller: controller)
        }
    }
}

func log(meetingUid: String, log: String){
    DispatchQueue(label: "log").async {
        webAPI.logSend(meetingUid: meetingUid, log: log) { data, response, error in
            if(error == nil){
                let responseJSON = try? JSONSerialization.jsonObject(with: data!, options: [])
                if let responseJSON = responseJSON as? [String: Any] {
                    guard let result = responseJSON["result"] else {
                        return
                    }
                    print("result:", result)
                }
            }
        }
    }
}

func encodeURLParameter(_ string: String) -> String? {
    let allowedCharacters = CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[] ").inverted
    
    if let encodedString = string.addingPercentEncoding(withAllowedCharacters: allowedCharacters) {
        return encodedString
    }
    
    return nil
}

func requestAuthorization(completion: @escaping ()->Void) {
    if PHPhotoLibrary.authorizationStatus() == .notDetermined {
        PHPhotoLibrary.requestAuthorization { (status) in
            DispatchQueue.main.async {
                completion()
            }
        }
    } else if PHPhotoLibrary.authorizationStatus() == .authorized{
        completion()
    }
}

func saveVideoToAlbum(_ outputURL: URL, _ completion: ((Error?) -> Void)?) {
    requestAuthorization {
        PHPhotoLibrary.shared().performChanges({
            let request = PHAssetCreationRequest.forAsset()
            request.addResource(with: .video, fileURL: outputURL, options: nil)
        }) { (result, error) in
            DispatchQueue.main.async {
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    print("Saved successfully")
                }
                completion?(error)
            }
        }
    }
}

func requestCameraAndAudioPermission( _ completion: (() -> Void)?) {
    AVCaptureDevice.requestAccess(for: .video) { granted in
        if granted {
            // Camera permission granted
            AVCaptureDevice.requestAccess(for: .audio) { granted in
//                if granted {
//                    // Audio permission granted
//                } else {
//                    // Audio permission denied
//                    // Handle denial of audio permission
//                }
                completion?()
            }
        } else {
            // Camera permission denied
            // Handle denial of camera permission
            completion?()
        }
    }
}

func exportAudioWithTimeSpan(uiCtrl: UIViewController, composition: AVMutableComposition, audioMixInputParam: AVMutableAudioMixInputParameters, _ completion: @escaping ((URL?) -> Void)){
    //Omitted showIndicator(sender: nil, viewController: uiCtrl, color:UIColor.white)
    guard
        let documentDirectory = FileManager.default.urls(
            for: .cachesDirectory,
            in: .userDomainMask).first
    else { return }
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .long
    dateFormatter.timeStyle = .short
    var date = dateFormatter.string(from: Date())
    date += UUID().uuidString
    let url = documentDirectory.appendingPathComponent("changedaudio-\(date).m4a")
    
    let trackMix = audioMixInputParam
    
    let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetAppleM4A)
    let audioMix = AVMutableAudioMix()
    audioMix.inputParameters = [trackMix]
    exporter!.audioMix = audioMix
    exporter!.outputFileType = .m4a
    exporter!.outputURL = url
    
    exporter!.exportAsynchronously {
        DispatchQueue.main.async {
            //Omitted hideIndicator(sender: nil)
        }
        
        guard exporter!.status == .completed,
              let outputURL = exporter!.outputURL else {
            completion(nil)
            return
        }
        completion(outputURL)
    }
}

func exportVideoWithTimeSpan(uiCtrl: UIViewController, composition: AVMutableComposition, _ completion: @escaping ((URL?) -> Void)){
    //Omitted showIndicator(sender: nil, viewController: uiCtrl, color:UIColor.white)
    guard
        let documentDirectory = FileManager.default.urls(
            for: .cachesDirectory,
            in: .userDomainMask).first
    else { return }
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .long
    dateFormatter.timeStyle = .short
    var date = dateFormatter.string(from: Date())
    date += UUID().uuidString
    let url = documentDirectory.appendingPathComponent("changedaudio-\(date).mov")
    
    let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)
    exporter!.outputURL = url
    exporter!.outputFileType = .mov
    exporter!.shouldOptimizeForNetworkUse = true
    
    exporter!.exportAsynchronously {
        DispatchQueue.main.async {
            //Omitted hideIndicator(sender: nil)
        }
        
        guard exporter!.status == .completed,
              let outputURL = exporter!.outputURL else {
            completion(nil)
            return
        }
        completion(outputURL)
    }
}

func showViewBy(currentTime:Double, view: UIImageView?){
    DispatchQueue.main.async {
        if(currentTime > 0){view?.isHidden = true}
        else {view?.isHidden = false}
    }
}

func initPlayerThumb(playerView: PlayerView, movie: AVMutableComposition, completeHandler:@escaping(UIImageView)->Void){
    let imageGenerator = AVAssetImageGenerator(asset: movie)
    let screenshotTime = CMTime(seconds: 1, preferredTimescale: 30)
    if let imageRef = try? imageGenerator.copyCGImage(at: screenshotTime, actualTime: nil) {
        DispatchQueue.main.async {
            let img = UIImage(cgImage: imageRef)
            let thumbView = UIImageView(image: img)
            thumbView.transform = CGAffineTransformMakeRotation(degreeToRadian(CGFloat(mainRotateDegree)))
            playerView.addSubview(thumbView)
            thumbView.frame = playerView.frame
            thumbView.layer.contentsGravity = CALayerContentsGravity.resizeAspectFill
            completeHandler(thumbView)
        }
    }    
}

func initPlayerThumbEx(playerView: PlayerView, url: URL?, thumbImgView: UIImageView? = nil) -> UIImageView?{
    var retView: UIImageView? = nil
    if(url != nil){
        if(thumbImgView == nil){
            let thumbView = UIImageView()
            thumbView.imageFrom(url: url!)
            thumbView.transform = CGAffineTransformMakeRotation(degreeToRadian(CGFloat(mainRotateDegree)))
            thumbView.layer.contentsGravity = CALayerContentsGravity.resizeAspectFill
            playerView.addSubview(thumbView)
            thumbView.frame = playerView.frame
            retView = thumbView
        }
        else{
            thumbImgView!.imageFrom(url: url!)
            thumbImgView!.transform = CGAffineTransformMakeRotation(degreeToRadian(CGFloat(mainRotateDegree)))
            thumbImgView!.layer.contentsGravity = CALayerContentsGravity.resizeAspectFill
            retView = thumbImgView!
        }
    }
    return retView
}

func getJobIdForRemovalAudioNoise(uiCtrl:UIViewController, audioURL: URL, completeHandler:@escaping(String)->Void){
    audoAPI.getFileId(filePath: audioURL) { data, response, error in
        guard let data = data, error == nil else {
            DispatchQueue.main.async {
                Toast.show(message: "Audio Enhancement failed. Unable to upload file.", controller: uiCtrl)
            }
            completeHandler("")
            return
        }
        do {
            struct FileId : Codable {
                let fileId: String
            }
            //print("Raw response data: \(String(describing: dataString))")
            let respItem = try JSONDecoder().decode(FileId.self, from: data)
            //print(respItem.fileId)
            audoAPI.removeNoise(fileId: respItem.fileId) { data, response, error in
                guard let data = data, error == nil else {
                    DispatchQueue.main.async {
                        Toast.show(message: "Audio Enhancement failed. Unable to process uploaded file.", controller: uiCtrl)
                    }
                    completeHandler("")
                    return
                }
                do {
                    struct JobId : Codable {
                        let jobId: String
                    }
                    
                    let respItem = try JSONDecoder().decode(JobId.self, from: data)
                    //print(respItem.jobId)
                    DispatchQueue.main.async {
                        //self.jobId = respItem.jobId
                    }
                    completeHandler(respItem.jobId)
                } catch {
                    DispatchQueue.main.async {
                        Toast.show(message: "Audio Enhancement failed. Unable to get job id.", controller: uiCtrl)
                    }
                    completeHandler("")
                }
            }
            
        } catch {
            print(error)
            DispatchQueue.main.async {
                Toast.show(message: "Audio Enhancement failed. Unable to get file id.", controller: uiCtrl)
            }
            completeHandler("")
        }
    }
}

func downloadClearAudio(uiCtrl: UIViewController, jobId: String, completeHandler: @escaping(Error?, URL?)->Void){
    audoAPI.getJobStatus(jobId: jobId) { data, response, error in
        guard let data = data, error == nil else {
            completeHandler(error, nil)
            return
        }
        do {
            struct JobStatus: Codable {
                let state: String
            }
            let respItem = try JSONDecoder().decode(JobStatus.self, from: data)
            if respItem.state == "succeeded" {
                struct JobStatusSucceed: Codable {
                    let state: String
                    let downloadPath: String
                }
                let res = try JSONDecoder().decode(JobStatusSucceed.self, from: data)
                audoAPI.getResultFile(downloadPath: res.downloadPath) { (tempLocalUrl, response, error) in
                    if let tempLocalUrl = tempLocalUrl, error == nil {
                        // Success
                        if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                            DispatchQueue.main.async {
                                Toast.show(message: "Audio Enhancement completed", controller: uiCtrl)
                            }
                            print("Successfully downloaded. Status code: \(statusCode)")
                            let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
                            let saveFilePath = URL(fileURLWithPath: "\(documentsPath)/tmpAudio-\(UUID().uuidString).mp3")
                            do {
                                try FileManager.default.copyItem(at: tempLocalUrl, to: saveFilePath)
                            } catch{
                                DispatchQueue.main.async {
                                    Toast.show(message: "Audio Enhancement failed while copying file to save.", controller: uiCtrl)
                                }
                            }
                            completeHandler(nil, saveFilePath)
                        }
                    } else {
                        completeHandler(error, nil)
                    }
                }
            } else if respItem.state == "failed" {
            }
        } catch {
        }
    }
}

func getProjectName(tape: VideoCard) -> String{
    return (tape.readerUid != nil ? "Read with \(tape.readerName!)" : "\(tape.tapeName)")
}

func getS3KeyName(_ fileName: String) -> String {
    var s3Key = fileName
    s3Key = s3Key.replacingOccurrences(of: "+",  with: "%2B")
    s3Key = s3Key.replacingOccurrences(of: "!",  with: "%21")
    s3Key = s3Key.replacingOccurrences(of: "'",  with: "%27")
    s3Key = s3Key.replacingOccurrences(of: "(",  with: "%28")
    s3Key = s3Key.replacingOccurrences(of: ")",  with: "%29")
    s3Key = s3Key.replacingOccurrences(of: "&",  with: "%26")
    s3Key = s3Key.replacingOccurrences(of: "$",  with: "%24")
    s3Key = s3Key.replacingOccurrences(of: "@",  with: "%40")
    s3Key = s3Key.replacingOccurrences(of: "=",  with: "%3D")
    s3Key = s3Key.replacingOccurrences(of: ";",  with: "%3B")
    s3Key = s3Key.replacingOccurrences(of: ":",  with: "%3A")
    s3Key = s3Key.replacingOccurrences(of: ",",  with: "%2C")
    s3Key = s3Key.replacingOccurrences(of: "?",  with: "%3F")
    s3Key = s3Key.replacingOccurrences(of: " ",  with: "+")
    return s3Key
}

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let documentsDirectory = paths[0]
    //let documentsDirectory = URL(string: NSTemporaryDirectory())
    return documentsDirectory
}

func selectMicrophone(_ index: Int){
    var audioInputs: [AVAudioSessionPortDescription] {
        AVAudioSession.sharedInstance().availableInputs ?? []
    }
    
    log(meetingUid: "overlay-microhpone", log:"mic count: \(audioInputs.count)")
    if(audioInputs.count > 0 && audioInputs.count > index){
        let selectedMicroPhone = audioInputs[index]
        do {
            try AVAudioSession.sharedInstance().setPreferredInput(selectedMicroPhone)
            try AVAudioSession.sharedInstance().setActive(true)
            log(meetingUid: "overlay-microhpone", log:"Overlay mic testing: [0] \(selectedMicroPhone.portName) - result: true")
        } catch  {
            print("Error messing with audio session: \(error)")
            log(meetingUid: "overlay-microhpone", log:"Overlay mic testing: [0] \(selectedMicroPhone.portName) - result: false")
        }
    }
}

func replaceOrgWithResult(org: URL, result: URL){
    do {
        try FileManager.default.removeItem(at: org)
        print("File deleted successfully")
    } catch {
        print("Error deleting file: \(error.localizedDescription)")
    }
    do {
        try FileManager.default.copyItem(at: result, to: org)
    } catch (let writeError) {
        print("Error creating a file \(org) : \(writeError)")
    }
}

func time2slotNo(_ timeStr: String) -> Int{
    var slot = 0
    switch timeStr {
    case "09":
        slot = 1
    case "10":
        slot = 2
    case "11":
        slot = 3
    case "12":
        slot = 4
    case "13":
        slot = 5
    case "14":
        slot = 6
    case "15":
        slot = 7
    case "16":
        slot = 8
    case "17":
        slot = 9
    case "18":
        slot = 10
    case "19":
        slot = 11
    case "20":
        slot = 12
    case "21":
        slot = 13
    case "22":
        slot = 14
    default:
        slot = -1
    }
    
    return slot
}

func getStringWithLen(_ str: String, _ len: Int) -> String{
    guard str.count > len else{
        return str
    }
    
    let start = str.index(str.startIndex, offsetBy: 0)
    let end = str.index(str.startIndex, offsetBy: len)
    let range = start..<end
    let subStr = str[range]
    
    return String(subStr)
}

func exportMergedVideo(avUrl: URL, aaUrl: URL, rvUrl: URL, raUrl:URL, vc: UIViewController, completeHandler: @escaping( URL? )->Void){
    DispatchQueue.main.async {
        showIndicator(sender: nil, viewController: vc, color:UIColor.white)
    }
    
    let actorVAsset = AVURLAsset(url: avUrl)
    let actorAAsset = AVURLAsset(url: aaUrl)
    let readerAAsset = AVURLAsset(url: raUrl)
//        do
//        {
    let mixComposition = AVMutableComposition()
    guard
        let recordTrack = mixComposition.addMutableTrack(
            withMediaType: .video,
            preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
    else {
        DispatchQueue.main.async {
            hideIndicator(sender:  nil)
        }
        return
    }
    
    do {
        try recordTrack.insertTimeRange(
            CMTimeRangeMake(start: .zero, duration: actorVAsset.duration),
            of: actorVAsset.tracks(withMediaType: .video).first!,
            at: .zero)
        recordTrack.preferredTransform = transformForTrack(rotateOffset: CGFloat(0))
    } catch {
        DispatchQueue.main.async {
            hideIndicator(sender:  nil)
        }
        return
    }
    
    let audioTrack = mixComposition.addMutableTrack(
        withMediaType: .audio,
        preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
    do {
        try audioTrack?.insertTimeRange(
            CMTimeRangeMake(
                start: .zero,
                duration: actorVAsset.duration),
            of: actorAAsset.tracks(withMediaType: .audio).first!,
            at: .zero)
    } catch {
        print("Failed to load Audio track")
    }
    
    let uploadedAudioTrack = mixComposition.addMutableTrack(
        withMediaType: .audio,
        preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
    do {
        let duration = min(actorAAsset.duration, readerAAsset.duration)
        try uploadedAudioTrack?.insertTimeRange(
            CMTimeRangeMake(
                start: .zero,
                duration: duration),
            of: readerAAsset.tracks(withMediaType: .audio).first!,
            at: .zero)
    } catch {
        print("Failed to load Audio track")
    }
    
    // Not needed Uploaded video track here right now..
    let mainInstruction = AVMutableVideoCompositionInstruction()
    mainInstruction.timeRange = CMTimeRangeMake(
        start: .zero,
        duration: actorVAsset.duration)
    
    // only video of recorded track so not added time CMTimeAdd(recordAsset.duration, secondAsset.duration)
    let firstInstruction = VideoHelper.videoCompositionInstruction(recordTrack, asset: actorVAsset)
    firstInstruction.setOpacity(0.0, at: actorVAsset.duration)

    mainInstruction.layerInstructions = [firstInstruction]
    let mainComposition = AVMutableVideoComposition()
    mainComposition.instructions = [mainInstruction]
    mainComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
    mainComposition.renderSize = VideoSize
    
    guard
        let documentDirectory = FileManager.default.urls(
            for: .cachesDirectory,
            in: .userDomainMask).first
    else { return }
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .long
    dateFormatter.timeStyle = .short
    var date = dateFormatter.string(from: Date())
    date += UUID().uuidString
    let url = documentDirectory.appendingPathComponent("mergeVideo-\(date).mov")
    
    guard let exporter = AVAssetExportSession(
        asset: mixComposition,
        presetName: AVAssetExportPresetPassthrough)
    else { return }
    exporter.outputURL = url
    exporter.outputFileType = AVFileType.mov
    exporter.shouldOptimizeForNetworkUse = true
    exporter.videoComposition = mainComposition
    
    exporter.exportAsynchronously {
        DispatchQueue.main.async {
            hideIndicator(sender:  nil)
            
            guard  exporter.status == AVAssetExportSession.Status.completed, let outputURL = exporter.outputURL else {
                completeHandler(nil)
                return
            }
            completeHandler(outputURL)
        }
    }
//        }
//        catch
//        {
//            print("Exception when compiling movie");
//        }
}

func checkMP3(audioFile: inout URL){
    let audioAsset = AVAsset(url: audioFile)
    if audioAsset.tracks(withMediaType: .audio).count <= 0{
        let audioMP3Url = URL(string: audioFile.absoluteString.replacingOccurrences(of: ".m4a", with: ".mp3"))
        
        do {
            try FileManager.default.moveItem(at: audioFile, to: audioMP3Url!)
            audioFile = audioMP3Url!
        } catch (let writeError) {
            print("Error renameing a file : \(writeError)")
        }
    }
}

public enum RoundingPrecision {
    case ones
    case tenths
    case hundredths
}

// Round to the specific decimal place
public func preciseRound(
    _ value: Float,
    precision: RoundingPrecision = .ones) -> Float
{
    switch precision {
    case .ones:
        return round(value)
    case .tenths:
        return round(value * 10) / 10.0
    case .hundredths:
        return round(value * 100) / 100.0
    }
}

