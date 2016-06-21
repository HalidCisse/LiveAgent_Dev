//
//  Trash.m
//  LiveAgent
//
//  Created by Halid Cisse on 6/13/16.
//  Copyright © 2016 Halid Cisse. All rights reserved.
//

#import "Trash.h"
#import "Constants.h"

@implementation Trash




//- (void) pullMessages {
//
//    if (LiveAgentApi.hasEnded) {
//        return;
//    }
//
//    FSNConnection *connection =
//    [FSNConnection withUrl:[[NSURL alloc] initWithString:Messages_path]
//                    method:FSNRequestMethodGET
//                   headers:[LiveAgentApi getHeaders]
//                parameters:nil
//                parseBlock:^id(FSNConnection *c, NSError **error) {
//                    return [c.responseData dictionaryFromJSONWithError:error];
//                }
//           completionBlock:^(FSNConnection *json) {
//               if (json.didSucceed) {
//                   NSDictionary *dictionary = (NSDictionary *)json.parseResult;
//
//                   NSArray* messages = [dictionary objectForKey:@"messages"];
//                   NSDictionary *lastMessage = messages.firstObject;
//
//                   if ([[lastMessage objectForKey:@"type"]  isEqual: @"ChatRequestFail"]) {
//                       [self deactivateChat:@"chat request failed."];
//                       return;
//                   }
//
//                   if ([[lastMessage objectForKey:@"type"]  isEqual: @"ChatMessage"]) {
//                       NSDictionary *ChatMessage = [lastMessage objectForKey:@"message"];
//
//                      [self addMessageToUI:[ChatMessage objectForKey:@"text"] senderId:@"agent"   senderName:[ChatMessage objectForKey:@"name"]];
//                   }
//
//                   if ([[lastMessage objectForKey:@"type"]  isEqual: @"AgentTyping"]) {
//                       self.showTypingIndicator = true;
//                   }
//
//                   if ([[lastMessage objectForKey:@"type"]  isEqual: @"AgentNotTyping"]) {
//                       self.showTypingIndicator = false;
//                   }
//
//                   if ([[lastMessage objectForKey:@"type"]  isEqual: @"ChatEnded"]) {
//                       [self deactivateChat:@"chat ended by the agent."];
//                   }
//
//                   [self pullMessages];
//               }else if (json.httpResponse.statusCode == 503){
//                   [self ResyncSession];
//               } else if (json.response.statusCode == 204){
//                   [self pullMessages];
//               } else if (json.response.statusCode == 0){
//                   //[self deactivateChat:@"The Internet connection appears to be offline."];
//                   [self pullMessages];
//               } else if (json.response.statusCode == 409){
//                   LiveAgentApi.sessionAffinityToken = @"1";
//                   [self pullMessages];
//               }
//               else {
//                   NSLog(@"response code %ld", json.response.statusCode);
//                   NSLog(@"response code %@", json.response);
//
//                   [self deactivateChat:@"can not connect."];
//               }
//           } progressBlock:^(FSNConnection *c) {}];
//    [connection start];
//}



//- (void) ResyncSession{
//
//    FSNConnection *connection =
//    [FSNConnection withUrl:[[NSURL alloc] initWithString:ResyncSession_path]
//                    method:FSNRequestMethodGET
//                   headers:[LiveAgentApi getHeaders]
//                parameters:@{Param_SessionId : LiveAgentApi.sessionId}
//                parseBlock:^id(FSNConnection *c, NSError **error) {
//                    return [c.responseData dictionaryFromJSONWithError:error];
//                }
//           completionBlock:^(FSNConnection *json) {
//               if (json.didSucceed) {
//                   NSDictionary *dictionary = (NSDictionary *)json.parseResult;
//
//                   if ([dictionary objectForKey:@"isValid"]) {
//                       LiveAgentApi.sessionKey = [dictionary objectForKey:@"key"];
//                       LiveAgentApi.sessionAffinityToken = [dictionary objectForKey:@"affinityToken"];
//
//                       [self pullMessages];
//                   }
//               }
//           } progressBlock:^(FSNConnection *c) {}];
//    [connection start];
//}



