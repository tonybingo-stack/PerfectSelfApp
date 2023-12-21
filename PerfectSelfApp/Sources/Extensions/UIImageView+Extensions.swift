//
//  UIImageView+Extensions.swift
//  PerfectSelf
//
//  Created by Kayan Mishra on 3/2/23.
//  Copyright © 2023 Stas Seldin. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView{
  func imageFrom(url:URL){
    DispatchQueue.global().async { [weak self] in
      if let data = try? Data(contentsOf: url){
        if let image = UIImage(data:data){
          DispatchQueue.main.async{
            self?.image = image
          }
        }
      }
    }
  }
}
