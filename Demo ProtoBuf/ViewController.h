//
//  ViewController.h
//  Demo ProtoBuf
//
//  Created by Qiang Zhang on 3/12/15.
//  Copyright (c) 2015 Qiang Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AppDelegate;

@interface ViewController : UIViewController
{
    IBOutlet UITextField *input_username;
    IBOutlet UITextField *input_email;
    IBOutlet UITextField *input_phone;
    IBOutlet UITextField *input_password;
    IBOutlet UITextField *input_password2;
    
    AppDelegate* app_delegate;
    
}

-(IBAction)onCancel:(id)sender;
-(IBAction)onLogin:(id)sender;
-(IBAction)onRegister:(id)sender;
-(IBAction)onForget:(id)sender;

@end

#define MESSAGE_HEAD 0
#define MESSAGE_BODY 1