//- (void) checkAvailabilityX {
//    
//    [self.activityHUD showWithText:@"connecting..." shimmering:YES];
//    
//    FSNConnection *connection =
//    [FSNConnection withUrl:[[NSURL alloc] initWithString:Availability_path]
//                    method:FSNRequestMethodGET
//                   headers:@{ X_LIVEAGENT_API_VERSION : API_V}
//                parameters:@{
//                             @"org_id"           : ORG_ID,
//                             @"deployment_id"    : DEPLOYEMENT_ID,
//                             @"Availability.ids" : BUTTON_ID
//                             }
//                parseBlock:^id(FSNConnection *c, NSError **error) {
//                    return [c.responseData dictionaryFromJSONWithError:error];
//                }
//           completionBlock:^(FSNConnection *json) {
//               if (json.didSucceed) {
//                   NSDictionary *dictionary = (NSDictionary *)json.parseResult;
//                   
//                   NSArray* messages = [dictionary objectForKey:@"messages"];
//                   NSDictionary *lastMessage = messages.firstObject;
//                   
//                   NSDictionary* message = [lastMessage objectForKey:@"message"];
//                   NSArray* results = [message objectForKey:@"results"];
//                   
//                   NSDictionary *availability = results.firstObject;
//                   
//                   if ((bool)[availability objectForKey:@"isAvailable"]) {
//                       [self updateStatus];
//                   } else {
//                       dispatch_async(dispatch_get_main_queue(), ^{
//                           [self.activityHUD dismissWithText:@"no agent is currently online." delay:0.7 success:NO];
//                       });
//                   }
//               } else {
//                   [self.activityHUD dismissWithText:@"can not connect." delay:0.7 success:NO];
//               }
//           } progressBlock:^(FSNConnection *c) {}];
//    [connection start];
//}



//- (void) updateStatusX {
//    
//    if (_statusResolved) {
//        return;
//    }
//    
//    [self.activityHUD showWithText:@"waiting for an agent..." shimmering:YES];
//    FSNConnection *connection =
//    [FSNConnection withUrl:[[NSURL alloc] initWithString:Messages_path]
//                    method:FSNRequestMethodGET
//                   headers:[LiveAgentApi getHeaders]
//                parameters:nil
//                parseBlock:^id(FSNConnection *c, NSError **error) {
//                    return [c.responseData dictionaryFromJSONWithError:error];
//                }
//           completionBlock:^(FSNConnection *json) {
//               if (json.didSucceed) {
//                   NSDictionary *dictionary = (NSDictionary *)json.parseResult;
//                   
//                   NSArray* messages = [dictionary objectForKey:@"messages"];
//                   NSDictionary *lastMessage = messages.firstObject;
//                   
//                   NSLog(@"%@", [lastMessage objectForKey:@"type"]);
//                   
//                   if ([[lastMessage objectForKey:@"type"]  isEqual: @"ChatRequestSuccess"]) {
//                       _requestStatus.text = @"ChatRequestSuccess";
//                   }
//                   
//                   if ([[lastMessage objectForKey:@"type"]  isEqual: @"ChatEstablished"]) {
//                       [self.activityHUD dismiss];
//                       _statusResolved = true;
//                       
//                       NSDictionary *message  =[lastMessage objectForKey:@"message"];
//                       LiveAgentApi.agentName =[message objectForKey:@"name"];
//                       LiveAgentApi.agentId   =[message objectForKey:@"userId"];
//                       
//                       [self performSegueWithIdentifier:@"ChatViewController" sender:self];
//                   }
//                   
//                   if ([[lastMessage objectForKey:@"type"]  isEqual: @"QueueUpdate"]) {
//                       [self.activityHUD dismiss];
//                       [self.activityHUD showWithProgress];
//                   }
//                   
//                   if ([[lastMessage objectForKey:@"type"]  isEqual: @"ChatRequestFail"]) {
//                       _statusResolved = true;
//                       
//                       [self.activityHUD dismissWithText:@"chat request failed." delay:0.7 success:NO];
//                   }
//                   
//                   [self updateStatus];
//               }else if (json.httpResponse.statusCode == 503){
//                   //[self ResyncSession];
//               } else {
//                   [self updateStatus];
//               }
//           } progressBlock:^(FSNConnection *c) {}];
//    [connection start];
//}
//


//- (void) requestSessionx {
//    
//    NSDictionary* headers    = @{ X_LIVEAGENT_SESSION_KEY : @"",
//                                  X_LIVEAGENT_AFFINITY    : @"null",
//                                  X_LIVEAGENT_SEQUENCE    : @"null" ,
//                                  X_LIVEAGENT_API_VERSION : API_V
//                                  };
//    
//    FSNConnection *connection =
//    [FSNConnection withUrl:[[NSURL alloc] initWithString:SessionId_path]
//                    method:FSNRequestMethodGET
//                   headers:headers
//                parameters:nil
//                parseBlock:^id(FSNConnection *c, NSError **error) {
//                    return [c.responseData dictionaryFromJSONWithError:error];
//                }
//           completionBlock:^(FSNConnection *json) {
//               if (json.didSucceed) {
//                   NSDictionary *dictionary = (NSDictionary *)json.parseResult;
//                   
//                   LiveAgentApi.sessionId = [dictionary objectForKey:@"id"];
//                   LiveAgentApi.sessionKey = [dictionary objectForKey:@"key"];
//                   LiveAgentApi.sessionAffinityToken= [dictionary objectForKey:@"affinityToken"];
//                   
//                   LiveAgentApi.sessionSequence = [NSString stringWithFormat:@"%d", 2];
//                   
//                   //LiveAgentApi.sessionSequence = [NSString stringWithFormat:@"%d", LiveAgentApi.sessionSequence.intValue + 1];
//                   [self requestChat];
//               }else {
//                   _requestStatus.text = @"can not connect to server.";
//               }
//           } progressBlock:^(FSNConnection *c) {}];
//    [connection start];
//}


