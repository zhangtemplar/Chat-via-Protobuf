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

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    app_delegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
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
    NSMutableDictionary *chat_list=[app_delegate getChatList];
    ChatViewController *chat_view=[chat_list objectForKey: [login_user userId]];
    if (chat_view==nil)
    {
        // if we don't have a chat view for it, create a new one
        chat_view=[ChatViewController messagesViewController];
        chat_view.delegateModal=self;
        [chat_view setUser:[login_user userId] user_name:[login_user userName] client_id: guest_id guest_name:nil];
        [chat_list setObject:[login_user userId] forKey:chat_view];
    }
    // if current view is not present, show it
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:chat_view];
    [self presentViewController:nc animated:YES completion:nil];
}
-(void) SetUser:(Message *)user
{
    login_user=user;
}
@end
