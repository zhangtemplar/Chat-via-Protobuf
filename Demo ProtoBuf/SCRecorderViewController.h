//
//  VRViewController.h
//  VideoRecorder
//
//  Created by Simon CORSIN on 8/3/13.
//  Copyright (c) 2013 rFlex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCRecorder.h"
@class ChatViewController;

@interface SCRecorderViewController : UIViewController<SCRecorderDelegate>
{
    ChatViewController* chat_view;
}

@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet UILabel *timeRecordedLabel;
@property (weak, nonatomic) IBOutlet UIButton *reverseCamera;
@property (weak, nonatomic) IBOutlet UIButton *flashModeButton;

- (IBAction)switchCameraMode:(id)sender;
- (IBAction)switchFlash:(id)sender;
- (IBAction)startRecord:(id)sender;
- (IBAction)stopRecord:(id)sender;
- (IBAction)cancelRecord:(id)sender;

@end
