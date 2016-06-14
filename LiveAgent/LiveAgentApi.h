//
//  LiveAgentApi.h
//  LiveAgent
//
//  Created by Halid Cisse on 6/13/16.
//  Copyright © 2016 Halid Cisse. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LiveAgentApi : NSObject

+ (NSString *) sessionId;
+ (void) setSessionId:(NSString *)key;

+ (NSString *) sessionKey;
+ (void) setSessionKey:(NSString *)key;

+ (NSString *) sessionAffinityToken;
+ (void) setSessionAffinityToken:(NSString *)key;

+ (NSString *) sessionSequence;
+ (void) setSessionSequence:(NSString *)key;

+ (BOOL *) hasEnded;
+ (void) setHasEnded:(BOOL*)key;

@end
