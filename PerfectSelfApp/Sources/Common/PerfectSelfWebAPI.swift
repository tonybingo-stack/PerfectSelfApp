//
//  PerfectSelfWebAPI.swift
//  PerfectSelf
//
//  Created by Kayan Mishra on 3/17/23.
//  Copyright © 2023 Stas Seldin. All rights reserved.
//

import Foundation

class PerfectSelfWebAPI
{
    let PERFECTSELF_WEBAPI_ROOT:String = "http://18.119.1.15:5001/api/"

    init()
    {
        
    }
    
    deinit
    {
    }
    
    func executeAPI(with method:String, apiPath: String, json: [String: Any?], completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> Void
    {
        let urlString = "\(PERFECTSELF_WEBAPI_ROOT)\(apiPath)"
        let encodedString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        let url = URL(string: encodedString!)!
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if method != "GET" {
            request.httpBody = jsonData
            request.setValue("\(String(describing: jsonData?.count))", forHTTPHeaderField: "Content-Length")
        }
        
        let task = URLSession.shared.dataTask(with: request, completionHandler:completionHandler)
        task.resume()
    }
    
    func executeAPIEX(with method:String, apiPath: String, json: [[String: Any?]], completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> Void
    {
        let urlString = "\(PERFECTSELF_WEBAPI_ROOT)\(apiPath)"
        let encodedString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        let url = URL(string: encodedString!)!
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if method != "GET" {
            request.httpBody = jsonData
            request.setValue("\(String(describing: jsonData?.count))", forHTTPHeaderField: "Content-Length")
        }
        
        let task = URLSession.shared.dataTask(with: request, completionHandler:completionHandler)
        task.resume()
    }
    
    func login(userType: Int, email: String, password: String, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> Void
    {
        let json: [String: Any] = ["userType": userType,// 3 for actor, 4 for reader
                                   "email": email,
                                   "password": password]
        
        return executeAPI(with: "POST", apiPath: "Users/Login", json: json, completionHandler:completionHandler)
    }
    
    func signup(userType: Int, userName: String, firstName: String, lastName: String, email: String, password: String, phoneNumber: String, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> Void
    {
        let json: [String: Any] = [
            "userType": userType,
            "userName": userName,
            "email": email,
            "password": password,
            "avatarBucketName": "",
            "avatarKey": "",
            "firstName": firstName,
            "lastName": lastName,
            "dateOfBirth": "",
            "gender": 0,
            "currentAddress": "",
            "permanentAddress": "",
            "city": "",
            "nationality": "",
            "phoneNumber": phoneNumber,
            "isLogin": false,
            "token": "",
            "isDeleted": false,
        ]
        return executeAPI(with: "POST", apiPath: "Users", json: json, completionHandler:completionHandler)
    }
    
    func getActorProfile(actoruid: String, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> Void
    {
        return executeAPI(with: "GET", apiPath: "ActorProfiles/ByUid/\(actoruid)", json: [:], completionHandler:completionHandler)
    }
    
    func updateActorProfile(actoruid: String, ageRange: String, height: String, weight: String, country: String, state: String, city: String, agency: String, vaccination: Int, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> Void
    {
        let json: [String: Any] = [
            "title": "",
            "actorUid": actoruid,
            "ageRange": ageRange,
            "height": Float(height) ?? 0,
            "weight": Float(weight) ?? 0,
            "country": country,
            "state": state,
            "city": city,
            "agency": agency,
            "vaccinationStatus": vaccination,
        ]
      print(json)
        return executeAPI(with: "PUT", apiPath: "ActorProfiles/ByUid/\(actoruid)", json: json, completionHandler:completionHandler)
    }
    
    func getUserInfo(uid: String, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> Void
    {
        return executeAPI(with: "GET", apiPath: "Users/\(uid)", json: [:], completionHandler:completionHandler)
    }
    
    func updateUserInfo(uid: String
                        , userType: Int
                        , bucketName: String
                        , avatarKey: String
                        , username: String
                        , email: String
                        , password: String
                        , firstName: String
                        , lastName: String
                        , dateOfBirth: String
                        , gender: Int
                        , currentAddress: String
                        , permanentAddress: String
                        , city: String
                        , nationality: String
                        , phoneNumber: String
                        , isLogin: Bool
                        , fcmDeviceToken: String
                        , deviceKind: Int
                        , completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> Void
    {
        let json: [String: Any] = [
            "userType": userType, //-1,
            "avatarBucketName": bucketName,//"none",
            "avatarKey": avatarKey, //"none",
            "userName": username, //"",
            "email": email, //"",
            "password": password, //"",
            "firstName": firstName, //"",
            "lastName": lastName, //"",
            "dateOfBirth": dateOfBirth, //"",
            "gender": gender, //0,
            "currentAddress": currentAddress, //"",
            "permanentAddress": permanentAddress, //"",
            "city": city, //"",
            "nationality": nationality, //"",
            "phoneNumber": phoneNumber, //"",
            "isLogin": isLogin, // true,
            "token": "",
            "fcmDeviceToken": fcmDeviceToken, //"",
            "deviceKind": deviceKind //0
        ]
    
        return executeAPI(with: "PUT", apiPath: "Users/\(uid)", json: json, completionHandler:completionHandler)
    }
    
    func sendPushNotifiction(toFCMToken: String
                        , title: String
                        , body: String
                        , completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> Void
    {
        let json: [String: Any] = [
            "deviceId":  toFCMToken,
            "deviceKind": 0,
            "title": title,
            "body": body
        ]
    
        return executeAPI(with: "POST", apiPath: "Notification/send", json: json, completionHandler:completionHandler)
    }
    
    func uploadUserIntroVideo(uid: String, bucketName: String, videoKey: String, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> Void
    {
        let json: [String: Any] = [
            "title": "",
            "readerUid": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
            "min15Price": -1,
            "min30Price": -1,
            "hourlyPrice": -1,
            "voiceType": -1,
            "others": -1,
            "about": "",
            "reviewCount": -1,
            "score": -1,
            "skills": "",
            "isSponsored": true,
            "introBucketName": bucketName,
            "introVideoKey": videoKey,
            "auditionType": -1
        ]
    
        return executeAPI(with: "PUT", apiPath: "ReaderProfiles/\(uid)", json: json, completionHandler:completionHandler)
    }
    
    func getReaders(readerName: String?, isSponsored: Bool?, isAvailableSoon: Bool?, isTopRated: Bool?, isOnline: Bool?, availableTimeSlotType: Int?, availableFrom: String?, availableTo: String?, minPrice: Float?, maxPrice: Float?, gender: [Int]?, sortBy: Int?, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> Void
    {
        var params = ""
        var isParamsExist = false
        if readerName != nil {
            isParamsExist = true
            params += "readerName=\(readerName!)"
        }
        if isSponsored ?? false {
            params += (isParamsExist ? "&":"") + "isSponsored=\(isSponsored!)"
            isParamsExist = true
        }
        if isAvailableSoon ?? false {
            params += (isParamsExist ? "&":"") + "availableSoon=\(isAvailableSoon!)"
            isParamsExist = true
        }
        if isTopRated ?? false {
            params += (isParamsExist ? "&":"") + "topRated=4.5"
            isParamsExist = true
        }
        if isOnline != nil {
            params += (isParamsExist ? "&":"") + "isOnline=\(isOnline!)"
            isParamsExist = true
        }
        if availableTimeSlotType != nil {
            params += (isParamsExist ? "&":"") + "availableTimeSlotType=\(availableTimeSlotType!)"
            isParamsExist = true
        }
        if availableFrom != nil {
            params += (isParamsExist ? "&":"") + "availableFrom=\(availableFrom!)&availableTo=\(availableTo!)"
            isParamsExist = true
        }
        if minPrice != nil {
            params += (isParamsExist ? "&":"") + "minPrice=\(minPrice!)&maxPrice=\(maxPrice!)"
            isParamsExist = true
        }
        if gender != nil && gender!.count > 0 {
            params += (isParamsExist ? "&":"")
            
            for (index, gend) in gender!.enumerated() {
                params += "genders=\(gend)"
                if(index + 1 < gender!.count) {params += "&"}
            }
            isParamsExist = true
        }
        if sortBy != nil {
            params += (isParamsExist ? "&":"") + "sortBy=\(sortBy!)"
            isParamsExist = true
        }
      
        return executeAPI(with: "GET", apiPath: "ReaderProfiles/ReaderList?\(params)", json: [:], completionHandler:completionHandler)
    }
    
    func getReaderById(id: String, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> Void
    {
        return executeAPI(with: "GET", apiPath: "ReaderProfiles/Detail/\(id)", json: [:], completionHandler:completionHandler)
    }
    
    func editReaderProfile(uid: String,title: String,min15Price: Float,min30Price: Float,hourlyPrice: Float, about: String, introBucketName: String, introVideokey: String, skills: String?, auditionType: Int, isExplicitRead: Bool?, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> Void
    {
        let json: [String: Any?] = [
            "id": 0,// no effect
            "title": title, //no update
            "readerUid": uid,// no effect
            "min15Price": min15Price,
            "min30Price": min30Price,
            "hourlyPrice": hourlyPrice, //no update
            "voiceType": -1, //no update
            "others": -1, // no update
            "about": about, //no update
            "skills": skills,
            "isSponsored": true,//no effect
            "isExplicitRead": isExplicitRead,
            "introBucketName": introBucketName, // no update
            "introVideoKey": introVideokey, // no update
            "auditionType": auditionType
        ]
        //print(json)
     
        return executeAPI(with: "PUT", apiPath: "ReaderProfiles/\(uid)", json: json, completionHandler:completionHandler)
    }
    
    func updateTapeFolder(tapeId: String, parentId: String, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> Void
    {
        let parentParam = (parentId.isEmpty ? "" : "?parentId=\(parentId)")
        return executeAPI(with: "PUT", apiPath: "Library/UpdateTapeFolder/\(tapeId)\(parentParam)", json: [:], completionHandler:completionHandler)
    }
    
    func bookAppointment(actorUid: String, readerUid: String, projectName: String, bookStartTime: String,bookEndTime: String, script: String,scriptBucket: String, scriptKey: String, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> Void
    {
                
        let json: [String: Any] = [
            "actorUid": actorUid,
            "readerUid": readerUid,
            "projectName": getStringWithLen( projectName, 64),
            "bookStartTime": localToUTC(dateStr: bookStartTime)!,
            "bookEndTime": localToUTC(dateStr: bookEndTime)!,
            "scriptFile": script,
            "scriptBucket": scriptBucket,
            "scriptKey": scriptKey
        ]
   
        return executeAPI(with: "POST", apiPath: "Books/", json: json, completionHandler:completionHandler)
    }
    
    func getBookingsByUid(uid: String, bookType: Int, name: String, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> Void
    {
        return executeAPI(with: "GET", apiPath: "Books/DetailList/ByUid/\(uid)?bookType=\(bookType)&name=\(name)", json: [:], completionHandler:completionHandler)
    }
    
    func getBookingsInMinsByUid(uid: String, mins: Int=365*24*60, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> Void
    {
        return executeAPI(with: "GET", apiPath: "Books/ByUid/\(uid)?inMin=\(mins)", json: [:], completionHandler:completionHandler)
    }
    
    func cancelBookingByRoomUid(uid: String, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> Void
    {
        return executeAPI(with: "DELETE", apiPath: "Books/ByRoomUid/\(uid)", json: [:], completionHandler:completionHandler)
    }
    
    func acceptBookingById(id: Int, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> Void
    {
        return executeAPI(with: "POST", apiPath: "Books/Accept/\(id)", json: [:], completionHandler:completionHandler)
    }
    
    func rescheduleBooking(id: Int, bookStartTime: String, bookEndTime: String, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> Void
    {
        let json: [String: Any] = [
            "actorUid": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
            "readerUid": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
            "roomUid": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
            "bookStartTime": localToUTC(dateStr: bookStartTime)!,
            "bookEndTime": localToUTC(dateStr: bookEndTime)!,
            "scriptFile": "string",
            "isAccept": true,
            "readerScore": 0,
            "readerReview": "string",
            "readerReviewDate": "2023-04-18T17:03:55.098Z"
        ]

        return executeAPI(with: "POST", apiPath: "Books/Reschedule/\(id)", json: json, completionHandler:completionHandler)
    }
    
    func getAvailabilityById(uid: String, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> Void
    {
        return executeAPI(with: "GET", apiPath: "Availabilities/UpcomingByUid/\(uid)/\(Date.getStringFromDate(date: Date()))", json: [:], completionHandler:completionHandler)
    }
    
    func getLibraryByUid(uid: String, pid: String, keyword: String, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> Void
    {
        return executeAPI(with: "GET", apiPath: "Library/ByUid/\(uid)?parentId=\(pid)&keyword=\(keyword)", json: [:], completionHandler:completionHandler)
    }
    
    func deleteTapeByUid(uid: String?, tapeKey: String?, roomUid: String?, tapeId: String?, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> Void
    {
        guard let _=uid, let _=tapeKey, let _=roomUid else{
            return
        }
        let tapeKey = encodeURLParameter(tapeKey!)
        return executeAPI(with: "DELETE", apiPath: "Library/DeleteBy/\(uid!)/\(tapeKey!)/\(roomUid!)/\(tapeId!)", json: [:], completionHandler:completionHandler)
    }
    
    func getTapeCountByKey(tapeKey: String?, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> Void
    {
        guard let _=tapeKey else{
            return
        }
        let tapeKey = encodeURLParameter(tapeKey!)
        return executeAPI(with: "GET", apiPath: "Library/CountByTapeKey/\(tapeKey!)", json: [:], completionHandler:completionHandler)
    }

    func addAvailability(uid: String, date: String, fromTime: String, toTime: String, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> Void
    {
        let json: [String: Any] = [
            "readerUid": uid,
            "isDeleted": false,
            "date": localToUTC(dateStr: date)!,
            "fromTime": localToUTC(dateStr: fromTime)!,
            "toTime": localToUTC(dateStr: toTime)!
        ]
        return executeAPI(with: "POST", apiPath: "Availabilities/", json: json, completionHandler:completionHandler)
    }
    
    func updateAvailability(uid: String, timeSlotList: [TimeSlot], completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> Void
    {
        var batchData: [[String: Any]] = [[:]]
        batchData.removeAll()
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        for item in timeSlotList {
            for slot in item.time {
                var fromTime = df.string(from: Date.getDateFromString(date: item.date)!)
                var toTime = fromTime
                if slot.slot == 1 {
                    fromTime += "T09:00:00"
                    toTime += "T10:00:00"
                } else if slot.slot == 2 {
                    fromTime += "T10:00:00"
                    toTime += "T11:00:00"
                } else if slot.slot == 3 {
                    fromTime += "T11:00:00"
                    toTime += "T12:00:00"
                } else if slot.slot == 4 {
                    fromTime += "T12:00:00"
                    toTime += "T13:00:00"
                } else if slot.slot == 5 {
                    fromTime += "T13:00:00"
                    toTime += "T14:00:00"
                } else if slot.slot == 6 {
                    fromTime += "T14:00:00"
                    toTime += "T15:00:00"
                } else if slot.slot == 7 {
                    fromTime += "T15:00:00"
                    toTime += "T16:00:00"
                } else if slot.slot == 8 {
                    fromTime += "T16:00:00"
                    toTime += "T17:00:00"
                } else if slot.slot == 9 {
                    fromTime += "T17:00:00"
                    toTime += "T18:00:00"
                } else if slot.slot == 10 {
                    fromTime += "T18:00:00"
                    toTime += "T19:00:00"
                } else if slot.slot == 11 {
                    fromTime += "T19:00:00"
                    toTime += "T20:00:00"
                } else if slot.slot == 12 {
                    fromTime += "T20:00:00"
                    toTime += "T21:00:00"
                } else if slot.slot == 13 {
                    fromTime += "T21:00:00"
                    toTime += "T22:00:00"
                } else if slot.slot == 14 {
                    fromTime += "T22:00:00"
                    toTime += "T23:00:00"
                } else {
                    fromTime += "T00:00:00"
                    toTime += "T00:00:00"
                }
                let p: [String:Any] = [
                    "id": slot.id,
                    "readerUid": uid,
                    "isDeleted": slot.isDeleted,
                    "isStandBy": item.isStandBy,
                    "repeatFlag": item.repeatFlag,
                    "date": localToUTC(dateStr: item.date)!,
                    "fromTime": localToUTC(dateStr: fromTime)!,
                    "toTime": localToUTC(dateStr: toTime)!
                ]
                batchData.append(p)
            }
        }
        print(batchData)
        return executeAPIEX(with: "PUT", apiPath: "Availabilities/UpdateBatch", json: batchData, completionHandler:completionHandler)
    }
    
    func giveFeedback(id: Int, score: Float, review: String, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> Void
    {
        print("Books/GiveFeedbackToUid/\(id)?score=\(score)&review=\(review)")
        return executeAPI(with: "PUT", apiPath: "Books/GiveFeedbackToUid/\(id)?score=\(score)&review=\(review)", json: [:], completionHandler:completionHandler)
    }
    
    func getUnreadCountByUid(uid: String, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> Void
    {
        return executeAPI(with: "GET", apiPath: "MessageHistory/GetUnreadCountEx/\(uid)", json: [:], completionHandler:completionHandler)
    }
    
    func getChannelHistoryByUid(uid: String, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> Void
    {
        return executeAPI(with: "GET", apiPath: "MessageHistory/GetChannelHistory/\(uid)", json: [:], completionHandler:completionHandler)
    }
    
    func getMessageHistoryByRoomId(roomId: String, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> Void
    {
        return executeAPI(with: "GET", apiPath: "MessageHistory/GetChatHistory/\(roomId)", json: [:], completionHandler:completionHandler)
    }
    
    func getRoomIdBySendUidAndReceiverUid(sUid: String, rUid: String, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> Void
    {
        return executeAPI(with: "GET", apiPath: "MessageHistory/GetRoomId/\(sUid)/\(rUid)", json: [:], completionHandler:completionHandler)
    }
    
    func sendMessage(roomId: String,sUid: String, rUid: String, message: String, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> Void
    {
        let json: [String: Any] = [
            "senderUid": sUid,
            "receiverUid": rUid,
            "roomUid": roomId,
            "message": message
        ]
        
        return executeAPI(with: "POST", apiPath: "MessageHistory", json: json, completionHandler:completionHandler)
    }
    
    func updateAllMessageReadState(suid: String, ruid: String, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> Void
    {
        return executeAPI(with: "PUT", apiPath: "MessageHistory/SetAllReadMessage/\(ruid)/\(suid)", json: [:], completionHandler:completionHandler)
    }
    
    func updateOnlineState(uid: String, newState: Bool, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> Void
    {
        return executeAPI(with: "PUT", apiPath: "Users/ChangeOnline/\(uid)?state=\(newState)", json: [:], completionHandler:completionHandler)
    }
    
    func login() -> Void
    {
        let json: [String: Any] = ["userName": "tester",
                                   "email": "tester@gmail.com",
                                   "password": "123456"]
        
        return executeAPI(with: "POST", apiPath: "Users/Login", json: json){ data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
//            print("ok")
//            print(data)
            if let responseJSON = responseJSON as? [String: Any] {
                //print(responseJSON["result"])
                let result = responseJSON["result"] as! CFBoolean
                if result as! Bool {
                    let user = responseJSON["user"] as? [String: Any]
                    let token = user!["token"] as? String
                    print(token!)
//                    return token!
                }
            }
        }
    }
    
    func addLibrary(uid: String, tapeName: String, bucketName: String, tapeKey: String, roomUid: String, tapeId: String, parentId: String="", completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> Void
    {
        let json: [String: Any] = ["readerUid": uid,
                                   "tapeName": tapeName,
                                   "bucketName": bucketName,
                                   "tapeKey": tapeKey,
                                   "RoomUid": roomUid,
                                   "TapeId": tapeId,
                                   "ParentId": parentId
                                    ]
        
        return executeAPI(with: "POST", apiPath: "Library", json: json, completionHandler: completionHandler)
//        { data, response, error in
//            guard let data = data, error == nil else {
//                print(error?.localizedDescription ?? "No data")
//                return
//            }
//            let _ = try? JSONSerialization.jsonObject(with: data, options: [])
////            print("ok")
////            print(data)
//        }
    }
    
    func getCountries(completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> Void
    {
        let json: [String: Any] = [:]
        return executeAPI(with: "GET", apiPath: "Address/countries", json: json, completionHandler:  completionHandler)
    }
    
    func getStates(countryCode: String, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> Void
    {
        let json: [String: Any] = [:]
        return executeAPI(with: "GET", apiPath: "Address/states/\(countryCode)", json: json, completionHandler:  completionHandler)
    }
    
    func getCities(stateCode: String, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> Void
    {
        let json: [String: Any] = [:]
        return executeAPI(with: "GET", apiPath: "Address/cities/\(stateCode)", json: json, completionHandler:  completionHandler)
    }
    
    func sendVerifyCodeToEmail(email: String, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> Void
    {
        return executeAPI(with: "GET", apiPath: "Email/SendVerifyCode/\(email)", json: [:], completionHandler:  completionHandler)
    }
    
    func verifyCode(email: String, code: String, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> Void
    {
        return executeAPI(with: "GET", apiPath: "Users/VerifyForResetPassword/\(email)/\(code)", json: [:], completionHandler:  completionHandler)
    }
    
    func logSend(meetingUid: String, log: String, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> Void
    {
        return executeAPI(with: "GET", apiPath: "Log/\(meetingUid)/\(log)", json: [:], completionHandler:  completionHandler)
    }
    
    func resetPassword(email: String, code: String, password: String, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> Void
    {
        return executeAPI(with: "POST", apiPath: "Users/ResetPassword/\(email)/\(code)/\(password)", json: [:], completionHandler:  completionHandler)
    }
    
    func getLibraryURLs( urls: inout [String]) -> Void
    {
    //    var request = URLRequest(url: URL(string: "https://www.example.com/api/v1")!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
    //    let config = URLSessionConfiguration.default
    //    let session = URLSession(configuration: config)
    //    let task = session.dataTask(with: request, completionHandler: {(data, response, error) in
    //         if error != nil {
    //              print(error!.localizedDescription)
    //         }
    //         else {
    //             //print(response)//print(response ?? default "")
    //         }
    //     })
    //    task.resume()
        urls.append("https://video-thumbnail-bucket-123456789.s3.us-east-2.amazonaws.com/2023-02-03/123456789/tester2_2023-2-3_12h25m22s~2023-2-3_12h25m32s-0.jpg")
        urls.append("https://video-thumbnail-bucket-123456789.s3.us-east-2.amazonaws.com/2023-02-03/123456789/tester2_2023-2-3_12h25m22s~2023-2-3_12h25m32s-1.jpg")
        urls.append("https://video-thumbnail-bucket-123456789.s3.us-east-2.amazonaws.com/2023-02-03/123456789/tester2_2023-2-3_6h25m21s~2023-2-3_6h25m32s-0.jpg")
        urls.append("https://video-thumbnail-bucket-123456789.s3.us-east-2.amazonaws.com/2023-02-03/123456789/tester2_2023-2-3_6h25m21s~2023-2-3_6h25m32s-1.jpg")
        urls.append("https://video-thumbnail-bucket-123456789.s3.us-east-2.amazonaws.com/2023-02-05/123456789/tester1_2023-2-5_1h9m35s~2023-2-5_1h9m45s-0.jpg")
        urls.append("https://video-thumbnail-bucket-123456789.s3.us-east-2.amazonaws.com/2023-02-05/123456789/tester1_2023-2-5_1h9m35s~2023-2-5_1h9m45s-1.jpg")
        urls.append("https://video-thumbnail-bucket-123456789.s3.us-east-2.amazonaws.com/2023-02-03/123456789/tester2_2023-2-3_6h25m21s~2023-2-3_6h25m32s-0.jpg")
        urls.append("https://video-thumbnail-bucket-123456789.s3.us-east-2.amazonaws.com/2023-02-03/123456789/tester2_2023-2-3_6h25m21s~2023-2-3_6h25m32s-0.jpg")
        urls.append("https://video-thumbnail-bucket-123456789.s3.us-east-2.amazonaws.com/2023-02-03/123456789/tester2_2023-2-3_6h25m21s~2023-2-3_6h25m32s-0.jpg")
        urls.append("https://video-thumbnail-bucket-123456789.s3.us-east-2.amazonaws.com/2023-02-03/123456789/tester2_2023-2-3_6h25m21s~2023-2-3_6h25m32s-0.jpg")
        urls.append("https://video-thumbnail-bucket-123456789.s3.us-east-2.amazonaws.com/2023-02-03/123456789/tester2_2023-2-3_6h25m21s~2023-2-3_6h25m32s-0.jpg")
        urls.append("https://video-thumbnail-bucket-123456789.s3.us-east-2.amazonaws.com/2023-02-03/123456789/tester2_2023-2-3_6h25m21s~2023-2-3_6h25m32s-0.jpg")
        urls.append("https://video-thumbnail-bucket-123456789.s3.us-east-2.amazonaws.com/2023-02-03/123456789/tester2_2023-2-3_6h25m21s~2023-2-3_6h25m32s-0.jpg")
        urls.append("https://video-thumbnail-bucket-123456789.s3.us-east-2.amazonaws.com/2023-02-03/123456789/tester2_2023-2-3_6h25m21s~2023-2-3_6h25m32s-0.jpg")
        
    }
}
