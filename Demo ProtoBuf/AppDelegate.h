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

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    // socket
    GCDAsyncSocket *socket;
    
    // buffer for the message header
    char buffer[5];
    int buffer_index;
    
    // hash table for chat view
    NSMutableDictionary* chat_list;
}
@property (strong, nonatomic) UIWindow *window;

// on receiving the message
-(void)onReceiveLoginMessageResponse:(NSData *)data;

// send messsage
-(void)sendMessage:(Message *)msg;
@end

