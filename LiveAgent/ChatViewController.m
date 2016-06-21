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
#import "Constants.h"
#import "AFNetworking/AFNetworking.h"
#import <CCActivityHUD/CCActivityHUD.h>
#import "LiveAgentApi.h"
#import "AFNetworking.h"

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
                 @"agent"   : agentImage
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

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item % 7 == 0) {
        JSQMessage *message = [LiveAgentApi.messages objectAtIndex:indexPath.item];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [LiveAgentApi.messages objectAtIndex:indexPath.item];

    if ([message.senderId isEqualToString:self.senderId]) {
        return nil;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [LiveAgentApi.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:message.senderId]) {
            return nil;
        }
    }
  
    return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - Adjusting cell label heights

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item % 7 == 0) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *currentMessage = [LiveAgentApi.messages objectAtIndex:indexPath.item];
    if ([[currentMessage senderId] isEqualToString:self.senderId]) {
        return 0.0f;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [LiveAgentApi.messages objectAtIndex:indexPath.item - 1];
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

- (void) addMessageToUI:(NSString*) chatMessage senderId:(NSString*) senderId senderName:(NSString*) senderName  {
    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:senderId senderDisplayName:senderName date:[NSDate date] text:chatMessage];
    [LiveAgentApi.messages addObject:message];
    
    [self scrollToBottomAnimated:YES];
    
    if (senderId == self.senderId) {
        [self finishSendingMessageAnimated:true];
    }else{
        [self finishReceivingMessageAnimated:true];
    }
    
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
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [LiveAgentApi fillHeaders:manager];
    
    [manager GET:Messages_path parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSDictionary *dictionary = (NSDictionary *)responseObject;
        
        NSArray* messages = [dictionary objectForKey:@"messages"];
        NSDictionary *lastMessage = messages.firstObject;
        
        if ([[lastMessage objectForKey:@"type"]  isEqual: @"ChatRequestFail"]) {
            [self deactivateChat:@"chat request failed."];
            return;
        }
        
        if ([[lastMessage objectForKey:@"type"]  isEqual: @"ChatMessage"]) {
            NSDictionary *ChatMessage = [lastMessage objectForKey:@"message"];
            
            [self addMessageToUI:[ChatMessage objectForKey:@"text"] senderId:@"agent"   senderName:[ChatMessage objectForKey:@"name"]];
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
    } failure:^(NSURLSessionTask *task, NSError *error) {
        NSLog(@"Error: %@", error);
        
        NSInteger statusCode = ((NSHTTPURLResponse*)task.response).statusCode;
        
        if (statusCode == 503){
            [self ResyncSession];
        } else if (statusCode == 204){
            [self pullMessages];
        } else if (statusCode == 0){
            //[self deactivateChat:@"The Internet connection appears to be offline."];
            [self pullMessages];
        } else if (statusCode == 409){
            LiveAgentApi.sessionAffinityToken = @"1";
            [self pullMessages];
        } else {
            NSLog(@"response code %ld", statusCode);
            NSLog(@"response code %@", task.response);
            
            [self deactivateChat:@"can not connect."];
        }
    }];
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
    
    [manager.requestSerializer setValue:LiveAgentApi.sessionKey forHTTPHeaderField:X_LIVEAGENT_SESSION_KEY];
    [manager.requestSerializer setValue:LiveAgentApi.sessionAffinityToken forHTTPHeaderField:X_LIVEAGENT_AFFINITY];
    [manager.requestSerializer setValue:LiveAgentApi.sessionSequence forHTTPHeaderField:X_LIVEAGENT_SEQUENCE];
    [manager.requestSerializer setValue:API_V forHTTPHeaderField:X_LIVEAGENT_API_VERSION];
    
    [manager POST:ChatMessage_path parameters:@{@"text":chatMessage} progress:nil
          success:^(NSURLSessionDataTask *task, id responseObject){
              [self addMessageToUI:chatMessage senderId:senderId senderName:@"customer"];
              [self unPauseChat];
              LiveAgentApi.sessionSequence = [NSString stringWithFormat:@"%d", LiveAgentApi.sessionSequence.intValue + 1];
          } failure:^(NSURLSessionDataTask *task, NSError *error){
              [self unPauseChat];
              
              NSInteger statusCode = ((NSHTTPURLResponse*)task.response).statusCode;
              
              if (statusCode == 200 || statusCode == 204){
                  [self addMessageToUI:chatMessage senderId:senderId senderName:@"customer"];
                  LiveAgentApi.sessionSequence = [NSString stringWithFormat:@"%d", LiveAgentApi.sessionSequence.intValue + 1];
              } else if (statusCode == 503) {
                  [self ResyncSession];
              } else if (statusCode == 0) {
                  [self.activityHUD show];
                  [self.activityHUD dismissWithText:@"#The Internet connection appears to be offline." delay:3 success:NO];
                  [self deactivateChat:@"#The Internet connection appears to be offline."];
              } else if (statusCode == 409){
                  LiveAgentApi.sessionSequence = @"2";
              } else {
                  NSString* errResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
                  
                  NSLog(@"Error: %@", error);
                  NSLog(@"response %@", errResponse);
                  NSLog(@"response code %ld", statusCode);
              }
          }];
}

- (void) ResyncSession{
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [LiveAgentApi fillHeaders:manager];
    
    [manager GET:ResyncSession_path parameters:@{Param_SessionId : LiveAgentApi.sessionId} progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSDictionary *dictionary = (NSDictionary *)responseObject;
        
        if ([dictionary objectForKey:@"isValid"]) {
            LiveAgentApi.sessionKey = [dictionary objectForKey:@"key"];
            LiveAgentApi.sessionAffinityToken = [dictionary objectForKey:@"affinityToken"];
            
            [self pullMessages];
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void)closePressed:(UIBarButtonItem *)sender
{
    [self.delegateModal didDismissModalControllerDelegate:self];
    LiveAgentApi.hasEnded = true;
}

@end
