//
//  LiveAgentApi.m
//  LiveAgent
//
//  Created by Halid Cisse on 6/13/16.
//  Copyright © 2016 Halid Cisse. All rights reserved.
//

#import "LiveAgentApi.h"

@implementation LiveAgentApi

static NSString *sessionId = 0;
static NSString *sessionKey = 0;
static NSString *sessionAffinityToken = 0;
static NSString *sessionSequence = 0;
static BOOL     *hasEnded = false;

+ (NSString *) sessionId { return sessionId; }
+ (void) setSessionId:(NSString*)key { sessionId = key; }

+ (NSString *) sessionKey { return sessionKey; }
+ (void) setSessionKey:(NSString*)key { sessionKey = key; }

+ (NSString *) sessionAffinityToken { return sessionAffinityToken; }
+ (void) setSessionAffinityToken:(NSString*)key { sessionAffinityToken = key; }

+ (NSString *) sessionSequence { return sessionSequence; }
+ (void) setSessionSequence:(NSString*)key { sessionSequence = key; }

+ (BOOL *) hasEnded { return hasEnded; }
+ (void) setHasEnded:(BOOL*)key { hasEnded = key; }

@end
