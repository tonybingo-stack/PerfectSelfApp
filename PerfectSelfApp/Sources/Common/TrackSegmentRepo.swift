//
//  TrackSegment.swift
//  PerfectSelf
//
//  Created by user237184 on 6/19/23.
//  Copyright © 2023 Stas Seldin. All rights reserved.
//

import Foundation
import AVFoundation

class TrackSegment {
    var trackRange: CMTimeRange
    var assetRange: CMTimeRange?
    
    init(trackRange: CMTimeRange, assetRange: CMTimeRange?) {
        self.trackRange = trackRange
        self.assetRange = assetRange
    }
    
    func copy(with zone: NSZone? = nil) -> TrackSegment {
        let copy = TrackSegment(trackRange: trackRange, assetRange: assetRange)
        return copy
    }
}

class TrackSegmentRepo {
    var segments = [TrackSegment]()
    
    init(range: CMTimeRange) {
        segments.append(TrackSegment(trackRange: range, assetRange: range))
    }
    
    deinit{
        segments.removeAll()
    }
    
    func addEmptySegment(range: CMTimeRange){
        var atIndex: Int = -1
        for index in segments.indices {
            
            if(CMTimeCompare(segments[index].trackRange.start, range.start) == 0){
                atIndex = index + 1
                segments.insert(TrackSegment(trackRange: range, assetRange: nil), at: index)
                break
            }
            else if(segments[index].trackRange.containsTime(range.start)){
                if(segments[index].assetRange == nil){
                    segments[index].trackRange.duration = CMTimeAdd(segments[index].trackRange.duration, range.duration)
                    atIndex = index + 1
                }
                else{
                    let hotTrackTimeRange = segments[index].trackRange
                    let hotAssetTimeRange = segments[index].assetRange
                    let leftDur = CMTimeSubtract(range.start, segments[index].trackRange.start)
                    segments[index].trackRange.duration = leftDur
                    segments[index].assetRange!.duration = leftDur
                    
                    segments.insert(TrackSegment(trackRange: CMTimeRange(start: range.start, end: hotTrackTimeRange.end)
                                                 , assetRange: CMTimeRange(start: CMTimeAdd(hotAssetTimeRange!.start, leftDur), end: hotAssetTimeRange!.end))
                                    , at: index+1)
                    
                    segments.insert(TrackSegment(trackRange: range, assetRange: nil), at: index+1)
                    atIndex = index + 2
                }
                break
            }
        }
        
        if(atIndex >= 0){
            for i in (atIndex..<segments.count) {
                segments[i].trackRange.start = CMTimeAdd(segments[i].trackRange.start, range.duration)
            }
        }
    }
    
    func deleteEmptySegment(range: CMTimeRange){
        for i in (0..<segments.count).reversed() {
            if((CMTimeCompare(range.start, segments[i].trackRange.start) <= 0
                   && CMTimeCompare(range.end, segments[i].trackRange.end) >= 0)){
                segments.remove(at: i)
            }
        }
        
        for i in (0..<segments.count) {
            if(CMTimeCompare(range.start, segments[i].trackRange.start) > 0
                        && segments[i].trackRange.containsTime( range.start )){
                let leftDur = CMTimeSubtract(range.start, segments[i].trackRange.start)
                segments[i].trackRange.duration = leftDur
                if(segments[i].assetRange != nil){
                    segments[i].assetRange!.duration = leftDur
                }
                break
            }
        }
        
        for i in (0..<segments.count) {
            if(CMTimeCompare(range.end, segments[i].trackRange.end) < 0
                            && segments[i].trackRange.containsTime( range.end )){
                let rightDur = CMTimeSubtract(segments[i].trackRange.end, range.end)
                segments[i].trackRange.start = range.end
                segments[i].trackRange.duration = rightDur
                if(segments[i].assetRange != nil){
                    segments[i].assetRange!.start = CMTimeSubtract(segments[i].assetRange!.end, rightDur)
                }
                break
            }
        }
        
        for i in (0..<segments.count) {
            if(segments[i].trackRange.start >= range.end){
                segments[i].trackRange.start = CMTimeSubtract(segments[i].trackRange.start, range.duration)
            }
        }
    }
    
    func backupSegments() -> [TrackSegment]{
        let backup = segments.map { $0.copy() }
        return backup
    }
    
    func restoreSegments(backup: [TrackSegment]){
        segments.removeAll()
        for i in (0..<backup.count) {
            segments.append(backup[i])
        }
    }
    
    func dumpTrackSegments(){
#if DEBUG
        print("")
        for i in (0..<segments.count) {
            let trackRange = segments[i].trackRange
            let assetRange = segments[i].assetRange
            if(assetRange == nil){
                let trackRange = segments[i].trackRange
                let trackEnd = trackRange.start.seconds + trackRange.duration.seconds
                print("{\(trackRange.start.seconds):\(trackRange.start.timescale) \(trackEnd):\(trackRange.duration.timescale)} -> {nil}")
            }
            else{
                let trackEnd = trackRange.start.seconds + trackRange.duration.seconds
                let assetEnd = assetRange!.start.seconds + assetRange!.duration.seconds
                print("{\(trackRange.start.seconds):\(trackRange.start.timescale) \(trackEnd):\(trackRange.duration.timescale)} -> {\(assetRange!.start.seconds):\(assetRange!.start.timescale) \(assetEnd):\(assetRange!.duration.timescale)}")
            }
        }
#endif
    }
    
    func buildTrack(compositionVTrack: inout AVMutableCompositionTrack, vURL: URL, compositionATrack: inout AVMutableCompositionTrack, aURL: URL){
        compositionATrack.removeTimeRange(CMTimeRange(start: .zero, duration:  CMTimeMakeWithSeconds( 6*60*60, preferredTimescale: 1 )))
        compositionVTrack.removeTimeRange(CMTimeRange(start: .zero, duration:  CMTimeMakeWithSeconds( 6*60*60, preferredTimescale: 1 )))
        let vAsset = AVURLAsset(url: vURL)
        let aAsset = AVURLAsset(url: aURL)
        
        dumpTrackSegments()
        
        for i in (0..<segments.count) {
            if(segments[i].assetRange != nil){
                do{
                    try compositionATrack.insertTimeRange(segments[i].assetRange!, of: aAsset.tracks(withMediaType: .audio).first!, at: segments[i].trackRange.start)
                    
                    var vRange:CMTimeRange = segments[i].assetRange!
                    if(CMTimeCompare(vRange.duration, vAsset.duration) > 0) { vRange.duration = vAsset.duration }
                    try compositionVTrack.insertTimeRange(segments[i].assetRange!, of: vAsset.tracks(withMediaType: .video).first!, at: segments[i].trackRange.start)
                }catch {
                    print(error)
                }
            }
            else{
                compositionATrack.insertEmptyTimeRange(segments[i].trackRange)
                compositionVTrack.insertEmptyTimeRange(segments[i].trackRange)
            }
        }
    }
    
    func getMixInputParams(compositionTrack: AVMutableCompositionTrack) -> AVMutableAudioMixInputParameters{
        let trackMix = AVMutableAudioMixInputParameters(track: compositionTrack)
        
        for i in (0..<segments.count) {
            if(segments[i].assetRange != nil){
                trackMix.setVolume(1, at: segments[i].trackRange.start)
            }
            else
            {
                trackMix.setVolume(0, at: segments[i].trackRange.start)
            }
        }
        return trackMix
    }
    
    func clear(){
        segments.removeAll()
    }
}
