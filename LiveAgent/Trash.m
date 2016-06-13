//
//  Trash.m
//  LiveAgent
//
//  Created by Halid Cisse on 6/13/16.
//  Copyright © 2016 Halid Cisse. All rights reserved.
//

#import "Trash.h"
#import "Constants.h"
#import <FSNetworking/FSNConnection.h>

@implementation Trash

- (void) requestChatFs {
    
    NSDictionary* headers    = @{ X_LIVEAGENT_SESSION_KEY : @"",
                                  X_LIVEAGENT_AFFINITY    :@"null",
                                  X_LIVEAGENT_SEQUENCE    : @"null" ,
                                  X_LIVEAGENT_API_VERSION : API_V
                                  };
    
    NSDictionary *parameters = @{    Param_SessionId          :@"",
                                     Param_OrganizationId     :ORG_ID,
                                     Param_DeploymentId       :DEPLOYEMENT_ID,
                                     Param_ButtonId           :BUTTON_ID,
                                     Param_UserAgent          :USER_AGENT,
                                     Param_Language           :LANG,
                                     Param_ScreenResolution   :SCREEN_RES,
                                     Param_VisitorName        :@"Test Visitor",
                                     Param_PrechatDetails     :@[],
                                     Param_PrechatEntities    :@[],
                                     Param_ReceiveQueueUpdates:@YES,
                                     Param_IsPost             :@YES
                                     };
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:parameters
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:&error];
    NSString *jsonData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSLog(@"POST Json : %@", parameters);
    NSLog(@"POST Json : %@", jsonData);
    
    FSNConnection *connection =
    [FSNConnection withUrl:[[NSURL alloc] initWithString:ChasitorInit_path]
                    method:FSNRequestMethodPOST
                   headers:headers
                parameters:parameters
                parseBlock:^id(FSNConnection *c, NSError **error) {
                    return [c.responseData dictionaryFromJSONWithError:error];
                }
           completionBlock:^(FSNConnection *jsonResponse) {
               if (jsonResponse.didSucceed) {
                   NSDictionary *dictionary = (NSDictionary *)jsonResponse.parseResult;
                                  }else {
                   NSLog(@"Http Response %@",jsonResponse.httpResponse);
                   NSLog(@"Http Response %@",jsonResponse.responseData.stringFromUTF8);
               }
           } progressBlock:^(FSNConnection *c) {}];
    
    [connection start];
}



@end
