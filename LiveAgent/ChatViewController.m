//
//  ChatViewController.m
//  LiveAgent
//
//  Created by Halid Cisse on 6/13/16.
//  Copyright © 2016 Halid Cisse. All rights reserved.
//

#import "ChatViewController.h"
#import "JSQMessages.h"

@interface ChatViewController ()

@property NSMutableArray *messages;
@property JSQMessagesBubbleImage *outgoingBubbleImageView;
@property JSQMessagesBubbleImage *incomingBubbleImageView;

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Support client";
    self.senderId = @"Me";
    self.senderDisplayName = @"Halid";
    _messages = [[NSMutableArray alloc] init];
    
    [self setupBubbles];
    
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    // messages from someone else
    [self PushMessage:@"foo" chat:@"Hey person!"];
    
    // messages sent from local sender
    [self PushMessage:self.senderId chat:@"Yo!"];
    
    // animates the receiving of a new message on the view
    [self PushMessage:self.senderId chat:@"I like turtles!"];
    
    [self finishReceivingMessage];
}


- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath{
    
   return _messages[indexPath.item];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _messages.count;
}

- (void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date{
}

- (void) setupBubbles {
    JSQMessagesBubbleImageFactory *factory = [[JSQMessagesBubbleImageFactory alloc] init];
    _outgoingBubbleImageView = [factory outgoingMessagesBubbleImageWithColor:UIColor.jsq_messageBubbleBlueColor];
    
    _incomingBubbleImageView = [factory outgoingMessagesBubbleImageWithColor:UIColor.jsq_messageBubbleLightGrayColor];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    JSQMessage *message = _messages[indexPath.item];
    if (message.senderId == self.senderId) {
        return _outgoingBubbleImageView;
    } else {
        return _incomingBubbleImageView;
    }
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (void) PushMessage:(NSString*) senderId chat:(NSString*) chatMessage {
    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:senderId senderDisplayName:@"" date:[NSDate date] text:chatMessage];
    [self.messages addObject:message];
}


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
