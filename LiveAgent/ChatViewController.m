//
//  ChatViewController.m
//  LiveAgent
//
//  Created by Halid Cisse on 6/13/16.
//  Copyright © 2016 Halid Cisse. All rights reserved.
//

#import "ChatViewController.h"
#import "JSQMessages.h"
#import "LiveAgentApi.h"
#import <FSNetworking/FSNConnection.h>
#import "Constants.h"
#import "AFNetworking/AFNetworking.h"
#import <CCActivityHUD/CCActivityHUD.h>
#import "LiveAgentApi.h"

@interface ChatViewController ()

  @property NSDictionary *avatars;
  @property JSQMessagesBubbleImage *outgoingBubbleImageView;
  @property JSQMessagesBubbleImage *incomingBubbleImageView;
  @property CCActivityHUD *activityHUD;

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //self.navigationController.navigationBar.barStyle = UIStatusBarStyleBlackTranslucent;
    //[self.navigationController.navigationBar setBarTintColor:UIColorFromRGB(0x313B47)];
    //self.navigationController.navigationBar.translucent = true;
    
    [self setUp];
    [self pullMessages];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self.inputToolbar.contentView.textView becomeFirstResponder];
}

- (void) setUp {
    self.title             = @"Support client";
    [self setupBubbles];
    
    //self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    //self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
    
    self.inputToolbar.contentView.leftBarButtonItem = nil;
    _activityHUD = [CCActivityHUD new];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                                          target:self
                                                                                          action:@selector(closePressed:)];
}

- (void) setupBubbles {
    _avatars = [NSDictionary new];
    
    JSQMessagesAvatarImageFactory *avatarFactory = [[JSQMessagesAvatarImageFactory alloc] initWithDiameter:kJSQMessagesCollectionViewAvatarSizeDefault];
    
    JSQMessagesAvatarImage *meImage = [avatarFactory avatarImageWithUserInitials:@"Me"
                                                                 backgroundColor:[UIColor colorWithWhite:0.85f alpha:1.0f]
                                                                       textColor:[UIColor colorWithWhite:0.60f alpha:1.0f]
                                                                            font:[UIFont systemFontOfSize:14.0f]];
    
    JSQMessagesAvatarImage *agentImage = [avatarFactory avatarImageWithImage:[UIImage imageNamed:@"MySchneider"]];
    
    _avatars = @{
                 @"customer": meImage,
                 @"Agent"   : agentImage
                };
    
    JSQMessagesBubbleImageFactory *bubbleFactory = [JSQMessagesBubbleImageFactory new];
    _outgoingBubbleImageView = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    _incomingBubbleImageView = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleGreenColor]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.collectionView.collectionViewLayout.springinessEnabled = true;
}

- (NSString *)senderId {
    return @"customer";
}

- (NSString *)senderDisplayName {
    return @"Me";
}

- (void) deactivateChat : (NSString*) reason{
    self.inputToolbar.contentView.rightBarButtonItem = nil;
    self.inputToolbar.contentView.textView.text = reason;
    self.inputToolbar.contentView.textView.editable = false;
    LiveAgentApi.hasEnded = true;
    
    [self.activityHUD showWithText:reason shimmering:false];
    [self.activityHUD dismissWithText:reason delay:0.5 success:YES];
}

- (void) pauseChat {
    self.inputToolbar.contentView.textView.editable = false;
    self.inputToolbar.contentView.rightBarButtonItem.enabled = false;
}

- (void) unPauseChat {
    if (!LiveAgentApi.hasEnded) {
        self.inputToolbar.contentView.textView.editable = true;
        self.inputToolbar.contentView.rightBarButtonItem.enabled = true;
    }
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [LiveAgentApi.messages objectAtIndex:indexPath.item];
    
    return [self.avatars objectForKey:message.senderId];
}

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath{
    
   return LiveAgentApi.messages[indexPath.item];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return LiveAgentApi.messages.count;
}

