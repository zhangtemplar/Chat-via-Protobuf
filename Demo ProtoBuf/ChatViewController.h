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
@class Message_TextFromServerRequest;
@class AppDelegate;
@class ChatViewController;
@class Message_VideoFromServerRequest;
@class Message_VoiceFromServerRequest;
@class Message_PictureFromServerRequest;
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
@property (weak, nonatomic) id<JSQChatViewControllerDelegate> delegateModal;

// the message queue
@property (strong, nonatomic) ChatModelData *chatData;

// mimicking receiving a new message
- (void)receiveMessagePressed:(UIBarButtonItem *)sender;

// close current chat
- (void)closePressed:(UIBarButtonItem *)sender;

// initialize the chat with user and guest
-(void) initWithUser:(NSString *)user_id user_name:(NSString *)user_name guest_id:(NSString *)client_id guest_name:(NSString *)guest_name;

// receive a text message
-(void) onReceiveTextMessage:(Message_TextFromServerRequest *)msg;

// video message
-(void) onReceiveVideoMessage:(Message_VideoFromServerRequest *)msg;

// photo message
-(void) onReceivePhotoMessage:(Message_PictureFromServerRequest *)msg;

// voice
-(void) onReceiveVoiceMessage:(Message_VoiceFromServerRequest *)msg;
@end
