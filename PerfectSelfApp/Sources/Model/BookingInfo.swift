//
//  Booking.swift
//  PerfectSelf
//
//  Created by user237184 on 7/19/23.
//  Copyright © 2023 Stas Seldin. All rights reserved.
//

import Foundation

class BookingInfo {
    var uid = ""
    var readerUid: String = ""
    var readerName: String = ""
    var bookingDate: String = ""//yyyy-MM-dd
    var bookingStartTime: String = ""//HH:mm:ss
    var bookingEndTime: String = ""
    var projectName: String = ""
    var script: String = ""
    var scriptBucket: String = ""
    var scriptKey: String = ""
    
    init() {
        reset()
    }
    
    func reset(){
        uid = ""
        readerUid = ""
        readerName = ""
        bookingDate = ""//yyyy-MM-dd
        bookingStartTime = ""//HH:mm:ss
        bookingEndTime = ""
        projectName = ""
        script = ""
        scriptBucket = ""
        scriptKey = ""
    }
}
