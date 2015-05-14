//
//  AppDelegate.h
//  Demo ProtoBuf
//
//  Created by Qiang Zhang on 3/12/15.
//  Copyright (c) 2015 Qiang Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Message;
@class GCDAsyncSocket;
@class MainViewController;
@class ChatViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    // socket for log in etc
    GCDAsyncSocket *socket;
    // socket for chat
    GCDAsyncSocket *socket_chat;
    
    // buffer for the message header
    char buffer[5];
    int buffer_index;
    
    MainViewController *main_view;
    
    UIStoryboard *story_board;
}
@property (strong, nonatomic) UIWindow *window;

// on receiving the message
-(void)onReceiveLoginMessageResponse:(NSData *)data;

// send messsage
-(void)sendMessage:(Message *)msg;

// get story board
-(UIStoryboard *)getStoryBoard;

// get main view chontroler
-(MainViewController *)getMainView;

@end

