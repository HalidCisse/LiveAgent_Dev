//
//  Constants.m
//  LiveAgent
//
//  Created by Halid Cisse on 6/9/16.
//  Copyright © 2016 Halid Cisse. All rights reserved.
//

#import "Constants.h"

@implementation Constants

 NSString *const X_LIVEAGENT_SESSION_KEY = @"X-LIVEAGENT-SESSION-KEY";
 NSString *const X_LIVEAGENT_AFFINITY = @"X-LIVEAGENT-AFFINITY";
 NSString *const X_LIVEAGENT_API_VERSION = @"X-LIVEAGENT-API-VERSION";
 NSString *const X_LIVEAGENT_SEQUENCE = @"X-LIVEAGENT-SEQUENCE";

 NSString *const LIVE_AGENT_ENDPOINT = @"https://d.la1-c1-frf.salesforceliveagent.com/chat/rest/";
 NSString *const ORG_ID = @"00D58000000OwMB";
 NSString *const DEPLOYEMENT_ID = @"57258000000L1mj";
 NSString *const BUTTON_ID = @"57358000000L24F";
 NSString *const API_V = @"37";

 NSString *const SessionId_path = @"https://d.la1-c1-frf.salesforceliveagent.com/chat/rest/System/SessionId";
 NSString *const ChasitorInit_path = @"https://d.la1-c1-frf.salesforceliveagent.com/chat/rest/Chasitor/ChasitorInit";
 NSString *const Messages_path = @"https://d.la1-c1-frf.salesforceliveagent.com/chat/rest/System/Messages";
 NSString *const ResyncSession_path = @"https://d.la1-c1-frf.salesforceliveagent.com/chat/rest/System/ResyncSession";
 NSString *const ChasitorResyncState_path = @"https://d.la1-c1-frf.salesforceliveagent.com/chat/rest/Chasitor/ChasitorResyncState";
 NSString *const ChatMessage_path = @"https://d.la1-c1-frf.salesforceliveagent.com/chat/rest/Chasitor/ChatMessage";

@end