//- (void) requestChatx {
//    
//    NSDictionary *parameters;
//    
//    if (LiveAgentApi.agentId.length > 0)
//    {
//        parameters = @{    Param_SessionId          :LiveAgentApi.sessionId,
//                           Param_OrganizationId     :ORG_ID,
//                           Param_DeploymentId       :DEPLOYEMENT_ID,
//                           Param_ButtonId           :BUTTON_ID,
//                           Param_AgentId            :LiveAgentApi.agentId,
//                           Param_UserAgent          :USER_AGENT,
//                           Param_Language           :LANG,
//                           Param_ScreenResolution   :SCREEN_RES,
//                           Param_VisitorName        :LiveAgentApi.clientName,
//                           Param_PrechatDetails     :@[],
//                           Param_PrechatEntities    :@[],
//                           Param_ReceiveQueueUpdates:@YES,
//                           Param_IsPost             :@YES
//                           };
//    }else {
//        parameters = @{    Param_SessionId          :LiveAgentApi.sessionId,
//                           Param_OrganizationId     :ORG_ID,
//                           Param_DeploymentId       :DEPLOYEMENT_ID,
//                           Param_ButtonId           :BUTTON_ID,
//                           Param_UserAgent          :USER_AGENT,
//                           Param_Language           :LANG,
//                           Param_ScreenResolution   :SCREEN_RES,
//                           Param_VisitorName        :LiveAgentApi.clientName,
//                           Param_PrechatDetails     :@[],
//                           Param_PrechatEntities    :@[],
//                           Param_ReceiveQueueUpdates:@YES,
//                           Param_IsPost             :@YES
//                           };
//    }
//    
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    
//    AFJSONRequestSerializer *serializer = [AFJSONRequestSerializer serializer];
//    [serializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//    [serializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
//    manager.requestSerializer = serializer;
//    
//    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
//    
//    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",nil];
//    manager.responseSerializer = [AFJSONResponseSerializer serializer];
//    
//    [manager.requestSerializer setValue:LiveAgentApi.sessionKey forHTTPHeaderField:X_LIVEAGENT_SESSION_KEY];
//    [manager.requestSerializer setValue:@"null" forHTTPHeaderField:X_LIVEAGENT_AFFINITY];
//    [manager.requestSerializer setValue:@"1" forHTTPHeaderField:X_LIVEAGENT_SEQUENCE];
//    [manager.requestSerializer setValue:API_V forHTTPHeaderField:X_LIVEAGENT_API_VERSION];
//    
//    [manager POST:ChasitorInit_path parameters:parameters progress:nil
//          success:^(NSURLSessionDataTask *task, id responseObject) {
//              
//              LiveAgentApi.hasEnded = false;
//              [self checkAvailability];
//          } failure:^(NSURLSessionDataTask *task, NSError *error) {
//              
//              if (task.response.statusCode == 200 || task.response.statusCode == 204) {
//                  LiveAgentApi.hasEnded = false;
//                  [self checkAvailability];
//              } else {
//                  [self.activityHUD showWithText:@"failed to connect" shimmering:YES];
//                  [self.activityHUD dismissWithText:@"failed to connect" delay:3 success:NO];
//                  
//                  LiveAgentApi.agentName = @"";
//                  LiveAgentApi.agentId   = @"";
//                  
//                  NSString* errResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
//                  
//                  NSLog(@"Error: %@", error);
//                  NSLog(@"response %@",errResponse);
//                  NSLog(@"response code %ld",task.response.statusCode);
//              }
//          }];
//}





