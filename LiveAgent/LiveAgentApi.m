//
//  LiveAgentApi.m
//  LiveAgent
//
//  Created by Halid Cisse on 6/13/16.
//  Copyright © 2016 Halid Cisse. All rights reserved.
//

#import "JSQMessages.h"
#import "LiveAgentApi.h"
#import "Constants.h"

@implementation LiveAgentApi

static NSString *sessionId            = @"";
static NSString *sessionKey           = @"";
static NSString *sessionAffinityToken = @"1";
static NSString *sessionSequence      = @"null";
static NSString *agentId              = @"";
static NSString *agentName            = @"agent";
static NSString *clientName           = @"Customer";
static BOOL     *hasEnded             = false;
static NSMutableArray* messages;

+ (NSString *) sessionId { return sessionId; }
+ (void) setSessionId:(NSString*)sId { sessionId = sId; }

+ (NSString *) sessionKey { return sessionKey; }
+ (void) setSessionKey:(NSString*)key { sessionKey = key; }

+ (NSString *) sessionAffinityToken { return sessionAffinityToken; }
+ (void) setSessionAffinityToken:(NSString*)affinityToken { sessionAffinityToken = affinityToken; }

+ (NSString *) sessionSequence { return sessionSequence; }
+ (void) setSessionSequence:(NSString*)sequence { sessionSequence = sequence; }

+ (NSString *) agentId { return agentId; }
+ (void) setAgentId:(NSString*)agent { agentId = agent; }

+ (NSString *) agentName { return agentName; }
+ (void) setAgentName:(NSString*)name { agentName = name; }

+ (NSString *) clientName { return clientName; }
+ (void) setClientName:(NSString*)name { clientName = name; }

+ (BOOL *) hasEnded { return hasEnded; }
+ (void) setHasEnded:(BOOL*)ended { hasEnded = ended; }

+ (NSMutableArray*) messages { return messages; }
+ (void) setMessages:(NSMutableArray*)chatMessages { messages = chatMessages; }


+ (NSDictionary *)getHeaders {
    return @{ X_LIVEAGENT_SESSION_KEY : sessionKey,
              X_LIVEAGENT_AFFINITY    : sessionAffinityToken,
              X_LIVEAGENT_SEQUENCE    : sessionSequence,
              X_LIVEAGENT_API_VERSION : API_V
              };
}

+ (NSString *) agentInitial {
    NSMutableString * firstCharacters = [NSMutableString string];
    NSArray * words = [agentName componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    for (NSString * word in words) {
        if ([word length] > 0) {
            NSString * firstLetter = [word substringToIndex:1];
            [firstCharacters appendString:[firstLetter uppercaseString]];
        }
    }
    return firstCharacters;
}
@end
