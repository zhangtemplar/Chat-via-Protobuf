//
//  SCAudioRecordViewController.h
//  SCAudioVideoRecorder
//
//  Created by Simon CORSIN on 18/12/13.
//  Copyright (c) 2013 rFlex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCRecorder.h"
@class ChatViewController;

@interface SCAudioRecordViewController : UIViewController<SCRecorderDelegate, SCPlayerDelegate>
{
    ChatViewController* chat_view;
    NSTimer *timer;
}

@property (strong, nonatomic) IBOutlet UIButton *stopRecordingButton;
@property (strong, nonatomic) IBOutlet UIButton *recordButton;
@property (strong, nonatomic) IBOutlet UILabel *recordTimeLabel;
@property (strong, nonatomic) IBOutlet UIButton *deleteButton;

- (IBAction)recordPressed:(id)sender;
- (IBAction)stopRecordPressed:(id)sender;
- (IBAction)deletePressed:(id)sender;
-(void) setChatView:(ChatViewController *)view;
- (void)updateRecordTimeLabel:(NSTimer *)timer;
@end
