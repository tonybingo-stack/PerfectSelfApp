//
//  AWSMultipartUpload.swift
//  PerfectSelf
//
//  Created by Kayan Mishra on 3/4/23.
//  Copyright © 2023 Stas Seldin. All rights reserved.
//

import UIKit
import Foundation
import AWSCore
import AWSS3

class AWSMultipartUpload: NSObject, URLSessionTaskDelegate, URLSessionDataDelegate, URLSessionStreamDelegate, URLSessionWebSocketDelegate {
    var multipartUploadId: String = ""
    var completedPartsInfo: AWSS3CompletedMultipartUpload?
    var chunckSize: Int32 = 5 * 1024 * 1024//5M
    //Omitted var bucketName: String = "video-client-upload-123456798"
    var fileName: String = ""
    var contentType: String =  "video/MP4"
    var session: URLSession?
    var chunkUrls: [URL] = [URL]()
    let transferUtility: AWSS3TransferUtility
    
    override init()
    {
        //Create a credentialsProvider to instruct AWS how to sign those URL
        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: "AKIAUG22JIQEI4J44HP7", secretKey: "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")
        
        //create a service configuration with the credential provider we just created
        let configuration = AWSServiceConfiguration.init(region: AWSRegionType.USEast2, credentialsProvider: credentialsProvider)
        //let configuration = AWSServiceConfiguration(region: .USEast2,endpoint: AWSEndpoint(url: URL(string: "https://s3.amazonaws.com")) , credentialsProvider: credentialsProvider)
        
        //set this as the default configuration
        //this way any time the AWS frameworks needs to get credential
        //information, it will get those from the credential provider we just created
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        let tuConf = AWSS3TransferUtilityConfiguration()
        tuConf.isAccelerateModeEnabled = true
        tuConf.retryLimit = 5
        tuConf.multiPartConcurrencyLimit = 5
        tuConf.timeoutIntervalForResource = 15*60 //15 minutes

        //Register a transfer utility object asynchronously
        AWSS3TransferUtility.register(
            with: configuration!,
            transferUtilityConfiguration: tuConf,
            forKey: "transfer-utility-with-advanced-options"
        ) { (error) in
            if error != nil {
                 //Handle registration error.
             }
        }
        
        self.transferUtility = AWSS3TransferUtility.s3TransferUtility(forKey: "transfer-utility-with-advanced-options")!

//        //Look up the transfer utility object from the registry to use for your transfers.
//        let _:(AWSS3TransferUtility?) = AWSS3TransferUtility.s3TransferUtility(forKey: "transfer-utility-with-advanced-options")
        
