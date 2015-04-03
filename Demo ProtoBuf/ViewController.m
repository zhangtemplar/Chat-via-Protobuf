//
//  ViewController.m
//  Demo ProtoBuf
//
//  Created by Qiang Zhang on 3/12/15.
//  Copyright (c) 2015 Qiang Zhang. All rights reserved.
//
#import "ViewController.h"
#import "AppDelegate.h"
#import "App.pb.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    app_delegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)onCancel:(id)sender
{
    input_username.text=@"your username here";
    input_email.text=@"your email here";
    input_phone.text=@"your phone here";
    input_password.text=@"your password here";
    input_password2.text=@"your password again";
    
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Request is canceled" message:@"Your request is canceled and the input is reset" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

-(IBAction)onForget:(id)sender
{
    Message_ForgetPasswordMessageRequest_Builder *msg_tmp_forget_build=[Message_ForgetPasswordMessageRequest builder];
    [msg_tmp_forget_build setPhoneNumber:input_phone.text];
    [msg_tmp_forget_build setEmail:input_email.text];
    
    Message_Builder *msg_tmp_build=[Message builder];
    [msg_tmp_build setType:Message_MessageTypeForgetPwdReq];
    [msg_tmp_build setForgetPwdRequest:[msg_tmp_forget_build build]];
    
    [app_delegate sendMessage:[msg_tmp_build build]];
}

-(IBAction)onLogin:(id)sender
{
    // create message
    Message_LoginMessageRequest_Builder *msg_tmp_login_build=[Message_LoginMessageRequest builder];
    [msg_tmp_login_build setPhoneNumber:input_phone.text];
    [msg_tmp_login_build setEmail:input_email.text];
    [msg_tmp_login_build setPassword:input_password.text];
    
    Message_Builder *msg_tmp_build=[Message builder];
    [msg_tmp_build setType:Message_MessageTypeLoginReq];
    [msg_tmp_build setLoginRequest:msg_tmp_login_build.build];
    
    // send the message to the socket: we need to code the stream first
    [app_delegate sendMessage:[msg_tmp_build build]];
}

-(IBAction)onRegister:(id)sender
{
    Message_SubMessageRequest_Builder *msg_tmp_register_build=[Message_SubMessageRequest builder];
    [msg_tmp_register_build setPhoneNumber:input_phone.text];
    [msg_tmp_register_build setEmail:input_email.text];
    [msg_tmp_register_build setPassword:input_password.text];
    [msg_tmp_register_build setSex:0];
    
    Message_Builder *msg_tmp_build=[Message builder];
    [msg_tmp_build setType:Message_MessageTypeSubscribeReq];
    [msg_tmp_build setSubRequest:msg_tmp_register_build.build];
    
    // send the message to the socket: we need to code the stream first
    [app_delegate sendMessage:[msg_tmp_build build]];
}

@end
