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

- (void)receiveMessagePressed:(UIBarButtonItem *)sender;

- (void)closePressed:(UIBarButtonItem *)sender;

-(void) setUser:(NSString *)user_id user_name:(NSString *)user_name client_id:(NSString *)client_id guest_name:(NSString *)guest_name;

-(void) onReceiveMessage:(Message_TextFromServerRequest *)msg;
@end
