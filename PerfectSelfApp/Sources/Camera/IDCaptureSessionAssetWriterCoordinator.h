//
//  IDCaptureSessionAssetWriterCoordinator.h
//  VideoCaptureDemo
//
//  Created by Adriaan Stellingwerff on 9/04/2015.
//  Copyright (c) 2015 Infoding. All rights reserved.
//

#import "IDCaptureSessionCoordinator.h"
#import<CoreImage/CIImage.h>
@class ImageChromaResultView;
@protocol IDCaptureSessionAssetWriterCoordinatorDelegate;

@interface IDCaptureSessionAssetWriterCoordinator : IDCaptureSessionCoordinator
@property (nonatomic, strong) ImageChromaResultView *cameraFilterPreview;

//- (void)setFilterHandler:((CIImageRef) (^)(CIImageRef)) handler;
- (void)setFilterHandler:(CIImage* (^)(CIImage*)) handler;
@end