        super.init()
    }
    
    //Check if downloadable.
    func checkDownloadPossibility(bucket: String, key: String, completion: @escaping (Bool) -> Void) {
        let s3 = AWSS3.default()
        
        let getObjectRequest = AWSS3GetObjectRequest()
        getObjectRequest?.bucket = bucket
        getObjectRequest?.key = key
        
        s3.getObject(getObjectRequest!).continueWith { (task: AWSTask<AWSS3GetObjectOutput>) -> AnyObject? in
            if let error = task.error as NSError? {
                if error.domain == AWSS3ErrorDomain && AWSS3ErrorType(rawValue: error.code) == .noSuchKey {
                    print("File not found in S3 bucket")
                    completion(false)
                } else {
                    print("Error checking for file: \(error)")
                    completion(false)
                }
            } else {
                print("File found in S3 bucket")
                completion(true)
            }
            return nil
        }
    }
    
    func multipartUpload(filePath: URL, bucketName: String
                         , prefixKey: String
                         , forceKey: Bool=false
                         , completeHandler:@escaping(Error?)->Void
                         , progressHandler:((Double)->Void)?=nil) -> Void
    {
        let expression = AWSS3TransferUtilityMultiPartUploadExpression()
              expression.progressBlock = {(task, progress) in
                  DispatchQueue.main.async(execute: {
                      // Do something e.g. Update a progress bar.
                      progressHandler?(progress.fractionCompleted)
                  })
                  print("progress value=>", progress.fractionCompleted)   //2
                  if progress.isFinished {           //3
                    print("Upload Finished...")
                    //do any task here.
                      
                  }
           }

           var completionHandler: AWSS3TransferUtilityMultiPartUploadCompletionHandlerBlock
           completionHandler = { (task, error) -> Void in
              DispatchQueue.main.async(execute: {
                 // Do something e.g. Alert a user for transfer completion.
                 // On failed uploads, `error` contains the error object.
                  completeHandler(error)
              })
           }

        let transferUtility = self.transferUtility//AWSS3TransferUtility.default()

        var targetKey = prefixKey
        if( !forceKey ) {targetKey = String("\(prefixKey)\(filePath.lastPathComponent)")}
        transferUtility.uploadUsingMultiPart(fileURL: filePath, bucket: bucketName, key: targetKey, contentType: self.contentType,
                expression: expression,
                completionHandler: completionHandler).continueWith {
               (task) -> AnyObject? in
                       if let error = task.error {
                           print("Error: \(error.localizedDescription)")
                           //completeHandler(error)
                       }

                       if let _ = task.result {
                          // Do something with uploadTask.
                       }
                       return nil;
               }
    }
    
    func upload(filePath: URL, bucketName: String) -> Void
    {
        let expression  = AWSS3TransferUtilityUploadExpression()
        expression.progressBlock = { (task: AWSS3TransferUtilityTask,progress: Progress) -> Void in
          print(progress.fractionCompleted)   //2
          if progress.isFinished{           //3
            print("Upload Finished...")
            //do any task here.
          }
        }
        
        expression.setValue("public-read-write", forRequestHeader: "x-amz-acl")   //4
        expression.setValue("public-read-write", forRequestParameter: "x-amz-acl")
        
        //5
        AWSS3TransferUtility.default().uploadFile(filePath, bucket: bucketName, key: String(filePath.lastPathComponent), contentType: self.contentType, expression: expression) { (task:AWSS3TransferUtilityUploadTask, err:Error?) -> Void in
            if(err != nil){
                print("Failure uploading file")
                
            }else{
                print("Success uploading file")
            }
        }
        .continueWith(block: { (task:AWSTask) -> AnyObject? in
            if(task.error != nil){
                print("Error uploading file: \(String(describing: task.error?.localizedDescription))")
            }
            if(task.result != nil){
                print("Starting upload...")
            }
            return nil
        })
    }
    
    func uploadImage(filePath: URL, bucketName: String, prefix: String, completeHandler:@escaping((Error?)->Void)) -> Void
    {
        let expression  = AWSS3TransferUtilityUploadExpression()
        expression.progressBlock = { (task: AWSS3TransferUtilityTask,progress: Progress) -> Void in
          print(progress.fractionCompleted)   //2
          if progress.isFinished{           //3
            print("Upload Finished...")
            //do any task here.
          }
        }
        
        expression.setValue("public-read-write", forRequestHeader: "x-amz-acl")   //4
        expression.setValue("public-read-write", forRequestParameter: "x-amz-acl")
        
        //5
        AWSS3TransferUtility.default().uploadFile(filePath, bucket: bucketName, key: "\(prefix)/\(String(filePath.lastPathComponent))", contentType:  "image/jpeg", expression: expression) { (task:AWSS3TransferUtilityUploadTask, err:Error?) -> Void in
            if(err != nil){
                print("Failure uploading file")
                
            }else{
                print("Success uploading file")
                completeHandler(nil)
            }
        }
        .continueWith(block: { (task:AWSTask) -> AnyObject? in
            if(task.error != nil){
                print("Error uploading file: \(String(describing: task.error?.localizedDescription))")
            }
            if(task.result != nil){
                print("Starting upload...")
            }
            return nil
        })
    }
    
    func uploadVideo(filePath: URL, bucketName: String, prefix: String, completeHandler:@escaping((Error?)->Void)) -> Void
    {
        let expression  = AWSS3TransferUtilityUploadExpression()
        expression.progressBlock = { (task: AWSS3TransferUtilityTask,progress: Progress) -> Void in
          print(progress.fractionCompleted)   //2
          if progress.isFinished{           //3
            print("Upload Finished...")
            //do any task here.
          }
        }
        
        expression.setValue("public-read-write", forRequestHeader: "x-amz-acl")   //4
        expression.setValue("public-read-write", forRequestParameter: "x-amz-acl")
        
        //5
        AWSS3TransferUtility.default().uploadFile(filePath, bucket: bucketName, key: "intro-video/\(prefix)/\(String(filePath.lastPathComponent))", contentType: self.contentType, expression: expression) { (task:AWSS3TransferUtilityUploadTask, err:Error?) -> Void in
            if(err != nil){
                print("Failure uploading file")
                
            }else{
                print("Success uploading file")
                completeHandler(nil)
            }
        }
        .continueWith(block: { (task:AWSTask) -> AnyObject? in
            if(task.error != nil){
                print("Error uploading file: \(String(describing: task.error?.localizedDescription))")
            }
            if(task.result != nil){
                print("Starting upload...")
            }
            return nil
        })
    }
    
    func uploadScript(filePath: URL, bucketName: String, prefix: String, completeHandler:@escaping((Error?)->Void)) -> Void
    {
        let expression  = AWSS3TransferUtilityUploadExpression()
        expression.progressBlock = { (task: AWSS3TransferUtilityTask,progress: Progress) -> Void in
          print(progress.fractionCompleted)   //2
          if progress.isFinished{           //3
            print("Upload Finished...")
            //do any task here.
          }
        }
        
        expression.setValue("public-read-write", forRequestHeader: "x-amz-acl")   //4
        expression.setValue("public-read-write", forRequestParameter: "x-amz-acl")
        
        //5
        AWSS3TransferUtility.default().uploadFile(filePath, bucket: bucketName, key: "\(prefix)/\(String(filePath.lastPathComponent))", contentType: "application/pdf", expression: expression) { (task:AWSS3TransferUtilityUploadTask, err:Error?) -> Void in
            if(err != nil){
                print("Failure uploading file")
                
            }else{
                print("Success uploading file")
                completeHandler(nil)
            }
        }
        .continueWith(block: { (task:AWSTask) -> AnyObject? in
            if(task.error != nil){
                print("Error uploading file: \(String(describing: task.error?.localizedDescription))")
            }
            if(task.result != nil){
                print("Starting upload...")
            }
            return nil
        })
    }
    
    func download(filePath: URL, bucketName: String,  key: String, completeHandler:@escaping((Error?)->Void)) -> Void
    {
        let expression = AWSS3TransferUtilityDownloadExpression()
        expression.progressBlock = {(task, progress) in
            DispatchQueue.main.async(execute: {
                // Do something e.g. Update a progress bar.
                print("progress \(progress)")
            })
            print(progress.fractionCompleted)   //2
            if progress.isFinished {           //3
                print("Download Finished...")
                //do any task here.
            }
        }
        
        var completionHandler: AWSS3TransferUtilityDownloadCompletionHandlerBlock
        completionHandler = { (task, location,  data,  error) -> Void in
           DispatchQueue.main.async(execute: {
              // Do something e.g. Alert a user for transfer completion.
              // On failed download, `error` contains the error object.
               completeHandler(error)
           })
        }

        //let transferUtility = self.transferUtility
        let transferUtility = AWSS3TransferUtility.default()
        transferUtility.download(to: filePath, bucket: bucketName, key: key, expression: expression, completionHandler: completionHandler).continueWith {
               (task) -> AnyObject? in
                       if let error = task.error {
                           print("Error: \(error.localizedDescription)")
                           completeHandler(error)
                       }

                       if let _ = task.result {
                          // Do something with uploadTask.
                       }
                       return nil;
               }
    }
    
    func downloadEx(filePath: URL, bucketName: String,  key: String, completeHandler:@escaping((Error?)->Void), progressHandler:((Float)->Void)? = nil) -> Void
    {
        let expression = AWSS3TransferUtilityDownloadExpression()
        expression.progressBlock = {(task, progress) in
            DispatchQueue.main.async(execute: {
                // Do something e.g. Update a progress bar.
                print("progress \(progress.fractionCompleted)")
                progressHandler?(Float(progress.fractionCompleted))
            })
            //print(progress.fractionCompleted)   //2
            if progress.isFinished {           //3
                print("Download Finished...")
                //do any task here.
            }
        }
        
        var completionHandler: AWSS3TransferUtilityDownloadCompletionHandlerBlock
        completionHandler = { (task, location,  data,  error) -> Void in
           DispatchQueue.main.async(execute: {
              // Do something e.g. Alert a user for transfer completion.
              // On failed download, `error` contains the error object.
               completeHandler(error)
           })
        }

        //let transferUtility = self.transferUtility
        let transferUtility = self.transferUtility
        transferUtility.download(to: filePath, bucket: bucketName, key: key, expression: expression, completionHandler: completionHandler).continueWith {
               (task) -> AnyObject? in
                       if let error = task.error {
                           print("Error: \(error.localizedDescription)")
                           completeHandler(error)
                       }

                       if let _ = task.result {
                          // Do something with uploadTask.
                       }
                       return nil;
               }
    }
    
    func cancelDownload(){
        let awsTask = transferUtility.getDownloadTasks()
        if let taskArray = awsTask.result {
            for idx in taskArray {
                if let task = idx as? AWSS3TransferUtilityDownloadTask {
                    task.cancel()
                }
            }
        }
    }
    
    func deleteFile(bucket: String, key: String?){
        guard let _=key else{
            return
        }

        let s3 = AWSS3.default()
        guard let deleteObjectRequest = AWSS3DeleteObjectRequest() else {
            return
        }
        deleteObjectRequest.bucket = bucket
        deleteObjectRequest.key = key
        s3.deleteObject(deleteObjectRequest).continueWith { (task:AWSTask) -> AnyObject? in
            if let error = task.error {
                print("Error occurred: \(error)")
                return nil
            }
            print("Deleted successfully.")
            return nil
        }
    }
}
