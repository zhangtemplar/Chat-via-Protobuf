//
//  MainViewController.h
//  Demo ProtoBuf
//
//  Created by Qiang Zhang on 4/1/15.
//  Copyright (c) 2015 Qiang Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Message_LoginMessageResponse;
@class AppDelegate;
@class Message_WhoAmIResponse;

@interface MainViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>
{
    IBOutlet UITextField* input_friend_id;
    
    Message_LoginMessageResponse* login_user;
    
    // app delegate for socket operation and many more
    AppDelegate *app_delegate;
    
    // hash table for chat view
    NSMutableDictionary* chat_list;
    
    // the counter for new message
    NSMutableDictionary* chat_new_message_count;
    
    // table showing the list of views
    IBOutlet UITableView* chat_table;
}

-(IBAction)onChat:(id)sender;
-(void) SetUser:(Message_LoginMessageResponse *)user;

// get chat list
-(ChatViewController *)getChatView:(NSString *)title;

// set chat list
-(void)setChatView:(NSString *)title view:(ChatViewController *)view;

// increase new message counter
-(void)increaseNewMessageCount:(NSString*)title;

// reset new message counter
-(void)resetNewMessageCount:(NSString*)title;

// get new message count
-(int)getNewMessageCount:(NSString *)title;
@end
