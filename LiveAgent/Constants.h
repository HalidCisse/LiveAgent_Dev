//
//  Constants.h
//  LiveAgent
//
//  Created by Halid Cisse on 6/9/16.
//  Copyright © 2016 Halid Cisse. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Constants : NSObject

extern NSString *const X_LIVEAGENT_SESSION_KEY;
extern NSString *const X_LIVEAGENT_AFFINITY;
extern NSString *const X_LIVEAGENT_API_VERSION;
extern NSString *const X_LIVEAGENT_SEQUENCE;

extern NSString *const Param_SessionId;
extern NSString *const Param_OrganizationId;
extern NSString *const Param_DeploymentId;
extern NSString *const Param_ButtonId;
extern NSString *const Param_UserAgent;
extern NSString *const Param_Language;
extern NSString *const Param_ScreenResolution;
extern NSString *const Param_VisitorName;
extern NSString *const Param_PrechatDetails;
extern NSString *const Param_PrechatEntities;
extern NSString *const Param_ReceiveQueueUpdates;
extern NSString *const Param_IsPost;

extern NSString *const LIVE_AGENT_ENDPOINT;
extern NSString *const ORG_ID;
extern NSString *const DEPLOYEMENT_ID;
extern NSString *const BUTTON_ID;
extern NSString *const API_V;
extern NSString *const USER_AGENT;
extern NSString *const LANG;
extern NSString *const SCREEN_RES;

extern NSString *const Availability_path;
extern NSString *const SessionId_path;
extern NSString *const ChasitorInit_path;
extern NSString *const Messages_path;
extern NSString *const ResyncSession_path;
extern NSString *const ChasitorResyncState_path;
extern NSString *const ChatMessage_path;

@end
