//
//  MainViewController.h
//  Demo ProtoBuf
//
//  Created by Qiang Zhang on 4/1/15.
//  Copyright (c) 2015 Qiang Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Message_LoginMessageResponse;
@class AppDelegate;
@class Message_WhoAmIResponse;

@interface MainViewController : UIViewController
{
    IBOutlet UITextField* input_friend_id;
    IBOutlet UITextField* input_who_am_i;
    
    Message_LoginMessageResponse* login_user;
    
    // app delegate for socket operation and many more
    AppDelegate *app_delegate;
}

-(IBAction)onChat:(id)sender;
-(void) SetUser:(Message_LoginMessageResponse *)user;
-(void) SetWhoAmI:(Message_WhoAmIResponse *)user;
@end
