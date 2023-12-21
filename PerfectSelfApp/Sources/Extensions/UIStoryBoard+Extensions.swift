//
//  UIStoryBoard+Extensions.swift
//  VIdeoAudioOverLay
//
//  Created by Jatin Kathrotiya on 22/09/22.
//

import Foundation
import UIKit

extension UIStoryboard {

    public static var mainStoryboard: UIStoryboard? {
        let bundle = Bundle.main
        guard let name = bundle.object(forInfoDictionaryKey: "UIMainStoryboardFile") as? String else {
            return nil
        }
        return UIStoryboard(name: name, bundle: bundle)
    }

    public func instantiateVC<T>() -> T? {
        let storyboardID = String(describing: T.self)
        if let vc = instantiateViewController(withIdentifier: storyboardID) as? T {
            return vc
        } else {
            return nil
        }
    }
}
