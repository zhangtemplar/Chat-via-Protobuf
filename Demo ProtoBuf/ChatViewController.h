//
//  ChatViewController.h
//  Demo ProtoBuf
//
//  Created by Qiang Zhang on 3/29/15.
//  Copyright (c) 2015 Qiang Zhang. All rights reserved.
//
@class ChatModelData;
@class JSQMessagesViewController;
@class ChatViewController;
@class Message;
@class AppDelegate;

@protocol JSQChatViewControllerDelegate <NSObject>

- (void)didDismissJSQChatViewController:(ChatViewController *)vc;

@end

@interface ChatViewController : JSQMessagesViewController <UIActionSheetDelegate>
{
    Message *login_user;
    // app delegate for socket operation and many more
    AppDelegate *app_delegate;
    // guest
    NSMutableArray *guest_id;
}
@property (weak, nonatomic) id<JSQChatViewControllerDelegate> delegateModal;

// the message queue
@property (strong, nonatomic) ChatModelData *chatData;

- (void)receiveMessagePressed:(UIBarButtonItem *)sender;

- (void)closePressed:(UIBarButtonItem *)sender;

-(void) setUser:(Message *)user;

-(void) onReceiveMessage:(Message *)msg;
@end
