//
//  VideoHelper.swift
//  VIdeoAudioOverLay
//
//  Created by Jatin Kathrotiya on 15/09/22.
//

import AVFoundation
import UIKit
import Foundation

class VideoHelper {

    static func orientationFromTransform(
      _ transform: CGAffineTransform
    ) -> (orientation: UIImage.Orientation, isPortrait: Bool) {
      var assetOrientation = UIImage.Orientation.up
      var isPortrait = false
      let tfA = transform.a
      let tfB = transform.b
      let tfC = transform.c
      let tfD = transform.d

      if tfA == 0 && tfB == 1.0 && tfC == -1.0 && tfD == 0 {
        assetOrientation = .right
        isPortrait = true
      } else if tfA == 0 && tfB == -1.0 && tfC == 1.0 && tfD == 0 {
        assetOrientation = .left
        isPortrait = true
      } else if tfA == 1.0 && tfB == 0 && tfC == 0 && tfD == 1.0 {
        assetOrientation = .up
      } else if tfA == -1.0 && tfB == 0 && tfC == 0 && tfD == -1.0 {
        assetOrientation = .down
      }
      return (assetOrientation, isPortrait)
    }


    static func videoCompositionInstruction(
      _ track: AVCompositionTrack,
      asset: AVAsset
    ) -> AVMutableVideoCompositionLayerInstruction {
      // 1
      let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)

      // 2
      let assetTrack = asset.tracks(withMediaType: AVMediaType.video)[0]

      // 3
      let transform = assetTrack.preferredTransform
      let assetInfo = orientationFromTransform(transform)

      let naturalSize = VideoSize

      var scaleToFitRatio = naturalSize.width / assetTrack.naturalSize.width

      if assetInfo.isPortrait {
        // 4
          scaleToFitRatio = naturalSize.width / assetTrack.naturalSize.height
        let scaleFactor = CGAffineTransform(
          scaleX: scaleToFitRatio,
          y: scaleToFitRatio)
        instruction.setTransform(
          assetTrack.preferredTransform.concatenating(scaleFactor),
          at: .zero)
      } else {
        // 5
        let scaleFactor = CGAffineTransform(
          scaleX: scaleToFitRatio,
          y: scaleToFitRatio)
        var concat = assetTrack.preferredTransform.concatenating(scaleFactor)
          .concatenating(CGAffineTransform(
            translationX: 0,
            y: naturalSize.width / 2))
        if assetInfo.orientation == .down {
          let fixUpsideDown = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
          let yFix = assetTrack.naturalSize.height + naturalSize.height
          let centerFix = CGAffineTransform(
            translationX: assetTrack.naturalSize.width,
            y: yFix)
          concat = fixUpsideDown.concatenating(centerFix).concatenating(scaleFactor)
        }
        instruction.setTransform(concat, at: .zero)
      }

      return instruction
    }
}

