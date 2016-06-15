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

@interface ChatViewController ()

//@property NSMutableArray *messages;
  @property JSQMessagesBubbleImage *outgoingBubbleImageView;
  @property JSQMessagesBubbleImage *incomingBubbleImageView;

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUp];
    [self pullMessages];
}

- (void) setUp {
    self.title             = @"Support client";
    self.senderId          = @"customer";
    self.senderDisplayName = @"Me";
    
    [self setupBubbles];
    
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
    
    //self.inputToolbar.contentView.backgroundColor = UIColor.blackColor;
}

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath{
    
   return LiveAgentApi.messages[indexPath.item];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return LiveAgentApi.messages.count;
}

- (void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date{
    
    
    [self pushMessage:text sender:senderId];
}

- (void)didPressAccessoryButton:(UIButton *)sender{
}

- (void) setupBubbles {
    JSQMessagesBubbleImageFactory *factory = [[JSQMessagesBubbleImageFactory alloc] init];
    _outgoingBubbleImageView = [factory outgoingMessagesBubbleImageWithColor:UIColor.jsq_messageBubbleBlueColor];
    
    _incomingBubbleImageView = [factory incomingMessagesBubbleImageWithColor:UIColor.jsq_messageBubbleLightGrayColor];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    JSQMessage *message = LiveAgentApi.messages[indexPath.item];
    if (message.senderId == self.senderId) {
        return _outgoingBubbleImageView;
    } else {
        return _incomingBubbleImageView;
    }
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell*) [super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    JSQMessage *message = LiveAgentApi.messages[indexPath.item];
    
    if (message.senderId == self.senderId) {
        cell.textView.textColor = UIColor.whiteColor;
    } else {
        cell.textView.textColor = UIColor.blackColor;
    }
    return cell;
}

- (void) addMessageToUI:(NSString*) chatMessage senderId:(NSString*) senderId  {
    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:senderId senderDisplayName:@"" date:[NSDate date] text:chatMessage];
    [LiveAgentApi.messages addObject:message];
    
    if (senderId == self.senderId) {
        [self finishSendingMessage];
    }else{
        [self finishReceivingMessage];
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
                   
                   NSLog(@"%@", [lastMessage objectForKey:@"type"]);
                   
                   if ([[lastMessage objectForKey:@"type"]  isEqual: @"ChatRequestSuccess"]) {
                       [self pullMessages];
                       return;
                   }
                   
                   if ([[lastMessage objectForKey:@"type"]  isEqual: @"ChatEstablished"]) {
                       [self pullMessages];
                       return;
                   }
                   
                   if ([[lastMessage objectForKey:@"type"]  isEqual: @"ChatRequestFail"]) {
                       
                       //failed do something
                       return;
                   }
                   
                   if ([[lastMessage objectForKey:@"type"]  isEqual: @"ChatMessage"]) {
                       NSDictionary *ChatMessage = [lastMessage objectForKey:@"message"];
                       NSString *chat = [ChatMessage objectForKey:@"text"];
                       NSLog(@"New Chat message : %@" , chat);
                      [self addMessageToUI:chat senderId:@"Agent"];
                   }
                   
                   if ([[lastMessage objectForKey:@"type"]  isEqual: @"AgentTyping"]) {
                       NSLog(@"Chat AgentTyping");
                   }
                   
                   if ([[lastMessage objectForKey:@"type"]  isEqual: @"AgentNotTyping"]) {
                       NSLog(@"Chat AgentNotTyping");
                   }
                   
                   if ([[lastMessage objectForKey:@"type"]  isEqual: @"ChatEnd"]) {
                       NSLog(@"Chat end by agent");
                       LiveAgentApi.hasEnded = true;
                   }
                   
                   [self pullMessages];
               }else if (json.httpResponse.statusCode == 503 && !LiveAgentApi.hasEnded){
                   [self ResyncSession];
               } else {
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
    
    [self addMessageToUI:chatMessage senderId:senderId];
    
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
              LiveAgentApi.sessionSequence = [NSString stringWithFormat:@"%d", LiveAgentApi.sessionSequence.intValue + 1];
          } failure:^(NSURLSessionDataTask *task, NSError *error){
              if (task.response.statusCode == 200 || task.response.statusCode == 204){
                  LiveAgentApi.sessionSequence = [NSString stringWithFormat:@"%d", LiveAgentApi.sessionSequence.intValue + 1];
              } else if (task.response.statusCode == 503) {
                  [self ResyncSession];
              } else {
                  NSString* errResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
                  
                  NSLog(@"Error: %@", error);
                  NSLog(@"response %@",errResponse);
                  NSLog(@"response code %ld",task.response.statusCode);
              }
          }];
}



@end
