//
//  ChatModelData.m
//  Demo ProtoBuf
//
//  Created by Qiang Zhang on 3/29/15.
//  Copyright (c) 2015 Qiang Zhang. All rights reserved.
//

#import "ChatModelData.h"

@implementation ChatModelData
-(instancetype) init
{
    self=[super init];
    // intialization succeeeds
    if (self)
    {
        // intialize the message list, we can also load it from the local storage
        self.messages=[NSMutableArray new];
        
        // create avatar image
        self.avatars=[NSMutableDictionary new];
        
        // create users list
        self.users=[NSMutableDictionary new];
        
        // create message bubble images
        JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
        
        self.outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
        self.incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleGreenColor]];
    }
    
    return self;
}

// add new user
-(void)addUsers:(NSString *)user_id name:(NSString *)name avator:(JSQMessagesAvatarImage *)avator
{
    [self.users setObject:user_id forKey:name];
    [self.avatars setObject:user_id forKey:avator];
}

-(void)addTextMessage:(NSString *)user_id name:(NSString *)name date:(NSDate *)date text:(NSString *)text
{
    if (name==nil)
    {
        name=user_id;
    }
    JSQMessage *msg=[[JSQMessage alloc]initWithSenderId:user_id senderDisplayName:name date:date text:text];
    [self addMessages:msg];
}

-(void)addMessages:(JSQMessage *)msg
{
    [self.messages addObject:msg];
}

-(void)addPhotoMediaMessage:(NSString *)user_id name:(NSString *)name date:(NSDate *)date image:(UIImage *)image
{
    if (name==nil)
    {
        name=user_id;
    }
    JSQPhotoMediaItem *photo=[[JSQPhotoMediaItem alloc] initWithImage:image];
    JSQMessage *msg=[[JSQMessage alloc] initWithSenderId:user_id senderDisplayName:name date:date media:photo];
    [self addMessages:msg];
}

-(void)addLocationMediaMessageCompletion:(NSString *)user_id name:(NSString *)name date:(NSDate *)date location:(CLLocation *)location
{
    JSQLocationMediaItem* loc=[[JSQLocationMediaItem alloc] init];
    [loc setLocation:location];
    if (name==nil)
    {
        name=user_id;
    }
    JSQMessage *msg=[[JSQMessage alloc] initWithSenderId:user_id senderDisplayName:name date:date media:loc];
    [self addMessages:msg];
}

-(void)addVideoMediaMessage:(NSString *)user_id name:(NSString *)name date:(NSDate *)date video:(NSURL *)video ready:(BOOL)ready
{
    JSQVideoMediaItem *clip=[[JSQVideoMediaItem alloc] initWithFileURL:video isReadyToPlay:ready];
    if (name==nil)
    {
        name=user_id;
    }
    JSQMessage *msg=[[JSQMessage alloc] initWithSenderId:user_id senderDisplayName:name date:date media:clip];
    [self addMessages:msg];
    
}
@end
