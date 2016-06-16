//
//  ChatViewController.h
//  LiveAgent
//
//  Created by Halid Cisse on 6/13/16.
//  Copyright © 2016 Halid Cisse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSQMessages.h"

@class ChatViewController;

@protocol ModalControllerDelegate <NSObject>

- (void)didDismissModalControllerDelegate:(ChatViewController *)viewController;

@end

@interface ChatViewController : JSQMessagesViewController
@property (weak, nonatomic) id<ModalControllerDelegate> delegateModal;

@end
