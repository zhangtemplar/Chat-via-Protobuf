//
//  ChatViewController.m
//  Demo ProtoBuf
//
//  Created by Qiang Zhang on 3/29/15.
//  Copyright (c) 2015 Qiang Zhang. All rights reserved.
//

#import "App.pb.h"
#import "ChatModelData.h"
#import "JSQMessages.h"
#import "ChatViewController.h"
#import "AppDelegate.h"

@interface ChatViewController ()

@end

@implementation ChatViewController
#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    /**
     *  You can set custom avatar sizes
     */
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
    
    self.showLoadEarlierMessagesHeader = YES;
    
    // the ... button or typing indicator
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage jsq_defaultTypingIndicatorImage] style:UIBarButtonItemStyleBordered target:self action:@selector(receiveMessagePressed:)];
    
    app_delegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
}

// dynamically add a close button to the top left of the view
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // the back button
    if (self.delegateModal) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(closePressed:)];
    }
}

// disable "spring" effect
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    /**
     *  Enable/disable springy bubbles, default is NO.
     *  You must set this from `viewDidAppear:`
     *  Note: this feature is mostly stable, but still experimental
     */
    self.collectionView.collectionViewLayout.springinessEnabled = NO;
}

#pragma mark - Testing

- (void)pushMainViewController
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *nc = [sb instantiateInitialViewController];
    [self.navigationController pushViewController:nc.topViewController animated:YES];
}

// on receive the new message
-(void) onReceiveMessage:(Message *)msg
{
    // check the msg then add it
    NSDate *msg_date=[NSDate dateWithTimeIntervalSince1970:[[msg textFromServerRequest] date]];
    
    [[self chatData] addTextMessage:[[msg textFromServerRequest] fromUserId] name:[[msg textFromServerRequest] fromUserId] date:msg_date text:[[msg textFromServerRequest] text]];
    
    /**
     *  Upon receiving a message, you should:
     *
     *  1. Play sound (optional)
     *  2. Add new id<JSQMessageData> object to your data source
     *  3. Call `finishReceivingMessage`
     */
    [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
    [self finishReceivingMessageAnimated:YES];
}

#pragma mark - Actions

// clicking the user is typing--mimicking receving a new message
- (void)receiveMessagePressed:(UIBarButtonItem *)sender
{
    NSLog(@"receiveMessagePressed is deprecated\n");
}

// close current view
- (void)closePressed:(UIBarButtonItem *)sender
{
    [self.delegateModal didDismissJSQChatViewController:self];
}

#pragma mark - JSQMessagesViewController method overrides

// on sending new message
- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date
{
    /**
     *  Sending a message. Your implementation of this method should do *at least* the following:
     *
     *  1. Play sound (optional)
     *  2. Add new id<JSQMessageData> object to your data source
     *  3. Call `finishSendingMessage`
     */
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    
    // create message
    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:senderId
                                             senderDisplayName:senderDisplayName
                                                          date:date
                                                          text:text];
    // add to message queue
    [self.chatData.messages addObject:message];
    
    // animation
    [self finishSendingMessageAnimated:YES];
    
    // send the message via sockets
    Message_TextChatMessageRequest_Builder *txt_msg_builder=[Message_TextChatMessageRequest builder];
    [txt_msg_builder setUserId:senderId];
    [txt_msg_builder setText:text];
    [txt_msg_builder setToUserId:[guest_id lastObject]];
    [txt_msg_builder setDate:[[NSDate date] timeIntervalSince1970]];
    [txt_msg_builder setMessageHash:nil];
    
    Message_Builder *msg_build=[Message builder];
    [msg_build setType:Message_MessageTypeTextReq];
    [msg_build setTextChatMessageRequest:[txt_msg_builder build]];
    
    [app_delegate sendMessage:[msg_build build]];
}

// add media message
- (void)didPressAccessoryButton:(UIButton *)sender
{
    // media list or button list
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Media messages"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"Send photo", @"Send location", @"Send video", nil];
    
    [sheet showFromToolbar:self.inputToolbar];
}

// the delegate for pressing the uiactionsheet
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    switch (buttonIndex) {
            // photo
        case 0:
//            [self.chatData addPhotoMediaMessage];
            break;
            // location
        case 1:
        {
            __weak UICollectionView *weakView = self.collectionView;
            
//            [self.chatData addLocationMediaMessageCompletion:^{[weakView reloadData];}];
        }
            break;
            // video
        case 2:
//            [self.chatData addVideoMediaMessage];
            break;
    }
    
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Function not yet supported" message:@"Sorry but only text message is supported" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    
    [self finishSendingMessageAnimated:YES];
}



