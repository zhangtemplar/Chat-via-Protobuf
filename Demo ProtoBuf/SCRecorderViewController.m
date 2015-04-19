//
//  VRViewController.m
//  VideoRecorder
//
//  Created by Simon CORSIN on 8/3/13.
//  Copyright (c) 2013 SCorsin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "SCRecorderViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "ChatViewController.h"

#define kVideoPreset AVCaptureSessionPresetHigh

////////////////////////////////////////////////////////////
// PRIVATE DEFINITION
/////////////////////

@interface SCRecorderViewController () {
    SCRecorder *_recorder;
    SCRecordSession *_recordSession;
}

@property (strong, nonatomic) SCRecorderToolsView *focusView;
@end

////////////////////////////////////////////////////////////
// IMPLEMENTATION
/////////////////////

@implementation SCRecorderViewController

#pragma mark - UIViewController 

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0

- (UIStatusBarStyle) preferredStatusBarStyle {
	return UIStatusBarStyleLightContent;
}

#endif

#pragma mark - Left cycle

- (void)viewDidLoad {
    [super viewDidLoad];

    _recorder = [SCRecorder recorder];
    _recorder.captureSessionPreset = [SCRecorderTools bestCaptureSessionPresetCompatibleWithAllDevices];
    _recorder.maxRecordDuration = CMTimeMake(10, 1);
    
    _recorder.delegate = self;
    _recorder.autoSetVideoOrientation = YES;
    
    UIView *previewView = self.previewView;
    _recorder.previewView = self.previewView;
    
    self.focusView = [[SCRecorderToolsView alloc] initWithFrame:previewView.bounds];
    self.focusView.recorder = _recorder;
    [previewView addSubview:self.focusView];
    
    self.focusView.outsideFocusTargetImage = [UIImage imageNamed:@"capture_flip"];
    self.focusView.insideFocusTargetImage = [UIImage imageNamed:@"capture_flip"];

    _recorder.initializeSessionLazily = NO;
    
    NSError *error;
    if (![_recorder prepare:&error]) {
        NSLog(@"Prepare error: %@", error.localizedDescription);
    }
}

- (void)recorder:(SCRecorder *)recorder didSkipVideoSampleBufferInSession:(SCRecordSession *)recordSession {
    NSLog(@"Skipped video buffer");
}

- (void)recorder:(SCRecorder *)recorder didReconfigureAudioInput:(NSError *)audioInputError {
    NSLog(@"Reconfigured audio input: %@", audioInputError);
}

- (void)recorder:(SCRecorder *)recorder didReconfigureVideoInput:(NSError *)videoInputError {
    NSLog(@"Reconfigured video input: %@", videoInputError);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self prepareSession];
    
	self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [_recorder previewViewFrameChanged];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [_recorder startRunning];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [_recorder stopRunning];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    self.navigationController.navigationBarHidden = NO;
}

#pragma mark - Handle

- (void)showAlertViewWithTitle:(NSString*)title message:(NSString*) message {
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alertView show];
}

- (IBAction)switchCameraMode:(id)sender {
	[_recorder switchCaptureDevices];
}

- (IBAction)stopRecord:(id)sender {
    [_recorder pause:^{
        [_recorder.session mergeSegmentsUsingPreset:AVAssetExportPresetMediumQuality completionHandler:^(NSURL *url, NSError *error)
         {
             if (error==nil)
             {
                 // add this audio the message
                 NSLog(@"Video recording succeed\n");
                 [chat_view onVideoCaptured:url];
             }
             else
             {
                 NSLog(@"Video recording failed %@\n", error);
             }
         }];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (IBAction)startRecord:(id)sender
{
    [_recorder record];
}

- (IBAction)cancelRecord:(id)sender
{
    [_recorder pause];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)switchFlash:(id)sender {
    NSString *flashModeString = nil;
    if ([_recorder.captureSessionPreset isEqualToString:AVCaptureSessionPresetPhoto]) {
        switch (_recorder.flashMode) {
            case SCFlashModeAuto:
                flashModeString = @"Flash : Off";
                _recorder.flashMode = SCFlashModeOff;
                break;
            case SCFlashModeOff:
                flashModeString = @"Flash : On";
                _recorder.flashMode = SCFlashModeOn;
                break;
            case SCFlashModeOn:
                flashModeString = @"Flash : Light";
                _recorder.flashMode = SCFlashModeLight;
                break;
            case SCFlashModeLight:
                flashModeString = @"Flash : Auto";
                _recorder.flashMode = SCFlashModeAuto;
                break;
            default:
                break;
        }
    } else {
        switch (_recorder.flashMode) {
            case SCFlashModeOff:
                flashModeString = @"Flash : On";
                _recorder.flashMode = SCFlashModeLight;
                break;
            case SCFlashModeLight:
                flashModeString = @"Flash : Off";
                _recorder.flashMode = SCFlashModeOff;
                break;
            default:
                break;
        }
    }
    
    [self.flashModeButton setTitle:flashModeString forState:UIControlStateNormal];
}

- (void)prepareSession {
    if (_recorder.session == nil) {
        
        SCRecordSession *session = [SCRecordSession recordSession];
        session.fileType = AVFileTypeQuickTimeMovie;
        
        _recorder.session = session;
    }
    
    [self updateTimeRecordedLabel];
}

- (void)recorder:(SCRecorder *)recorder didCompleteSession:(SCRecordSession *)recordSession {
    [_recorder.session mergeSegmentsUsingPreset:AVAssetExportPresetMediumQuality completionHandler:^(NSURL *url, NSError *error)
     {
         if (error==nil)
         {
             // add this audio the message
             NSLog(@"Video recording succeed\n");
             [chat_view onVideoCaptured:url];
         }
         else
         {
             NSLog(@"Video recording failed %@\n", error);
         }
     }];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)recorder:(SCRecorder *)recorder didInitializeAudioInSession:(SCRecordSession *)recordSession error:(NSError *)error {
    if (error == nil) {
        NSLog(@"Initialized audio in record session");
    } else {
        NSLog(@"Failed to initialize audio in record session: %@", error.localizedDescription);
    }
}

- (void)recorder:(SCRecorder *)recorder didInitializeVideoInSession:(SCRecordSession *)recordSession error:(NSError *)error {
    if (error == nil) {
        NSLog(@"Initialized video in record session");
    } else {
        NSLog(@"Failed to initialize video in record session: %@", error.localizedDescription);
    }
}

- (void)recorder:(SCRecorder *)recorder didBeginSegmentInSession:(SCRecordSession *)recordSession error:(NSError *)error {
    NSLog(@"Began record segment: %@", error);
}

- (void)recorder:(SCRecorder *)recorder didCompleteSegment:(SCRecordSessionSegment *)segment inSession:(SCRecordSession *)recordSession error:(NSError *)error {
    NSLog(@"Completed record segment at %@: %@ (frameRate: %f)", segment.url, error, segment.frameRate);
}

- (void)updateTimeRecordedLabel {
    CMTime currentTime = kCMTimeZero;
    
    if (_recorder.session != nil) {
        currentTime = _recorder.session.duration;
    }
    
    self.timeRecordedLabel.text = [NSString stringWithFormat:@"%.2f sec", CMTimeGetSeconds(currentTime)];
}

- (void)recorder:(SCRecorder *)recorder didAppendVideoSampleBufferInSession:(SCRecordSession *)recordSession {
    [self updateTimeRecordedLabel];
}

-(void) setChatView:(ChatViewController *)view
{
    chat_view=view;
}
@end
