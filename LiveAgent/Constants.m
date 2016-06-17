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

 NSString *const Param_SessionId = @"sessionId";
 NSString *const Param_OrganizationId = @"organizationId";
 NSString *const Param_DeploymentId = @"deploymentId";
 NSString *const Param_ButtonId = @"buttonId";
 NSString *const Param_AgentId = @"agentId";
 NSString *const Param_UserAgent = @"userAgent";
 NSString *const Param_Language = @"language";
 NSString *const Param_ScreenResolution = @"screenResolution";

 NSString *const Param_VisitorName = @"visitorName";
 NSString *const Param_PrechatDetails = @"prechatDetails";
 NSString *const Param_PrechatEntities = @"prechatEntities";
 NSString *const Param_ReceiveQueueUpdates = @"receiveQueueUpdates";
 NSString *const Param_IsPost = @"isPost";

// NSString *const LIVE_AGENT_ENDPOINT = @"https://d.la4-c2cs-was.salesforceliveagent.com/chat/rest/";
// NSString *const ORG_ID = @"00DR0000001uwzf";
// NSString *const DEPLOYEMENT_ID = @"572A000000004bg";
// NSString *const BUTTON_ID = @"573A000000004wL";

 NSString *const LIVE_AGENT_ENDPOINT = @"https://d.la1-c1-frf.salesforceliveagent.com/chat/rest/";
 NSString *const ORG_ID = @"00D58000000OwMB";
 NSString *const DEPLOYEMENT_ID = @"57258000000L1mj";
 NSString *const BUTTON_ID = @"57358000000L24F";
 NSString *const API_V = @"37";

 NSString *const USER_AGENT = @"SCHNEIDER_IOS";
 NSString *const LANG = @"en-US";
 NSString *const SCREEN_RES = @"1900x1080";

 NSString *const Availability_path = @"https://d.la1-c1-frf.salesforceliveagent.com/chat/rest/Visitor/Availability";
 NSString *const SessionId_path = @"https://d.la1-c1-frf.salesforceliveagent.com/chat/rest/System/SessionId";
 NSString *const ChasitorInit_path = @"https://d.la1-c1-frf.salesforceliveagent.com/chat/rest/Chasitor/ChasitorInit";
 NSString *const Messages_path = @"https://d.la1-c1-frf.salesforceliveagent.com/chat/rest/System/Messages";
 NSString *const ResyncSession_path = @"https://d.la1-c1-frf.salesforceliveagent.com/chat/rest/System/ResyncSession";
 NSString *const ChasitorResyncState_path = @"https://d.la1-c1-frf.salesforceliveagent.com/chat/rest/Chasitor/ChasitorResyncState";
 NSString *const ChatMessage_path = @"https://d.la1-c1-frf.salesforceliveagent.com/chat/rest/Chasitor/ChatMessage";

@end
