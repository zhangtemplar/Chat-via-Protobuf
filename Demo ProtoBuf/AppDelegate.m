//
//  AppDelegate.m
//  Demo ProtoBuf
//
//  Created by Qiang Zhang on 3/12/15.
//  Copyright (c) 2015 Qiang Zhang. All rights reserved.
//
#import "AppDelegate.h"
#import "GCDAsyncSocket.h"
#import "AppUtility.h"
#import "ChatViewController.h"
#import "MainViewController.h"
#import "App.pb.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
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
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
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
    [socket readDataWithTimeout:-1 tag:0];
    NSLog(@"Start reading data from socket");
}

// callback for getting data from socket
-(void)socket:(GCDAsyncSocket *)sender didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"Message is received at %@\n", [NSDate date]);
    
    // first assume we have all the data available
    while (buffer_index<5)
    {
        buffer[buffer_index]=((char *)data.bytes)[buffer_index];
        if (buffer[buffer_index]>=0)
        {
            int length=[[PBCodedInputStream streamWithData:[NSMutableData dataWithBytes:buffer length:buffer_index+1]] readRawVarint32];
            if (length<0)
            {
                // some error here, reject the whole package
                NSLog(@"Parse message header error in length: %d\n", length);
                buffer_index=0;
            }
            else
            {
                // we get the message header ready and read the message body
                NSLog(@"Message header with %d bytes parsed: %d\n", buffer_index, length);
                NSData *msg_body=[data subdataWithRange:NSMakeRange(buffer_index+1, length)];
                buffer_index=0;
                [self onReceiveLoginMessageResponse:msg_body];
            }
            return;
        }
        else
        {
            buffer_index++;
        }
    }
    // something is wrong here
    buffer_index=0;
}

-(void)onReceiveLoginMessageResponse:(NSData *)data
{
    //    Message_Builder *msg_tmp_builder=[Message builder];
    //    [msg_tmp_builder mergeFromCodedInputStream:[PBCodedInputStream streamWithData:[NSMutableData dataWithData:data]]];
    //    Message *msg_tmp=[msg_tmp_builder build];
    Message *msg_tmp=[Message parseFromCodedInputStream:[PBCodedInputStream streamWithData:[NSMutableData dataWithData:data]]];
    
    // check the response
    UIAlertView *alert=[UIAlertView alloc];
    if ([msg_tmp type]==Message_MessageTypeLoginResp && [[msg_tmp loginResponse] hasStatus])
    {
        switch ([[msg_tmp loginResponse] status]) {
            case 0:
            {
                // login succeed
                [alert initWithTitle:@"Login succeeds" message:@"You are now loggied in" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                // show the friend list
                UIStoryboard* story_board=[self getStoryBoard];
                MainViewController* main_view_controller=[story_board instantiateViewControllerWithIdentifier:@"mainViewController"];
                UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:main_view_controller];
                [[[self window] rootViewController] presentViewController:nc animated:YES completion:nil];
                break;
            }
            case 1:
            {
                // login failed, as user doesn't exist
                [alert initWithTitle:@"Username doesn't exist" message:@"Sorry but your username doesn't exists, register it?" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                break;
            }
            case 2:
            {
                // login succeed, as password is wrong
                [alert initWithTitle:@"Password is wrong" message:@"You input a wrong password, please check." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                break;
            }
            default:
            {
                [alert initWithTitle:@"Login fails with unknown error" message:@"Sorry your login fails due to some unknown error" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                break;
            }
        }
    }
    else if([msg_tmp type]==Message_MessageTypeSubscribeResp && [[msg_tmp subResponse] hasStatus])
    {
        switch ([[msg_tmp subResponse] status]) {
            case 0:
            {
                // login succeed
                [alert initWithTitle:@"Register succeeds" message:@"You are now register" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                break;
            }
            default:
            {
                // login failed, as user doesn't exist
                [alert initWithTitle:@"Register failed" message:@"Sorry but your username (email/phone) was already registerred, try to reset the password?" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                break;
            }
        }
    }
    else if ([msg_tmp type]==Message_MessageTypeForgetPwdResp && [[msg_tmp forgetPwdResponse] hasStatus])
    {
        switch ([[msg_tmp subResponse] status]) {
            case 0:
            {
                // login succeed
                [alert initWithTitle:@"Forget password request is approved." message:@"Please check your email or sms to find out the new password" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                break;
            }
            default:
            {
                // login failed, as user doesn't exist
                [alert initWithTitle:@"Forget password request is declined" message:@"Sorry but your username doesn't exists, register it?" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                break;
            }
        }
    }
    // send message response
    else if ([msg_tmp type]==Message_MessageTypeTextResp && [[msg_tmp textChatMessageResponse] hasStatus])
    {
        NSLog(@"Message sent confirmed with status: %d\n", [[msg_tmp textChatMessageResponse] status]);
    }
    // receving a new chat message
    else if ([msg_tmp type]==Message_MessageTypeTextFromServerReq)
    {
        // on get a new message, we create a new chat view
        ChatViewController *chat_view=[chat_list objectForKey:[[msg_tmp textFromServerRequest] toUserId]];
        if (chat_view==nil)
        {
            // if we don't have a chat view for it, create a new one
            chat_view=[ChatViewController messagesViewController];
            chat_view.delegateModal=self;
            [chat_view setUser:[[msg_tmp textFromServerRequest]toUserId] user_name:nil client_id: [[msg_tmp textFromServerRequest] fromUserId] guest_name:nil];
            [chat_list setObject:[[msg_tmp textFromServerRequest] toUserId] forKey:chat_view];
        }
        [chat_view onReceiveMessage:[msg_tmp textFromServerRequest]];
        // if current view is not present, show it
        if ([[self window] rootViewController]==chat_view)
        {
            UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:chat_view];
            [[[self window] rootViewController] presentViewController:nc animated:YES completion:nil];
        }
    }
    // for other message type put here
    else
    {
        [alert initWithTitle:@"System error" message:@"Sorry there is some error but it is not fault." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    }
    [alert show];
}

-(void) sendMessage:(Message *)msg
{
    NSData *msg_data=packMessage(msg);
    [socket writeData:msg_data withTimeout:-1 tag:1];
}

-(NSMutableDictionary *)getChatList
{
    return chat_list;
}

-(UIStoryboard *)getStoryBoard
{
    return [UIStoryboard storyboardWithName:@"Main" bundle:nil];
}

@end
