//
//  ViewController.m
//  LiveAgent
//
//  Created by Halid Cisse on 6/9/16.
//  Copyright © 2016 Halid Cisse. All rights reserved.
//

#import "ViewController.h"
#import <FSNetworking/FSNConnection.h>
#import "Constants.h"
#import "AFNetworking/AFNetworking.h"

@interface ViewController ()

- (IBAction)startChat:(UIButton *)sender;


@property NSString* sessionId;
@property NSString* sessionKey;
@property NSString* sessionAffinityToken;
@property NSString* liveAgentSequence;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void) requestSession {
    
    NSDictionary* headers    = [NSDictionary dictionaryWithObjectsAndKeys:
                         @"", X_LIVEAGENT_SESSION_KEY,
                         @"null", X_LIVEAGENT_AFFINITY,
                         @"null", X_LIVEAGENT_SEQUENCE,
                         API_V, X_LIVEAGENT_API_VERSION,
                        nil];
    
    FSNConnection *connection =
    [FSNConnection withUrl:[[NSURL alloc] initWithString:SessionId_path]
                    method:FSNRequestMethodGET
                   headers:headers
                parameters:nil
                parseBlock:^id(FSNConnection *c, NSError **error) {
                    return [c.responseData dictionaryFromJSONWithError:error];
                }
           completionBlock:^(FSNConnection *json) {
               if (json.didSucceed) {
                   NSDictionary *dictionary = (NSDictionary *)json.parseResult;
                   
                   _sessionId = [dictionary objectForKey:@"id"];
                   _sessionKey = [dictionary objectForKey:@"key"];
                   _sessionAffinityToken= [dictionary objectForKey:@"affinityToken"];
                   
                   [self requestChat];
               }
           } progressBlock:^(FSNConnection *c) {}];
    [connection start];
}

- (void) requestChat {
    
    NSDictionary *parameters =@{     Param_SessionId       :self.sessionId,
                                     Param_OrganizationId  :ORG_ID,
                                     Param_DeploymentId    :DEPLOYEMENT_ID,
                                     Param_ButtonId        :BUTTON_ID,
                                     Param_UserAgent       :USER_AGENT,
                                     Param_Language        :LANG,
                                     Param_ScreenResolution:SCREEN_RES,
                                     @"visitorName"        :@"Test Visitor",
                                     @"prechatDetails"     :@{},
                                     @"prechatEntities"    :@{},
                                     @"receiveQueueUpdates":@"true",
                                     @"isPost"             :@"true"
                                 };
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    AFJSONRequestSerializer *serializer = [AFJSONRequestSerializer serializer];
    [serializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [serializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    manager.requestSerializer = serializer;
    
    [manager.requestSerializer setValue:self.sessionKey forHTTPHeaderField:X_LIVEAGENT_SESSION_KEY];
    [manager.requestSerializer setValue:@"null" forHTTPHeaderField:X_LIVEAGENT_AFFINITY];
    [manager.requestSerializer setValue:@"1" forHTTPHeaderField:X_LIVEAGENT_SEQUENCE];
    [manager.requestSerializer setValue:API_V forHTTPHeaderField:X_LIVEAGENT_API_VERSION];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager POST:ChasitorInit_path parameters:parameters progress:nil
          success:^(NSURLSessionDataTask *task, id responseObject) {
              NSError* error;
              NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                   options:kNilOptions
                                                                     error:&error];
          } failure:^(NSURLSessionDataTask *task, NSError *error) {
              
              NSLog(@"Error: %@", error);
          }];
}


- (IBAction)startChat:(UIButton *)sender {
    [self requestSession];
}
@end