- (void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date{
    
    [self pauseChat];
    [self pushMessage:text sender:senderId];
}

- (void)didPressAccessoryButton:(UIButton *)sender{
}


- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    JSQMessage *message = LiveAgentApi.messages[indexPath.item];
    if (message.senderId == self.senderId) {
        return self.outgoingBubbleImageView;
    } else {
        return self.incomingBubbleImageView;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell*) [super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    JSQMessage *message = LiveAgentApi.messages[indexPath.item];
    
    if (message.senderId == self.senderId) {
        cell.textView.textColor = UIColor.blackColor;
    } else {
        cell.textView.textColor = UIColor.whiteColor;
    }
    return cell;
}

- (void) addMessageToUI:(NSString*) chatMessage senderId:(NSString*) senderId  {
    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:senderId senderDisplayName:@"" date:[NSDate date] text:chatMessage];
    [LiveAgentApi.messages addObject:message];
    
    if (senderId == self.senderId) {
        [self finishSendingMessageAnimated:true];
    }else{
        [self finishReceivingMessageAnimated:true];
    }
    
    [self scrollToBottomAnimated:YES];
    
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if (state == UIApplicationStateBackground || state == UIApplicationStateInactive)
    {
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.fireDate = [NSDate date];
        notification.alertTitle = @"Mew message!";
        notification.alertBody = chatMessage;
        notification.timeZone = [NSTimeZone defaultTimeZone];
        notification.soundName = UILocalNotificationDefaultSoundName;
        notification.applicationIconBadgeNumber = 1;
        
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
}

















- (void) pullMessages {
    
    if (LiveAgentApi.hasEnded) {
        return;
    }
    
    FSNConnection *connection =
    [FSNConnection withUrl:[[NSURL alloc] initWithString:Messages_path]
                    method:FSNRequestMethodGET
                   headers:[LiveAgentApi getHeaders]
                parameters:nil
                parseBlock:^id(FSNConnection *c, NSError **error) {
                    return [c.responseData dictionaryFromJSONWithError:error];
                }
           completionBlock:^(FSNConnection *json) {
               if (json.didSucceed) {
                   NSDictionary *dictionary = (NSDictionary *)json.parseResult;
                   
                   NSArray* messages = [dictionary objectForKey:@"messages"];
                   NSDictionary *lastMessage = messages.firstObject;
                   
                   if ([[lastMessage objectForKey:@"type"]  isEqual: @"ChatRequestFail"]) {
                       
                       [self deactivateChat:@"chat request failed."];
                       return;
                   }
                   
                   if ([[lastMessage objectForKey:@"type"]  isEqual: @"ChatMessage"]) {
                       NSDictionary *ChatMessage = [lastMessage objectForKey:@"message"];
                       NSString *chat = [ChatMessage objectForKey:@"text"];
                       NSLog(@"New Chat message : %@" , chat);
                      [self addMessageToUI:chat senderId:@"Agent"];
                   }
                   
                   if ([[lastMessage objectForKey:@"type"]  isEqual: @"AgentTyping"]) {
                       self.showTypingIndicator = true;
                   }
                   
                   if ([[lastMessage objectForKey:@"type"]  isEqual: @"AgentNotTyping"]) {
                       self.showTypingIndicator = false;
                   }
                   
                   if ([[lastMessage objectForKey:@"type"]  isEqual: @"ChatEnded"]) {
                       [self deactivateChat:@"chat ended by the agent."];
                   }
                   
                   [self pullMessages];
               }else if (json.httpResponse.statusCode == 503){
                   [self ResyncSession];
               } else {
                   [self.activityHUD show];
                   [self.activityHUD dismissWithText:@"#can not connect." delay:3 success:NO];
                   [self deactivateChat:@"#can not connect."];
                   [self pullMessages];
               }
           } progressBlock:^(FSNConnection *c) {}];
    [connection start];
}

- (void) ResyncSession{
    
    FSNConnection *connection =
    [FSNConnection withUrl:[[NSURL alloc] initWithString:ResyncSession_path]
                    method:FSNRequestMethodGET
                   headers:[LiveAgentApi getHeaders]
                parameters:@{Param_SessionId : LiveAgentApi.sessionId}
                parseBlock:^id(FSNConnection *c, NSError **error) {
                    return [c.responseData dictionaryFromJSONWithError:error];
                }
           completionBlock:^(FSNConnection *json) {
               if (json.didSucceed) {
                   NSDictionary *dictionary = (NSDictionary *)json.parseResult;
                   
                   if ([dictionary objectForKey:@"isValid"]) {
                       LiveAgentApi.sessionKey = [dictionary objectForKey:@"key"];
                       LiveAgentApi.sessionAffinityToken = [dictionary objectForKey:@"affinityToken"];
                       
                       [self pullMessages];
                   }
               }
           } progressBlock:^(FSNConnection *c) {}];
    [connection start];
}

- (void) pushMessage:(NSString *)chatMessage sender:(NSString *) senderId {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    AFJSONRequestSerializer *serializer = [AFJSONRequestSerializer serializer];
    [serializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [serializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    manager.requestSerializer = serializer;
    
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",nil];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    //    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    
    [manager.requestSerializer setValue:LiveAgentApi.sessionKey forHTTPHeaderField:X_LIVEAGENT_SESSION_KEY];
    [manager.requestSerializer setValue:LiveAgentApi.sessionAffinityToken forHTTPHeaderField:X_LIVEAGENT_AFFINITY];
    [manager.requestSerializer setValue:LiveAgentApi.sessionSequence forHTTPHeaderField:X_LIVEAGENT_SEQUENCE];
    [manager.requestSerializer setValue:API_V forHTTPHeaderField:X_LIVEAGENT_API_VERSION];
    
    [manager POST:ChatMessage_path parameters:@{@"text":chatMessage} progress:nil
          success:^(NSURLSessionDataTask *task, id responseObject){
              [self addMessageToUI:chatMessage senderId:senderId];
              [self unPauseChat];
              LiveAgentApi.sessionSequence = [NSString stringWithFormat:@"%d", LiveAgentApi.sessionSequence.intValue + 1];
          } failure:^(NSURLSessionDataTask *task, NSError *error){
              [self unPauseChat];
              
              if (task.response.statusCode == 200 || task.response.statusCode == 204){
                  [self addMessageToUI:chatMessage senderId:senderId];
                  LiveAgentApi.sessionSequence = [NSString stringWithFormat:@"%d", LiveAgentApi.sessionSequence.intValue + 1];
              } else if (task.response.statusCode == 503) {
                  [self ResyncSession];
              } else if (task.response.statusCode == 0) {
                  [self.activityHUD show];
                  [self.activityHUD dismissWithText:@"#The Internet connection appears to be offline." delay:3 success:NO];
                  [self deactivateChat:@"#The Internet connection appears to be offline."];
              } else {
                  NSString* errResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
                  
                  NSLog(@"Error: %@", error);
                  NSLog(@"response %@",errResponse);
                  NSLog(@"response code %ld",task.response.statusCode);
              }
          }];
}

- (void)closePressed:(UIBarButtonItem *)sender
{
    [self.delegateModal didDismissModalControllerDelegate:self];
    LiveAgentApi.hasEnded = true;
}

@end
