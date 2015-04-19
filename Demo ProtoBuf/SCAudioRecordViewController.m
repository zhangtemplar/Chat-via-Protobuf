//
//  SCAudioRecordViewController.m
//  SCAudioVideoRecorder
//
//  Created by Simon CORSIN on 18/12/13.
//  Copyright (c) 2013 rFlex. All rights reserved.
//

#import "SCAudioRecordViewController.h"
#import "ChatViewController.h";

@interface SCAudioRecordViewController () {
    SCRecorder *_recorder;
    SCRecordSession *_recordSession;
}
@end

@implementation SCAudioRecordViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _recorder = [SCRecorder recorder];
    _recorder.delegate = self;
    _recorder.photoConfiguration.enabled = NO;
    _recorder.videoConfiguration.enabled = NO;
    
    NSError *error;
    if (![_recorder prepare:&error]) {
        [self showError:error];
    }
    
    [self createSession];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [_recorder startRunning];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [_recorder stopRunning];
}

- (void)showError:(NSError*)error {
      [[[UIAlertView alloc] initWithTitle:@"Something went wrong" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

- (void)createSession {
    SCRecordSession *session = [SCRecordSession recordSession];
    session.fileType = AVFileTypeAppleM4A;
    
    _recorder.session = session;
}

- (void)updateRecordTimeLabel:(NSTimer *)timer {
    self.recordTimeLabel.text = [NSString stringWithFormat:@"%.2fs", [[timer fireDate] timeIntervalSinceDate:[timer userInfo]]];
}

- (IBAction)recordPressed:(id)sender {
    [_recorder record];
    timer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(updateRecordTimeLabel:) userInfo:[NSDate date] repeats:YES];
}

// save the recorder
- (IBAction)stopRecordPressed:(id)sender {
    [timer invalidate];
    [_recorder pause:^{
         [_recorder.session mergeSegmentsUsingPreset:AVAssetExportPresetAppleM4A completionHandler:^(NSURL *url, NSError *error)
          {
              if (error==nil)
              {
                  // add this audio the message
                  NSLog(@"Audio recording succeed\n");
                  [chat_view onAudioCaptured:url];
              }
              else
              {
                  NSLog(@"Audio recording failed %@\n", error);
              }
          }];
         [self dismissViewControllerAnimated:YES completion:nil];
     }];
}

// cancel the recorder
- (IBAction)deletePressed:(id)sender {
    NSLog(@"Audio recording cancel\n");
    [timer invalidate];
    [_recorder pause];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) setChatView:(ChatViewController *)view
{
    chat_view=view;
}
@end
