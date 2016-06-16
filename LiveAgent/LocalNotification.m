//
//  LocalNotification.m
//  LiveAgent
//
//  Created by Halid Cisse on 6/16/16.
//  Copyright © 2016 Halid Cisse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocalNotification.h"

static LocalNotification*   localNotification = nil;

@interface LocalNotification(){
    UIApplication* application;
}

@end

@implementation LocalNotification

- (instancetype)init{
    self = [super init];
    if (self) {
        application = [UIApplication sharedApplication];
    }
    return self;
}

+ (LocalNotification*)standardLocalNotification {
    
    @synchronized(self) {
        if(nil == localNotification) {
            localNotification = [LocalNotification alloc];
        }
    }
    return localNotification;
}

- (void)scheduleAlert:(NSString*)alertBody {
    
    [self scheduleAlert:alertBody fireDate:[[NSDate date] dateByAddingTimeInterval:1]];
}

- (void)scheduleAlert:(NSString*)alertBody fireDate:(NSDate*)fireDate{
    
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    
    localNotification.fireDate = fireDate;
    localNotification.timeZone = [NSTimeZone systemTimeZone];
    localNotification.repeatInterval = 0;
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.alertBody = alertBody;
    
    [application scheduleLocalNotification:localNotification];
}

@end
