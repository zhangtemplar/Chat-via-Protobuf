//
//  ViewController.m
//  Demo ProtoBuf
//
//  Created by Qiang Zhang on 3/12/15.
//  Copyright (c) 2015 Qiang Zhang. All rights reserved.
//
#import "GCDAsyncSocket.h"
#import "ViewController.h"
#import "App.pb.h"
#import "AppUtility.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // creates the tcp connection
    socket=[[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError *err=nil;
    if (![socket connectToHost:@"52.11.221.183" onPort:8080 error:&err])
    {
        NSLog(@"The connection failes.\n");
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Unable to connect to the server" message:@"Unable to connect the server, please check your network" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
    // start listening for imcoming data
    [socket readDataWithTimeout:-1 tag:Message_MessageTypeLoginResp];
}

// view disappear, disconnect the socket
-(void)viewDidDisappear:(BOOL)animated
{
    [socket disconnect];
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
    NSData *msg_data=packMessage([msg_tmp_build build]);
    [socket writeData:msg_data withTimeout:-1 tag:1];
}

-(IBAction)onRegister:(id)sender
{
    // test the socket here
}

// callback function for socket connection
-(void)socket:(GCDAsyncSocket *)sender didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSLog([[NSString alloc] initWithFormat:@"Connected to %@:%u.\n", host, port]);
}

// callback for writting data to socket
-(void)socket:(GCDAsyncSocket*)sender didWriteDataWithTag:(long)tag
{
    NSLog(@"Message is sent at %@\n", [NSDate date]);
}

// callback for getting data from socket
-(void)socket:(GCDAsyncSocket *)sender didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"Message is received at %@\n", [NSDate date]);
}

-(void)onReceiveLoginMessageResponse:(NSData *)data
{
    Message *msg_tmp=unPackMessage(data);
    
    // check the response
    if ([msg_tmp type]==Message_MessageTypeLoginResp && [[msg_tmp loginResponse] hasStatus])
    {
        UIAlertView *alert=[UIAlertView alloc];
        switch ([[msg_tmp loginResponse] status]) {
            case 0:
                // login succeed
                [alert initWithTitle:@"Login succeeds" message:@"You are now loggied in" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                break;
            case 1:
                // login failed, as user doesn't exist
                [alert initWithTitle:@"Username doesn't exist" message:@"Sorry but your username doesn't exists, register it?" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            case 2:
                // login succeed, as password is wrong
                [alert initWithTitle:@"Password is wrong" message:@"You input a wrong password, please check." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            default:
                [alert initWithTitle:@"Login fails with unknown error" message:@"Sorry your login fails due to some unknown error" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                break;
        }
        [alert show];
    }
}
@end
