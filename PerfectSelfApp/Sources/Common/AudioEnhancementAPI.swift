//
//  AudioEnhancementAPI.swift
//  PerfectSelf
//
//  Created by user232392 on 4/27/23.
//  Copyright © 2023 Stas Seldin. All rights reserved.
//

import Foundation
class AudioEnhancementAPI
{
    let API_ROOT_URL:String = "https://api.audo.ai/v1"
    let AUIDO_AI_APIKEY: String = "a5587cd5a567a3fba8a8093c85fc0ade"
    
    func getFileId(filePath: URL, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> Void {
        guard let url = URL(string: "\(API_ROOT_URL)/upload") else { return }

        let fileUrl = filePath

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = "Boundary-\(UUID().uuidString)"
        let contentType = "multipart/form-data; boundary=\(boundary)"
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        request.setValue(AUIDO_AI_APIKEY, forHTTPHeaderField: "x-api-key")
        
        let body = NSMutableData()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileUrl.lastPathComponent)\"\r\n".data(using: .utf8)!)
        
        body.append("Content-Type: application/octet-stream\r\n\r\n".data(using: .utf8)!)
        do {
            // Get the raw data from the file.
            let rawData: Data = try Data(contentsOf: fileUrl)
            // Return the raw data as an array of bytes.
            body.append(rawData)
        } catch {
            // Couldn't read the file.
            return
        }
        
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body as Data

        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: completionHandler)
       
        task.resume()

    }
    
    func removeNoise(fileId: String, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> Void {
        let json: [String: Any] = [
            "input": fileId,
            "outputExtension": "mp3"
        ]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        let url = URL(string: "\(API_ROOT_URL)/remove-noise")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(AUIDO_AI_APIKEY, forHTTPHeaderField: "x-api-key")
        
        request.httpBody = jsonData
        request.setValue("\(String(describing: jsonData?.count))", forHTTPHeaderField: "Content-Length")
        let task = URLSession.shared.dataTask(with: request, completionHandler:completionHandler)
        task.resume()
    }
    
    func getJobStatus(jobId: String, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> Void {
        let url = URL(string: "\(API_ROOT_URL)/remove-noise/\(jobId)/status")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(AUIDO_AI_APIKEY, forHTTPHeaderField: "x-api-key")
        
        let task = URLSession.shared.dataTask(with: request, completionHandler:completionHandler)
        task.resume()
    }
    func getResultFile(downloadPath: String, completionHandler: @escaping @Sendable (URL?, URLResponse?, Error?) -> Void) -> Void {
        
        let url = URL(string: "\(API_ROOT_URL)\(downloadPath)")!
        let request = URLRequest(url: url)
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
       
        let task = session.downloadTask(with: request, completionHandler: completionHandler)
        task.resume()
    }
}
