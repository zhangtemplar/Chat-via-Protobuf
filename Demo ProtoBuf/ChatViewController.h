//
//  ChatViewController.h
//  Demo ProtoBuf
//
//  Created by Qiang Zhang on 3/29/15.
//  Copyright (c) 2015 Qiang Zhang. All rights reserved.
//
#import "JSQMessages.h"
#import "AppDelegate.h"
@class ChatModelData;
@class JSQMessagesViewController;
@class ChatViewController;
@class AppDelegate;
@class ChatViewController;
@class Message_TextFromServerRequest;
@class Message_VideoFromServerRequest;
@class Message_VoiceFromServerRequest;
@class Message_PictureFromServerRequest;
@class Message_TextFromServerChatRoomRequest;
@class Message_VideoFromServerChatRoomRequest;
@class Message_VoiceFromServerChatRoomRequest;
@class Message_PictureFromServerChatRoomRequest;
@protocol JSQChatViewControllerDelegate <NSObject>

- (void)didDismissJSQChatViewController:(ChatViewController *)vc;

@end

@interface ChatViewController : JSQMessagesViewController <UIActionSheetDelegate>
{
    // app delegate for socket operation and many more
    AppDelegate *app_delegate;
    // guest
    NSMutableArray *guest_list;
}
@property (weak, nonatomic) id<JSQChatViewControllerDelegate> delegate_modal;

// the message queue
@property (strong, nonatomic) ChatModelData *chat_data;

// the chat mode, TRUE for two user mode
@property BOOL chat_mode;

// mimicking receiving a new message
- (void)receiveMessagePressed:(UIBarButtonItem *)sender;

// close current chat
- (void)closePressed:(UIBarButtonItem *)sender;

// initialize the chat with user and guest
-(void) initWithUser:(NSString *)user_id user_name:(NSString *)user_name guest_id:(NSString *)client_id guest_name:(NSString *)guest_name;

#pragma mark for two user chat
// receive a text message
-(void) onReceiveTextMessage:(Message_TextFromServerRequest *)msg;

// video message
-(void) onReceiveVideoMessage:(Message_VideoFromServerRequest *)msg;

// photo message
-(void) onReceivePhotoMessage:(Message_PictureFromServerRequest *)msg;

// voice
-(void) onReceiveVoiceMessage:(Message_VoiceFromServerRequest *)msg;

# pragma mark for multiple user chat
// receive a text message
-(void) onReceiveChatRoomTextMessage:(Message_TextFromServerChatRoomRequest *)msg;
/*
// video message
-(void) onReceiveChatRoomVideoMessage:(Message_VideoFromServerChatRoomRequest *)msg;

// photo message
-(void) onReceiveChatRoomPhotoMessage:(Message_PictureFromServerChatRoomRequest *)msg;

// voice
-(void) onReceiveChatRoomVoiceMessage:(Message_VoiceFromServerChatRoomRequest *)msg;
*/
// voice and audio
-(void) onAudioCaptured:(NSURL *)url;
-(void) onVideoCaptured:(NSURL *)url;
@end
