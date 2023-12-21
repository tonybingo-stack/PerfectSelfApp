//
//  IDFileManager.h
//  VideoCaptureDemo
//
//  Created by Adriaan Stellingwerff on 9/04/2015.
//  Copyright (c) 2015 Infoding. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CaptureFileSaveDelegate <NSObject>
- (void)captureFileSaveEvent:(NSURL *) assetURL;
@end

@interface IDFileManager : NSObject

@property (nonatomic, retain) id<CaptureFileSaveDelegate> delegate;

- (NSURL *) tempFileURL;
- (void) removeFile:(NSURL *)outputFileURL;
- (void) copyFileToDocuments:(NSURL *)fileURL;
- (void) copyFileToCameraRoll:(NSURL *)fileURL;
@end
