//
//  MainViewController.h
//  Demo ProtoBuf
//
//  Created by Qiang Zhang on 4/1/15.
//  Copyright (c) 2015 Qiang Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Message;

@interface MainViewController : UIViewController
{
    IBOutlet UITextField* input_friend_id;
    
    Message* login_user;
}

-(IBAction)onChat:(id)sender;
-(void) SetUser:(Message *)user;
@end
