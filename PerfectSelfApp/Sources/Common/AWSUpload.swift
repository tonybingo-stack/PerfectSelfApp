//
//  AWSUpload.swift
//  PerfectSelf
//
//  Created by Kayan Mishra on 3/2/23.
//  Copyright © 2023 Stas Seldin. All rights reserved.
//

import Foundation
import AWSCore
import AWSS3

class AWSUpload: URLSessionDelegate, NSObject
{
    
    var description: String
    var multipartUploadId: String = ""
    var completedPartsInfo: AWSS3CompletedMultipartUpload?
    var chunckSize: Int32 = 5 * 1024 * 1024//5M
    var bucketName: String = "video-client-upload-123456798"
    var fileName: String = ""
    var contentType: String =  "video/x-m4v"
    var session: URLSession?
    var chunkUrls: [URL] = [URL]()
    
    init()
    {
        //Create a credentialsProvider to instruct AWS how to sign those URL
        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: "AKIAUG22JIQEI4J44HP7", secretKey: "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")
        
        //create a service configuration with the credential provider we just created
        let configuration = AWSServiceConfiguration.init(region: AWSRegionType.USEast2, credentialsProvider: credentialsProvider)
        
        //set this as the default configuration
        //this way any time the AWS frameworks needs to get credential
        //information, it will get those from the credential provider we just created
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        self.session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
    }
    
    func upload(filePath: URL) -> Void
    {
        //create a request to start a multipart upload
        let multipart = AWSS3CreateMultipartUploadRequest()
        
        //the key in AWS S3 parlance is the name of the file, it needs to be unique
        multipart!.key = "myGreatFile"
        
        //tell which bucket you want to upload to
        multipart!.bucket = self.bucketName
        
        //and the content type of the file you are uploading (in my case MP4 video)
        multipart!.contentType = "video/MP4"
        
        //access the default AWS S3 object, which is configured appropriately
        let awsService = AWSS3.default()
        generateFileDataInChunks( filePath: filePath )
        
        //actually create the multipart upload using the multipart request we created earlier
        awsService.createMultipartUpload(multipart!).continueWith (block: { (task:AWSTask!) -> AnyObject? in
            if( task.error != nil )
            {
                let fileManager = FileManager.default
                do {
                    for tmpUrl in self.chunkUrls {
                        try fileManager.removeItem( atPath: tmpUrl.absoluteString )
                    }
                } catch{}
                return task
            }
            
            //get the ID that AWS uses to uniquely identify this upload as you'll need it later
            let output:AWSS3CreateMultipartUploadOutput = task.result!
            self.multipartUploadId = output.uploadId! as String
            
            //as individual part complete you'll want to keep track of those
            //as AWS S3 requires the list of all parts to be able to reassemble the file
            self.completedPartsInfo = AWSS3CompletedMultipartUpload()
            
            //now that we have an upload ID we can actually start uploading the parts
            self.uploadAllParts(filePath: filePath)
            
            return task
        })
    }
    
    func uploadAllParts (filePath: URL)
    {
        //get the file size of the file to upload
//        let fileAttributes = try! FileManager.default.attributesOfItem(atPath: filePath.absoluteString)
//        let fileSizeNumber = fileAttributes[FileAttributeKey.size] as! NSNumber
//        let fileSize = fileSizeNumber.int64Value
        
        //figure out how many parts we're going to have
//        let partsCount = Int(fileSize / Int64(self.chunckSize)) + 1  //+1: if the file is 5Mb and chunkSize is 10, the 5/10 will be 0 but we have 1 part
        let partsCount = self.chunkUrls.count
        
        //create a part for each chunk
        //var partsStarted = 0
        var chunkIndex = 1
        while partsCount >= chunkIndex
        {
            //reading from file allocates memory in chunk the same size as the chunck
            //need to release it to avoid running out of memory
            autoreleasepool {
                self.uploadAWSPart(chunkIndex)
                chunkIndex += 1
            }
        }
    }
    
    func uploadAWSPart(_ awsPartNumber:Int)
    {
        //Get a presigned URL for AWS S3
        let getPreSignedURLRequest = AWSS3GetPreSignedURLRequest()

        //specify which bucket we want to upload to
        getPreSignedURLRequest.bucket = self.bucketName

        //specify what is the name of the file
        getPreSignedURLRequest.key = self.fileName

        //for upload, we need to do a PUT
        getPreSignedURLRequest.httpMethod = AWSHTTPMethod.PUT;

        //this is where the magic happens, you can specify how long you want
        //this pre-signed URL to be valid for, in this case 36 hours
        getPreSignedURLRequest.expires = Date(timeIntervalSinceNow: 36 * 60 * 60);

        //Important: set contentType for a PUT request.
        getPreSignedURLRequest.contentType = self.contentType

        //Tell AWS which upload you are uploading to, this is a value we got earlier
        getPreSignedURLRequest.setValue(self.multipartUploadId, forRequestParameter: "uploadId")

        //tell AWS what is the index of this part, note that this needs to be a string for some reason
        getPreSignedURLRequest.setValue(String(awsPartNumber), forRequestParameter: "partNumber")

        //generate the file for the current chunck
        //NSURLSession can only work from files when working in the background
        //so we need to create a file containing just the part required
        let URL = self.chunkUrls[awsPartNumber-1]

        //AWS wants to get an MD5 hash of the file to make sure everything got transfered ok
        let MD5 = (try? Data(contentsOf: URL))?.base64EncodedString()
        getPreSignedURLRequest.contentMD5 = MD5

        //create a presigned URL request for this specific chunk
        let presignedTask = AWSS3PreSignedURLBuilder.default().getPreSignedURL(getPreSignedURLRequest)

        //run the request to get a presigned URL
        presignedTask.continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask!) -> AnyObject? in
            if let presignedURL = task.result
            {
                //we now have the URL we can use to upload this chunk...
                self.startUploadForPresignedURL (presignedURL as URL, chunkURL: URL, awsPartNumber: awsPartNumber)
            }
            return task
        })
    }
    
    func generateFileDataInChunks(filePath: URL)
    {
//        let doumentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
//        let filePath = doumentDirectoryPath.appendingPathComponent("video.mp4")
        
        self.fileName = filePath.lastPathComponent
        //Check file exits at path or not.
        //if FileManager.default.fileExists(atPath: filePath)
        //{
            let chunkSize = self.chunckSize // divide data into 5M
            
            do {
                //open file for reading.
                let outputFileHandle = try FileHandle(forReadingFrom: filePath)
                var datas = outputFileHandle.readData(ofLength: Int(chunkSize))
                while !(datas.isEmpty)
                {
                    //here I write chunk data to ReadData or you can directly write to socket.
                    //ReadData.append(datas!)
                    // get the next chunk
                    datas = outputFileHandle.readData(ofLength: Int(chunkSize))
                    let tmpUrl = writeTempFile( data: datas )
                    self.chunkUrls.append( tmpUrl )
                    //print("Running: \(ReadData.length)")
                }
                
                //close outputFileHandle after reading data complete.
                outputFileHandle.closeFile()
                print("File reading complete")
            }catch let error as NSError {
                print("Error : \(error.localizedDescription)")
            }
        //}
    }
    
    func writeTempFile(data: Data) -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("tmp")
        try? data.write(to: url)
        return url
    }
    
    func startUploadForPresignedURL (_ presignedURL:URL, chunkURL: URL, awsPartNumber: Int)
    {
        //create the request with the presigned URL
        let urlRequest = NSMutableURLRequest(url: presignedURL)
        urlRequest.cachePolicy = .reloadIgnoringLocalCacheData
        urlRequest.httpMethod = "PUT"
        urlRequest.setValue(self.contentType, forHTTPHeaderField: "Content-Type")
        urlRequest.setValue((try? Data(contentsOf: chunkURL))!.base64EncodedString(), forHTTPHeaderField: "Content-MD5")
        
        //create the upload task with the request
        let uploadTask =  self.session!.uploadTask(with: urlRequest as URLRequest, fromFile: chunkURL)
        
        //set the part number as the description so we can keep track of the various tasks
        uploadTask.taskDescription = String(awsPartNumber)
        
        //start the part upload
        uploadTask.resume()
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64)
    {
        self.handleSuccessfulPartUploadInSession(session, task: task)
        //let uploadProgress = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
    }
    
    func handleSuccessfulPartUploadInSession (_ session: Foundation.URLSession, task: URLSessionTask)
    {
        //for each part we need to save the etag and the part number
        let completedPart = AWSS3CompletedPart()
        
        //remember how we saved the part number in the task description, time to get it back
        completedPart?.partNumber = NSNumber(value: UInt(task.taskDescription!)!)
        
        //save the etag as AWS needs that information
        let headers = (task.response as! HTTPURLResponse).allHeaderFields
        completedPart?.eTag = headers["ETag"] as? String
        
        //add the part to the list of completed parts
        self.completedPartsInfo!.parts?.append(completedPart!)

        //check if there are any other parts uploading
        self.session!.getAllTasks(completionHandler: { (tasks:[URLSessionTask]) -> Void in
            if tasks.count > 1 //completed task are flushed from the list, current task is still listed though, hence 1
            {
                //upload is still progressing
            }
            else
            {
                //all parts were uploaded, let AWS know
                self.completeUpload(session)
            }
        })
    }
    
    func completeUpload (_ session:Foundation.URLSession)
    {
        //For some reason AWS needs the parts sorted, it can't do it on its own...
        let descriptor = NSSortDescriptor(key: "partNumber", ascending: true)
        //{{
        //self.completedPartsInfo!.parts = (self.completedPartsInfo.parts! as NSArray).sortedArrayUsingDescriptors([descriptor])
        //==
        let partsAry: NSArray = self.completedPartsInfo!.parts! as NSArray
        self.completedPartsInfo!.parts = partsAry.sortedArray(using: [descriptor]) as? [AWSS3CompletedPart]
        //}}

        //close up the session as we are done
        self.session!.finishTasksAndInvalidate()
        self.session = nil

        //create the request to complete the multipart upload
        let complete = AWSS3CompleteMultipartUploadRequest()
        complete!.uploadId = self.multipartUploadId
        complete!.bucket = self.bucketName
        complete!.multipartUpload = self.completedPartsInfo
        complete!.key = "myGreatFile"

        //run the request that will complete the uplaod
        AWSS3.default().completeMultipartUpload(complete!).continueWith(block: { (task:AWSTask!) -> AnyObject? in
            //handle error and do any needed cleanup
            let fileManager = FileManager.default
            do {
                for tmpUrl in self.chunkUrls {
                    try fileManager.removeItem( atPath: tmpUrl.absoluteString )
                }
            } catch{}
            return nil
        })
    }
}
