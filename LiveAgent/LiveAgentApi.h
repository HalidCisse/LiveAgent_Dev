//
//  LiveAgentApi.h
//  LiveAgent
//
//  Created by Halid Cisse on 6/13/16.
//  Copyright © 2016 Halid Cisse. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSQMessages.h"
#import "AFNetworking.h"


@interface LiveAgentApi : NSObject

+ (NSString *) sessionId;
+ (void) setSessionId:(NSString *)sId;

+ (NSString *) sessionKey;
+ (void) setSessionKey:(NSString *)key;

+ (NSString *) sessionAffinityToken;
+ (void) setSessionAffinityToken:(NSString *)affinityToken;

+ (NSString *) sessionSequence;
+ (void) setSessionSequence:(NSString *)sequence;

+ (NSString *) agentId;
+ (void) setAgentId:(NSString *)agent;

+ (NSString *) agentName;
+ (void) setAgentName:(NSString *)name;

+ (NSString *) clientName;
+ (void) setClientName:(NSString *)name;

+ (BOOL *) hasEnded;
+ (void) setHasEnded:(BOOL*)ended;

+ (NSMutableArray*) messages;
+ (void) setMessages:(NSMutableArray*)chatMessages;

+ (NSDictionary *)getHeaders;
+ (void)fillHeaders:(AFHTTPSessionManager*) manager;
+ (NSString *) agentInitial;

@end
