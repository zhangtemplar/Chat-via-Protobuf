//
//  ChatModelData.h
//  Demo ProtoBuf
//
//  Created by Qiang Zhang on 3/29/15.
//  Copyright (c) 2015 Qiang Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "JSQMessages.h"

@class JSQMessagesBubbleImage;

@interface ChatModelData : NSObject
// the message list
@property (strong, nonatomic) NSMutableArray *messages;
// the avatar hashtable
@property (strong, nonatomic) NSMutableDictionary *avatars;
// the outgoing message bubble
@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingBubbleImageData;
// the in coming message bubble
@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImageData;
// the users in this chat
@property (strong, nonatomic) NSMutableDictionary *users;
// add new user and its avator
-(void)addUsers:(NSString *)id name:(NSString *)name avator:(JSQMessagesAvatarImage *)avator;
// add a photo message
- (void)addPhotoMediaMessage:(NSString *)id name:(NSString *)name date:(NSDate *)date image:(UIImage*)image;
// the add location
- (void)addLocationMediaMessageCompletion:(NSString *)id name:(NSString *)name date:(NSDate *)date location:(CLLocation*)location;
// add video
- (void)addVideoMediaMessage:(NSString *)id name:(NSString *)name date:(NSDate *)date video:(NSURL *)video ready:(BOOL)ready;
// add text message
-(void) addTextMessage:(NSString *)id name:(NSString *)name date:(NSDate *)date text:(NSString *)text;
// add general message
-(void) addMessages:(JSQMessage *)msg;
@end
