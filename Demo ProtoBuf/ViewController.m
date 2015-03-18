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
    buffer_index=0;
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
    Message_ForgetPasswordMessageRequest_Builder *msg_tmp_forget_build=[Message_ForgetPasswordMessageRequest builder];
    [msg_tmp_forget_build setPhoneNumber:input_phone.text];
    [msg_tmp_forget_build setEmail:input_email.text];
    
    Message_Builder *msg_tmp_build=[Message builder];
    [msg_tmp_build setType:Message_MessageTypeForgetPwdReq];
    [msg_tmp_build setForgetPwdRequest:[msg_tmp_forget_build build]];
    
    NSData *msg_data=packMessage([msg_tmp_build build]);
    [socket writeData:msg_data withTimeout:-1 tag:1];
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
    Message_SubMessageRequest_Builder *msg_tmp_register_build=[Message_SubMessageRequest builder];
    [msg_tmp_register_build setPhoneNumber:input_phone.text];
    [msg_tmp_register_build setEmail:input_email.text];
    [msg_tmp_register_build setPassword:input_password.text];
    [msg_tmp_register_build setSex:0];
    
    Message_Builder *msg_tmp_build=[Message builder];
    [msg_tmp_build setType:Message_MessageTypeSubscribeReq];
    [msg_tmp_build setSubRequest:msg_tmp_register_build.build];
    
    // send the message to the socket: we need to code the stream first
    NSData *msg_data=packMessage([msg_tmp_build build]);
    [socket writeData:msg_data withTimeout:-1 tag:1];
}

// callback function for socket connection
-(void)socket:(GCDAsyncSocket *)sender didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSLog([[NSString alloc] initWithFormat:@"Connected to %@:%u.\n", host, port]);
    
    // start listening for imcoming data
//    [socket readDataWithTimeout:-1 tag:MESSAGE_HEAD];
//    NSLog(@"Start reading data from socket");
}

// callback for writting data to socket
-(void)socket:(GCDAsyncSocket*)sender didWriteDataWithTag:(long)tag
{
    NSLog(@"Message is sent at %@\n", [NSDate date]);
    
    // start listening for imcoming data
    [socket readDataWithTimeout:-1 tag:MESSAGE_HEAD];
    NSLog(@"Start reading data from socket");
}

// callback for getting data from socket
-(void)socket:(GCDAsyncSocket *)sender didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"Message is received at %@\n", [NSDate date]);
    // [self onReceiveLoginMessageResponse:data];
    
    if (tag!=MESSAGE_BODY)
    {
        // read the available byte
        buffer[buffer_index]=((char *)data.bytes)[0];
        // the header can take 5 bytes at most and the last byte must be nonegative
        if (buffer[buffer_index]>=0)
        {
            // the header is finished, parse the message header to obtain the length of the buffer
            int length=[[PBCodedInputStream streamWithData:[NSMutableData dataWithBytes:buffer length:buffer_index+1]] readRawVarint32];
            if (length<0)
            {
                // some error here
                NSLog(@"Parse message header error in length: %d\n", length);
                buffer_index=0;
//                [socket readDataWithTimeout:-1 tag:MESSAGE_HEAD];
            }
            else
            {
                // read the message body
                NSLog(@"Message header with %d bytes parsed: %d\n", buffer_index, length);
                buffer_index=0;
                [socket readDataToLength:length withTimeout:-1 tag:MESSAGE_BODY];
            }
        }
        else
        {
            buffer_index++;
            if (buffer_index<5)
            {
                // the head is not finished yet, read one more byte
                NSLog(@"Message header is not complete and read one more byte: %d\n", buffer_index);
                [socket readDataWithTimeout:-1 tag:MESSAGE_HEAD];
            }
            else
            {
                NSLog(@"Parse message header error with %d bytes\n", buffer_index);
                buffer_index=0;
//                [socket readDataWithTimeout:-1 tag:MESSAGE_HEAD];
            }
        }
    }
    else
    {
        // it is a message body
        NSLog(@"Message body with %lu byte is read\n", (unsigned long)[data length]);
        [self onReceiveLoginMessageResponse:data];
//        [socket readDataWithTimeout:-1 tag:MESSAGE_HEAD];
    }
}

-(void)onReceiveLoginMessageResponse:(NSData *)data
{
    Message *msg_tmp=[Message parseFromCodedInputStream:[PBCodedInputStream streamWithData:[NSMutableData dataWithData:data]]];
    
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
