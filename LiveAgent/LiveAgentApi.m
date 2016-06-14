//
//  LiveAgentApi.m
//  LiveAgent
//
//  Created by Halid Cisse on 6/13/16.
//  Copyright © 2016 Halid Cisse. All rights reserved.
//

#import "LiveAgentApi.h"

@implementation LiveAgentApi

static NSString *sessionId = @"";
static NSString *sessionKey = @"";
static NSString *sessionAffinityToken = @"null";
static NSString *sessionSequence = @"null";
static BOOL     *hasEnded = false;
static NSMutableArray* messages;


+ (NSString *) sessionId { return sessionId; }
+ (void) setSessionId:(NSString*)sId { self.sessionId = sId; }

+ (NSString *) sessionKey { return sessionKey; }
+ (void) setSessionKey:(NSString*)key { sessionKey = key; }

+ (NSString *) sessionAffinityToken { return sessionAffinityToken; }
+ (void) setSessionAffinityToken:(NSString*)affinityToken { sessionAffinityToken = affinityToken; }

+ (NSString *) sessionSequence { return sessionSequence; }
+ (void) setSessionSequence:(NSString*)sequence { sessionSequence = sequence; }

+ (BOOL *) hasEnded { return hasEnded; }
+ (void) setHasEnded:(BOOL*)ended { hasEnded = ended; }

+ (NSMutableArray*) messages { return messages; }
+ (void) setMessages:(NSMutableArray*)chatMessages { messages = chatMessages; }






@end