#pragma mark - JSQMessages CollectionView DataSource
// get message at the index
- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.chatData.messages objectAtIndex:indexPath.item];
}
// create message bubble for the mssage
- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  You may return nil here if you do not want bubbles.
     *  In this case, you should set the background color of your collection view cell's textView.
     *
     *  Otherwise, return your previously created bubble image data objects.
     */
    
    JSQMessage *message = [self.chatData.messages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return self.chatData.outgoingBubbleImageData;
    }
    
    return self.chatData.incomingBubbleImageData;
}

// get the avator for the message
- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Return `nil` here if you do not want avatars.
     *  If you do return `nil`, be sure to do the following in `viewDidLoad`:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
     *
     *  It is possible to have only outgoing avatars or only incoming avatars, too.
     */
    
    /**
     *  Return your previously created avatar image data objects.
     *
     *  Note: these the avatars will be sized according to these values:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize
     *
     *  Override the defaults in `viewDidLoad`
     */
    JSQMessage *message = [self.chatData.messages objectAtIndex:indexPath.item];
    
    // customize the avataor for sender or receiver
//    if ([message.senderId isEqualToString:self.senderId]) {
//        if (![NSUserDefaults outgoingAvatarSetting]) {
//            return nil;
//        }
//    }
//    else {
//        if (![NSUserDefaults incomingAvatarSetting]) {
//            return nil;
//        }
//    }
    
    // get the avator according to the sender id
    return [self.chatData.avatars objectForKey:message.senderId];
}

// some special text or separator, which is a timestamp here
- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
     *  The other label text delegate methods should follow a similar pattern.
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        JSQMessage *message = [self.chatData.messages objectAtIndex:indexPath.item];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    
    return nil;
}

// showing the sender's name
- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.chatData.messages objectAtIndex:indexPath.item];
    
    /**
     *  iOS7-style sender name labels, escape myself
     */
    if ([message.senderId isEqualToString:self.senderId]) {
        return nil;
    }
    
    // if the message are from the sender of previous message, skip it
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.chatData.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:message.senderId]) {
            return nil;
        }
    }
    
    /**
     *  Don't specify attributes to use the defaults.
     */
    return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - UICollectionView DataSource
// get the number of message
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.chatData.messages count];
}

// appearance property of the message
- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Override point for customizing cells
     */
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    /**
     *  Configure almost *anything* on the cell
     *
     *  Text colors, label text, label colors, etc.
     *
     *
     *  DO NOT set `cell.textView.font` !
     *  Instead, you need to set `self.collectionView.collectionViewLayout.messageBubbleFont` to the font you want in `viewDidLoad`
     *
     *
     *  DO NOT manipulate cell layout information!
     *  Instead, override the properties you want on `self.collectionView.collectionViewLayout` from `viewDidLoad`
     */
    
    JSQMessage *msg = [self.chatData.messages objectAtIndex:indexPath.item];
    
    if (!msg.isMediaMessage) {
        
        if ([msg.senderId isEqualToString:self.senderId]) {
            cell.textView.textColor = [UIColor blackColor];
        }
        else {
            cell.textView.textColor = [UIColor whiteColor];
        }
        
        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    }
    
    return cell;
}



#pragma mark - JSQMessages collection view flow layout delegate

#pragma mark - Adjusting cell label heights

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
     */
    
    /**
     *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
     *  The other label height delegate methods should follow similarly
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  iOS7-style sender name labels
     */
    JSQMessage *currentMessage = [self.chatData.messages objectAtIndex:indexPath.item];
    if ([[currentMessage senderId] isEqualToString:self.senderId]) {
        return 0.0f;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.chatData.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:[currentMessage senderId]]) {
            return 0.0f;
        }
    }
    
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.0f;
}

#pragma mark - Responding to collection view tap events

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
{
    NSLog(@"Load earlier messages!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped avatar!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped message bubble!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
{
    NSLog(@"Tapped cell at %@!", NSStringFromCGPoint(touchLocation));
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

-(void)setUser:(Message *)user
{
    login_user=user;
    // receive a message
    if ([login_user type]==Message_MessageTypeTextReq)
    {
        // receive: current user
        [[self chatData] addUsers:[[login_user textFromServerRequest] toUserId] name:[[login_user textFromServerRequest] toUserId] avator:nil];
        // sender: remote user
        [[self chatData] addUsers:[[login_user textFromServerRequest] fromUserId] name:[[login_user textFromServerRequest] fromUserId] avator:nil];
        
        // set up the sender, which is the logged in user
        self.senderId=[[login_user textFromServerRequest] toUserId];
        self.senderDisplayName=[[login_user textFromServerRequest] toUserId];
       
        if (guest_id==nil)
        {
            guest_id=[NSMutableArray alloc];
        }
        [guest_id addObject:[[login_user textFromServerRequest] fromUserId]];
    }
    // current user want to start a chat
    else if ([login_user type]==Message_MessageTypeLoginResp)
    {
        NSLog(@"Not yet implemented");
    }
    else
    {
        NSLog(@"Invalid message type");
    }
}

@end
