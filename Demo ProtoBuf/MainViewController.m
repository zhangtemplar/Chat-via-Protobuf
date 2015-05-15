//
//  MainViewController.m
//  Demo ProtoBuf
//
//  Created by Qiang Zhang on 4/1/15.
//  Copyright (c) 2015 Qiang Zhang. All rights reserved.
//

#import "AppDelegate.h"
#import "ChatViewController.h"
#import "MainViewController.h"
#import "App.pb.h"
#import "NSString+NSHash.h"
#import "NSData+NSHash.h"

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    app_delegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // send whoami request
    Message_WhoAmIRequest_Builder *who_msg_build=[Message_WhoAmIRequest builder];
    [who_msg_build setUserId:[login_user userId]];
    [who_msg_build setDate:[[NSDate date] timeIntervalSince1970]];
    [who_msg_build setLocation:@"Pasadena, CA, USA"];
    [who_msg_build setMessageHash:[@"" MD5]];
    
    Message_Builder *msg_build=[Message builder];
    [msg_build setType:Message_MessageTypeWhoAmIReq];
    [msg_build setWhoAmIrequest:[who_msg_build build]];
    
    chat_list=[[NSMutableDictionary alloc] init];
    chat_new_message_count=[[NSMutableDictionary alloc] init];
    
    [app_delegate sendMessage:[msg_build build]];
    
    [chat_table setDataSource:self];
    [chat_table setDelegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(IBAction)onChat:(id)sender
{
    NSString *guest_id=input_friend_id.text;
    ChatViewController *chat_view=[self getChatView:guest_id];
    if (chat_view==nil)
    {
        // if we don't have a chat view for it, create a new one
        chat_view=[ChatViewController messagesViewController];
        chat_view.delegate_modal=self;
        [chat_view initWithUser:[login_user userId] user_name:[login_user userName] guest_id: guest_id guest_name:nil];
        [self setChatView:guest_id view:chat_view];
    }
    // if current view is not present, show it
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:chat_view];
    [self presentViewController:nc animated:YES completion:nil];
}

// create chat room
-(IBAction)onCreate:(id)sender
{
    NSLog(@"Request to create a room\n");
    Message_CreateChatRoomRequest_Builder *msg_create_builder=[Message_CreateChatRoomRequest builder];
    [msg_create_builder setUserId:[login_user userId]];
    [msg_create_builder setRoomName:[input_room_name text]];
    [msg_create_builder setCategory:[input_room_name text]];
    [msg_create_builder setDescription:[input_room_name text]];
    [msg_create_builder setDate:[[NSDate date] timeIntervalSince1970]];
    
    Message_Builder *msg_builder=[Message builder];
    [msg_builder setType:Message_MessageTypeCreateChatRoomReq];
    [msg_builder setCreateChatRoomRequest:[msg_create_builder build]];
    
    [app_delegate sendMessage:[msg_builder build]];
}

// enter chat room
-(IBAction)onEnter:(id)sender
{
    NSLog(@"Request to enter a room\n");
    Message_JoinChatRoomRequest_Builder *msg_join_builder=[Message_JoinChatRoomRequest builder];
    [msg_join_builder setUserId:[login_user userId]];
    [msg_join_builder setChatRoomId:[input_room_id text]];
    
    Message_Builder *msg_builder=[Message builder];
    [msg_builder setType:Message_MessageTypeJoinChatRoomReq];
    [msg_builder setJoinChatRoomRequest:[msg_join_builder build]];
    
    [app_delegate sendMessage:[msg_builder build]];
}

// chat room is created
-(void)onRoom:(Message_CreateChatRoomResponse*)msg
{
    NSString *guest_id=[msg chatRoomUuid];
    ChatViewController *chat_view=[self getChatView:guest_id];
    if (chat_view==nil)
    {
        // if we don't have a chat view for it, create a new one
        chat_view=[ChatViewController messagesViewController];
        chat_view.delegate_modal=self;
        [chat_view initWithUser:[login_user userId] user_name:[login_user userName] guest_id: guest_id guest_name:nil];
        [self setChatView:guest_id view:chat_view];
    }
    // if current view is not present, show it
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:chat_view];
    [self presentViewController:nc animated:YES completion:nil];
}

// chat room is joined
-(void)onJoin:(Message_JoinChatRoomResponse*)msg
{
    NSString *guest_id=[[msg chatRoom] chatRoomId];
    ChatViewController *chat_view=[self getChatView:guest_id];
    if (chat_view==nil)
    {
        // if we don't have a chat view for it, create a new one
        chat_view=[ChatViewController messagesViewController];
        chat_view.delegate_modal=self;
        [chat_view initWithUser:[login_user userId] user_name:[login_user userName] guest_id: guest_id guest_name:[[msg chatRoom]chatRoomName]];
        [self setChatView:guest_id view:chat_view];
    }
    // if current view is not present, show it
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:chat_view];
    [self presentViewController:nc animated:YES completion:nil];
}


-(void) SetUser:(Message *)user
{
    login_user=user;
}


// get chat list
-(ChatViewController *)getChatView:(NSString *)title
{
    if (title==nil)
    {
        return nil;
    }
    return [chat_list objectForKey:title];
}

// set chat list
-(void)setChatView:(NSString *)title view:(ChatViewController *)view
{
    if (title==nil || view==nil)
    {
        return;
    }
    [chat_list setObject:view forKey:title];
    [chat_new_message_count setObject:[NSNumber numberWithInt:0] forKey:title];
    [chat_table reloadData];
}

// increase new message counter
-(void)increaseNewMessageCount:(NSString*)title
{
    int c=[((NSNumber *)[chat_new_message_count objectForKey:title]) intValue];
    [chat_new_message_count setObject:[NSNumber numberWithInt:c+1] forKey:title];
}

// reset new message counter
-(void)resetNewMessageCount:(NSString*)title
{
    [chat_new_message_count setObject:[NSNumber numberWithInt:0] forKey:title];
}

// get new message count
-(int)getNewMessageCount:(NSString *)title
{
    return [((NSNumber *)[chat_new_message_count objectForKey:title]) intValue];
}

#pragma mark - UITableViewController
// number of rows
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [chat_list count];
}

// number of sectiions, always 1
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

// display the cell
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.textLabel.text=[[chat_list allKeys] objectAtIndex:[indexPath indexAtPosition:1]];
    cell.detailTextLabel.text=[NSString stringWithFormat:@"%d",[self getNewMessageCount:cell.textLabel.text]];
}

// initialize the cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    cell=[chat_table dequeueReusableCellWithIdentifier:@"ChatCell"];
    if (cell==nil)
    {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"ChatCell"];
        cell.textLabel.text=[[chat_list allKeys] objectAtIndex:[indexPath indexAtPosition:1]];
        cell.detailTextLabel.text=[NSString stringWithFormat:@"%d",[self getNewMessageCount:cell.textLabel.text]];
    }
    return cell;
}

// when a cell is selected, open the chat
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[chat_table cellForRowAtIndexPath:indexPath];
    ChatViewController *chat_view=[self getChatView:cell.textLabel.text];
    [self resetNewMessageCount:cell.textLabel.text];
    [chat_table deselectRowAtIndexPath:indexPath animated:YES];
    if (chat_view==nil)
    {
        NSLog(@"The selected chat view doesn't exist\n");
    }
    else
    {
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:chat_view];
        [self presentViewController:nc animated:YES completion:nil];
    }
}
@end
