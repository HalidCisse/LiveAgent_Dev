//
//  LocalNotification.h
//  LiveAgent
//
//  Created by Halid Cisse on 6/16/16.
//  Copyright © 2016 Halid Cisse. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocalNotification : NSObject

+ (LocalNotification*)standardLocalNotification;

- (void)scheduleAlert:(NSString*)alertBody;

- (void)scheduleAlert:(NSString*)alertBody fireDate:(NSDate*)fireDate;


@end
