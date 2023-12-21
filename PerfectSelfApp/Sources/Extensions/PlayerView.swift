//
//  PlayerView.swift
//  VIdeoAudioOverLay
//
//  Created by Jatin Kathrotiya on 13/09/22.
//

import AVFoundation
import UIKit

protocol PlayerViewDelegate {
    func playerVideo(player: PlayerView, currentTime: Double)
    func playerVideo(player: PlayerView, duration:Double)
    func playerVideo(player: PlayerView, statusItemPlayer: AVPlayer.Status, error: Error?)
    func playerVideo(player: PlayerView, statusItemPlayer: AVPlayerItem.Status, error: Error?)
    func playerVideoDidEnd(player: PlayerView)
}

class PlayerView: UIView {
    private var timeObserverToken: AnyObject?
    private weak var lastPlayerTimeObserve: AVPlayer?
    var delegate: PlayerViewDelegate?

    private var statusContext = true
    private var statusItemContext = true
    private var loadedContext = true
    private var durationContext = true
    private var currentTimeContext = true
    private var rateContext = true
    private var playerItemContext = true
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        let audioSession = AVAudioSession.sharedInstance()

        do {
            try audioSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
        } catch let error as NSError {
            print("audioSession error: \(error.localizedDescription)")
        }
    }
    
    override public class var layerClass: Swift.AnyClass {
        get {
            return AVPlayerLayer.self
        }
    }

    var playerLayer: AVPlayerLayer {
        get {
            return self.layer as! AVPlayerLayer
        }
    }

    public var player: AVPlayer? {
        get {
            return playerLayer.player 
        } set {
            playerLayer.player = newValue
        }
    }

    public var url: URL? {
        didSet {
            guard let url = url else {
                return
            }
            playerItem = AVPlayerItem(url: url)
        }
    }
    
    public var avAsset: AVAsset? {
        didSet {
            guard let avAsset = avAsset else {
                return
            }
            playerItem = AVPlayerItem(asset: avAsset)
        }
    }
    
    public var mainavComposition: AVMutableComposition? {
        didSet {
            guard let mainavComposition = mainavComposition else {
                return
            }
            playerItem = AVPlayerItem(asset: mainavComposition)
        }
    }

    public var playerItem: AVPlayerItem? {
        didSet {
            guard let playerItem = playerItem else {
                return
            }
            player = AVPlayer(playerItem: playerItem)
            playerLayer.player = player
            playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            player?.actionAtItemEnd = .pause
            addObserversPlayer(avPlayer: player!)
            addObserversVideoItem(playerItem: playerItem)
        }
    }

    public var currentTime: Double {
        get {
            guard let player = player else {
                return 0
            }
            return CMTimeGetSeconds(player.currentTime())
        } set {
            guard let timescale = player?.currentItem?.duration.timescale else {
                return
            }
            let newTime = CMTimeMakeWithSeconds(newValue, preferredTimescale: timescale)
            player!.seek(to: newTime,toleranceBefore: CMTime.zero,toleranceAfter: CMTime.zero)
        }
    }

    public func play() {
        rate = 1
    }

    public func pause() {
        rate = 0
    }

    public func stop() {
        currentTime = 0
        pause()
    }

    public var interval = CMTimeMake(value: 1, timescale: 60) {
        didSet {
            if rate != 0 {
                addCurrentTimeObserver()
            }
        }
    }

    public var rate: Float {
        get {
            guard let player = player else {
                return 0
            }
            return player.rate
        } set {
            if newValue == 0 {
                removeCurrentTimeObserver()
            } else if rate == 0 && newValue != 0 {
                addCurrentTimeObserver()
            }

            player?.rate = newValue
        }
    }

   func addObserversPlayer(avPlayer: AVPlayer) {
       avPlayer.addObserver(self, forKeyPath: "status", options: [.new], context: &statusContext)
       avPlayer.addObserver(self, forKeyPath: "rate", options: [.new], context: &rateContext)
       avPlayer.addObserver(self, forKeyPath: "currentItem", options: [.old,.new], context: &playerItemContext)
   }

    func removeObserversPlayer(avPlayer: AVPlayer) {
        avPlayer.removeObserver(self, forKeyPath: "status", context: &statusContext)
        avPlayer.removeObserver(self, forKeyPath: "rate", context: &rateContext)
        avPlayer.removeObserver(self, forKeyPath: "currentItem", context: &playerItemContext)

        if let timeObserverToken = timeObserverToken {
            avPlayer.removeTimeObserver(timeObserverToken)
        }
    }

    func addObserversVideoItem(playerItem: AVPlayerItem) {
        playerItem.addObserver(self, forKeyPath: "loadedTimeRanges", options: [], context: &loadedContext)
        playerItem.addObserver(self, forKeyPath: "duration", options: [], context: &durationContext)
        playerItem.addObserver(self, forKeyPath: "status", options: [], context: &statusItemContext)
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidPlayToEndTime(aNotification:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
    }

    func removeObserversVideoItem(playerItem: AVPlayerItem) {

        playerItem.removeObserver(self, forKeyPath: "loadedTimeRanges", context: &loadedContext)
        playerItem.removeObserver(self, forKeyPath: "duration", context: &durationContext)
        playerItem.removeObserver(self, forKeyPath: "status", context: &statusItemContext)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
    }

    @objc func playerItemDidPlayToEndTime(aNotification: NSNotification) {
        // notification of player to stop
        let _ = aNotification.object as! AVPlayerItem
        currentTime = 0
        delegate?.playerVideoDidEnd(player: self)
        // Finish video
    }

    func removeCurrentTimeObserver() {
        if let timeObserverToken = self.timeObserverToken {
            lastPlayerTimeObserve?.removeTimeObserver(timeObserverToken)
        }
        timeObserverToken = nil
    }

    func addCurrentTimeObserver() {
        removeCurrentTimeObserver()
        lastPlayerTimeObserve = player
        self.timeObserverToken = player?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { [weak self] time-> Void in
            if let self = self {
                self.delegate?.playerVideo(player: self, currentTime: self.currentTime)
            }
        } as AnyObject?
    }

    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {

        if context == &statusContext {
            guard let avPlayer = player else {
                super.observeValue(forKeyPath: keyPath, of: object, change: change , context: context)
                return
            }
           self.delegate?.playerVideo(player: self, statusItemPlayer: avPlayer.status, error: avPlayer.error)
        } else if context == &loadedContext {
            let playerItem = player?.currentItem
            guard let times = playerItem?.loadedTimeRanges else {
                return
            }

            let _ = times.map({ $0.timeRangeValue})
        } else if context == &durationContext {

            if let currentItem = player?.currentItem {
                self.delegate?.playerVideo(player: self, duration: currentItem.duration.seconds)
            }

        } else if context == &statusItemContext {
            // status of item has changed
            if let currentItem = player?.currentItem {

                self.delegate?.playerVideo(player: self, statusItemPlayer: currentItem.status, error: currentItem.error)
            }
        } else if context == &rateContext {
            guard let newRateNumber = (change?[NSKeyValueChangeKey.newKey] as? NSNumber) else {
                return
            }
            let newRate = newRateNumber.floatValue
            if newRate == 0 {
                removeCurrentTimeObserver()
            } else {
                addCurrentTimeObserver()
            }
        } else if context == &playerItemContext {
            guard let oldItem = (change?[NSKeyValueChangeKey.oldKey] as? AVPlayerItem) else{
                return
            }
            removeObserversVideoItem(playerItem: oldItem)
            guard let newItem = (change?[NSKeyValueChangeKey.newKey] as? AVPlayerItem) else {
                return
            }
            addObserversVideoItem(playerItem: newItem)
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change , context: context)
        }
    }
}