//- (void) requestChatX {
//
//    NSDictionary *parameters;
//
//    if (LiveAgentApi.agentId.length > 0)
//    {
//        parameters = @{    Param_SessionId          :LiveAgentApi.sessionId,
//                           Param_OrganizationId     :ORG_ID,
//                           Param_DeploymentId       :DEPLOYEMENT_ID,
//                           Param_ButtonId           :BUTTON_ID,
//                           Param_AgentId            :LiveAgentApi.agentId,
//                           Param_UserAgent          :USER_AGENT,
//                           Param_Language           :LANG,
//                           Param_ScreenResolution   :SCREEN_RES,
//                           Param_VisitorName        :LiveAgentApi.clientName,
//                           Param_PrechatDetails     :@[],
//                           Param_PrechatEntities    :@[],
//                           Param_ReceiveQueueUpdates:@YES,
//                           Param_IsPost             :@YES
//                     };
//    }else {
//        parameters = @{    Param_SessionId          :LiveAgentApi.sessionId,
//                           Param_OrganizationId     :ORG_ID,
//                           Param_DeploymentId       :DEPLOYEMENT_ID,
//                           Param_ButtonId           :BUTTON_ID,
//                           Param_UserAgent          :USER_AGENT,
//                           Param_Language           :LANG,
//                           Param_ScreenResolution   :SCREEN_RES,
//                           Param_VisitorName        :LiveAgentApi.clientName,
//                           Param_PrechatDetails     :@[],
//                           Param_PrechatEntities    :@[],
//                           Param_ReceiveQueueUpdates:@YES,
//                           Param_IsPost             :@YES
//                     };
//    }
//
//    NSError *jsonSerializationError = nil;
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:&jsonSerializationError];
//
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:ChasitorInit_path]];
//    [request setHTTPMethod:@"POST"];
//    [request setHTTPBody:jsonData];
//    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//
//    [request setValue:LiveAgentApi.sessionKey forHTTPHeaderField:X_LIVEAGENT_SESSION_KEY];
//    [request setValue:@"null" forHTTPHeaderField:X_LIVEAGENT_AFFINITY];
//    [request setValue:@"1" forHTTPHeaderField:X_LIVEAGENT_SEQUENCE];
//    [request setValue:API_V forHTTPHeaderField:X_LIVEAGENT_API_VERSION];
//
//    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue new] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
//     {
//         if (response. ==  200 || response.statusCode ==  204){
//             LiveAgentApi.hasEnded = false;
//             [self checkAvailability];
//         }
//         else
//         {
//             NSLog(@"there was a download error %@", error);
//
//             [self.activityHUD showWithText:@"failed to connect" shimmering:YES];
//             [self.activityHUD dismissWithText:@"failed to connect" delay:3 success:NO];
//
//             LiveAgentApi.agentName = @"";
//             LiveAgentApi.agentId   = @"";
//
//             NSLog(@"Error: %@", error);
//             NSLog(@"response %@",response);
//             NSLog(@"response code %ld",response.statusCode);
//         }
//     }];
//}







//- (void) requestChatFs {
//    
//    NSDictionary* headers    = @{ X_LIVEAGENT_SESSION_KEY : @"",
//                                  X_LIVEAGENT_AFFINITY    :@"null",
//                                  X_LIVEAGENT_SEQUENCE    : @"null" ,
//                                  X_LIVEAGENT_API_VERSION : API_V
//                                  };
//    
//    NSDictionary *parameters = @{    Param_SessionId          :@"",
//                                     Param_OrganizationId     :ORG_ID,
//                                     Param_DeploymentId       :DEPLOYEMENT_ID,
//                                     Param_ButtonId           :BUTTON_ID,
//                                     Param_UserAgent          :USER_AGENT,
//                                     Param_Language           :LANG,
//                                     Param_ScreenResolution   :SCREEN_RES,
//                                     Param_VisitorName        :@"Test Visitor",
//                                     Param_PrechatDetails     :@[],
//                                     Param_PrechatEntities    :@[],
//                                     Param_ReceiveQueueUpdates:@YES,
//                                     Param_IsPost             :@YES
//                                     };
//    NSError *error;
//    NSData *data = [NSJSONSerialization dataWithJSONObject:parameters
//                                                   options:NSJSONWritingPrettyPrinted
//                                                     error:&error];
//    NSString *jsonData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    
//    NSLog(@"POST Json : %@", parameters);
//    NSLog(@"POST Json : %@", jsonData);
//    
//    FSNConnection *connection =
//    [FSNConnection withUrl:[[NSURL alloc] initWithString:ChasitorInit_path]
//                    method:FSNRequestMethodPOST
//                   headers:headers
//                parameters:parameters
//                parseBlock:^id(FSNConnection *c, NSError **error) {
//                    return [c.responseData dictionaryFromJSONWithError:error];
//                }
//           completionBlock:^(FSNConnection *jsonResponse) {
//               if (jsonResponse.didSucceed) {
//                   NSDictionary *dictionary = (NSDictionary *)jsonResponse.parseResult;
//                                  }else {
//                   NSLog(@"Http Response %@",jsonResponse.httpResponse);
//                   NSLog(@"Http Response %@",jsonResponse.responseData.stringFromUTF8);
//               }
//           } progressBlock:^(FSNConnection *c) {}];
//    
//    [connection start];
//}



@end
