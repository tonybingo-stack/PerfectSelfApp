//
//  SignalClient.swift
//  WebRTC
//
//  Created by Stasel on 20/05/2018.
//  Copyright © 2018 Stasel. All rights reserved.
//

import Foundation
import WebRTC

protocol SignalClientDelegate: AnyObject {
    func signalClientDidConnect(_ signalClient: SignalingClient)
    func signalClientDidDisconnect(_ signalClient: SignalingClient)
    func signalClient(_ signalClient: SignalingClient, didReceiveRemoteSdp sdp: RTCSessionDescription, roomId: String)
    func signalClient(_ signalClient: SignalingClient, didReceiveCandidate candidate: RTCIceCandidate, roomId: String)
    func signalClient(_ signalClient: SignalingClient, didReceiveRequest roomId: String)
}

final class SignalingClient {
    
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private let webSocket: WebSocketProvider
    weak var delegate: SignalClientDelegate?
    
    init(webSocket: WebSocketProvider) {
        self.webSocket = webSocket
    }
    
    func connect() {
        self.webSocket.delegate = self
        self.webSocket.connect()
    }
    
    func send(sdp rtcSdp: RTCSessionDescription, roomId: String) {
        let message = Message.sdp(SessionDescription(from: rtcSdp, roomID: roomId))
        do {
            let dataMessage = try self.encoder.encode(message)
            
            self.webSocket.send(data: dataMessage)
        }
        catch {
            debugPrint("Warning: Could not encode sdp: \(error)")
        }
    }
    
    func send(candidate rtcIceCandidate: RTCIceCandidate, roomId: String) {
        let message = Message.candidate(IceCandidate(from: rtcIceCandidate, roomID: roomId))
        do {
            let dataMessage = try self.encoder.encode(message)
            self.webSocket.send(data: dataMessage)
        }
        catch {
            debugPrint("Warning: Could not encode candidate: \(error)")
        }
    }
    
    func sendRoomId(roomId: String) {
        let message = Message.sdp(SessionDescription(from: "", roomID: roomId))
        do {
            let dataMessage = try self.encoder.encode(message)
            self.webSocket.send(data: dataMessage)
        }
        catch {
            debugPrint("Warning: Could not encode sdp: \(error)")
        }
    }
    
    func sendRoomIdClose(roomId: String) {
        let message = Message.sdp(SessionDescription(from: "close", roomID: roomId))
        do {
            let dataMessage = try self.encoder.encode(message)
            self.webSocket.send(data: dataMessage)
        }
        catch {
            debugPrint("Warning: Could not encode sdp: \(error)")
        }
    }
}


extension SignalingClient: WebSocketProviderDelegate {
    func webSocketDidConnect(_ webSocket: WebSocketProvider) {
        self.delegate?.signalClientDidConnect(self)
    }
    
    func webSocketDidDisconnect(_ webSocket: WebSocketProvider) {
        self.delegate?.signalClientDidDisconnect(self)
        
        // try to reconnect every two seconds
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            debugPrint("Trying to reconnect to signaling server...")
            //Omitted self.webSocket.connect()
        }
    }
    
    func webSocket(_ webSocket: WebSocketProvider, didReceiveData data: Data) {
        let message: Message
        do {
            message = try self.decoder.decode(Message.self, from: data)
        }
        catch {
            debugPrint("Warning: Could not decode incoming message: \(error)")
            return
        }
        
        switch message {
        case .candidate(let iceCandidate):
            self.delegate?.signalClient(self, didReceiveCandidate: iceCandidate.rtcIceCandidate, roomId: iceCandidate.roomId)
        case .sdp(let sessionDescription):
            do {
                if(sessionDescription.sdp != "")
                {
                    self.delegate?.signalClient(self, didReceiveRemoteSdp: sessionDescription.rtcSessionDescription, roomId: sessionDescription.roomId)
                }
                else
                {
                    self.delegate?.signalClient(self, didReceiveRequest: sessionDescription.roomId)
                }
            }
        }

    }
}

final class SignalingClientStatus: NSObject, SignalClientDelegate {
    private let signalClient: SignalingClient
    private let webRTCClient: WebRTCClient
    //var roomId: String = ""
    
    public var signalingConnected: Bool = false {
        didSet {
//REFME
//            DispatchQueue.main.async {
//                if self.signalingConnected {
//                    self.signalingStatusLabel?.text = "Connected"
//                    self.signalingStatusLabel?.textColor = UIColor.green
//                }
//                else {
//                    self.signalingStatusLabel?.text = "Not connected"
//                    self.signalingStatusLabel?.textColor = UIColor.red
//                }
//            }
        }
    }
    
    public var hasLocalSdp: Bool = false {
        didSet {
//REFME
//            DispatchQueue.main.async {
//                self.localSdpStatusLabel?.text = self.hasLocalSdp ? "✅" : "❌"
//            }
        }
    }
    
    public var localCandidateCount: Int = 0 {
        didSet {
//REFME
//            DispatchQueue.main.async {
//                self.localCandidatesLabel?.text = "\(self.localCandidateCount)"
//            }
        }
    }
    
    public var hasRemoteSdp: Bool = false {
        didSet {
//REFME
//            DispatchQueue.main.async {
//                self.remoteSdpStatusLabel?.text = self.hasRemoteSdp ? "✅" : "❌"
//            }
        }
    }
    
    public var remoteCandidateCount: Int = 0 {
        didSet {
//REFME
//            DispatchQueue.main.async {
//                self.remoteCandidatesLabel?.text = "\(self.remoteCandidateCount)"
//            }
        }
    }
    
    init(signalClient: inout SignalingClient, webRTCClient: inout WebRTCClient) {
        self.signalClient = signalClient
        self.webRTCClient = webRTCClient
        
        super.init()
        
        self.signalingConnected = false
        self.hasLocalSdp = false
        self.hasRemoteSdp = false
        self.localCandidateCount = 0
        self.remoteCandidateCount = 0
        self.signalClient.delegate = self
        self.signalClient.connect()
    }
    
    func signalClientDidConnect(_ signalClient: SignalingClient) {
        self.signalingConnected = true
    }
    
    func signalClientDidDisconnect(_ signalClient: SignalingClient) {
        self.signalingConnected = false
    }
    
    func signalClient(_ signalClient: SignalingClient, didReceiveRemoteSdp sdp: RTCSessionDescription, roomId: String) {
        print("Received remote sdp roomId=\(roomId)")
        
        if (!self.hasRemoteSdp)
        {
            self.webRTCClient.set(remoteSdp: sdp) { (error) in
                self.hasRemoteSdp = true
            }
        }
        
        if (!self.hasLocalSdp && self.hasRemoteSdp){
            self.webRTCClient.answer { (localSdp) in
                self.hasLocalSdp = true
                self.signalClient.send(sdp: localSdp, roomId: roomId)
            }
        }
    }
    
    func signalClient(_ signalClient: SignalingClient, didReceiveCandidate candidate: RTCIceCandidate, roomId: String) {
        self.webRTCClient.set(remoteCandidate: candidate) { error in
            print("Received remote candidate roomId=\(roomId)")
            self.remoteCandidateCount += 1
        }
    }
    
    func signalClient(_ signalClient: SignalingClient, didReceiveRequest roomId: String) {
        self.webRTCClient.offer { (sdp) in
            self.hasLocalSdp = true
            self.signalClient.send(sdp: sdp, roomId: roomId)
        }
    }
}
