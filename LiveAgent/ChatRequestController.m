//
//  ChatRequestController.m
//  LiveAgent
//
//  Created by Halid Cisse on 6/15/16.
//  Copyright © 2016 Halid Cisse. All rights reserved.
//

#import "ChatRequestController.h"
#import "JSQMessages.h"
#import "LiveAgentApi.h"
#import <FSNetworking/FSNConnection.h>
#import "Constants.h"
#import "AFNetworking/AFNetworking.h"

@interface ChatRequestController ()

- (IBAction)requestChat:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *requestStatus;

@end

@implementation ChatRequestController

bool statusResolved;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUp];
}

- (void)viewDidAppear:(BOOL)animated{
    LiveAgentApi.hasEnded = true;
    statusResolved = false;
}

- (void) setUp {
    
    self.title             = @"Support client";
    
    LiveAgentApi.messages  = [[NSMutableArray alloc] init];
    
    LiveAgentApi.sessionKey           = @"";
    LiveAgentApi.sessionAffinityToken = @"null";
    LiveAgentApi.sessionSequence      = @"1";
    LiveAgentApi.hasEnded             = false;
    LiveAgentApi.messages             = [[NSMutableArray alloc] init];
}

- (void) requestSession {
    
    NSDictionary* headers    = @{ X_LIVEAGENT_SESSION_KEY : @"",
                                  X_LIVEAGENT_AFFINITY    : @"null",
                                  X_LIVEAGENT_SEQUENCE    : @"null" ,
                                  X_LIVEAGENT_API_VERSION : API_V
                                  };
    
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
                   
                   LiveAgentApi.sessionId = [dictionary objectForKey:@"id"];
                   LiveAgentApi.sessionKey = [dictionary objectForKey:@"key"];
                   LiveAgentApi.sessionAffinityToken= [dictionary objectForKey:@"affinityToken"];
                   
                   LiveAgentApi.sessionSequence = [NSString stringWithFormat:@"%d", LiveAgentApi.sessionSequence.intValue + 1];
                   [self requestChat];
               }else {
                   _requestStatus.text = @"can not connect to server.";
               }
           } progressBlock:^(FSNConnection *c) {}];
    [connection start];
}

- (void) requestChat {
    
    NSDictionary *parameters = @{    Param_SessionId          :LiveAgentApi.sessionId,
                                     Param_OrganizationId     :ORG_ID,
                                     Param_DeploymentId       :DEPLOYEMENT_ID,
                                     Param_ButtonId           :BUTTON_ID,
                                     Param_UserAgent          :USER_AGENT,
                                     Param_Language           :LANG,
                                     Param_ScreenResolution   :SCREEN_RES,
                                     Param_VisitorName        :@"Customer",
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
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    AFJSONRequestSerializer *serializer = [AFJSONRequestSerializer serializer];
    [serializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [serializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    manager.requestSerializer = serializer;
    
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",nil];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    //    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    
    [manager.requestSerializer setValue:LiveAgentApi.sessionKey forHTTPHeaderField:X_LIVEAGENT_SESSION_KEY];
    [manager.requestSerializer setValue:@"null" forHTTPHeaderField:X_LIVEAGENT_AFFINITY];
    [manager.requestSerializer setValue:@"1" forHTTPHeaderField:X_LIVEAGENT_SEQUENCE];
    [manager.requestSerializer setValue:API_V forHTTPHeaderField:X_LIVEAGENT_API_VERSION];
    
    [manager POST:ChasitorInit_path parameters:parameters progress:nil
          success:^(NSURLSessionDataTask *task, id responseObject) {
              LiveAgentApi.hasEnded = false;
              [self checkAvailability];
          } failure:^(NSURLSessionDataTask *task, NSError *error) {
              
              if (task.response.statusCode == 200 || task.response.statusCode == 204) {
                  LiveAgentApi.hasEnded = false;
                  [self checkAvailability];
              } else {
                  NSString* errResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
                  
                  NSLog(@"Error: %@", error);
                  NSLog(@"response %@",errResponse);
                  NSLog(@"response code %ld",task.response.statusCode);
              }
          }];
}

- (void) updateStatus {
    
    if (statusResolved) {
        return;
    }
    
    FSNConnection *connection =
    [FSNConnection withUrl:[[NSURL alloc] initWithString:Messages_path]
                    method:FSNRequestMethodGET
                   headers:[LiveAgentApi getHeaders]
                parameters:nil
                parseBlock:^id(FSNConnection *c, NSError **error) {
                    return [c.responseData dictionaryFromJSONWithError:error];
                }
           completionBlock:^(FSNConnection *json) {
               if (json.didSucceed) {
                   NSDictionary *dictionary = (NSDictionary *)json.parseResult;
                   
                   NSArray* messages = [dictionary objectForKey:@"messages"];
                   NSDictionary *lastMessage = messages.firstObject;
                   
                   NSLog(@"%@", [lastMessage objectForKey:@"type"]);
                   
                   if ([[lastMessage objectForKey:@"type"]  isEqual: @"ChatRequestSuccess"]) {
                       _requestStatus.text = @"ChatRequestSuccess";
                   }
                   
                   if ([[lastMessage objectForKey:@"type"]  isEqual: @"ChatEstablished"]) {
                       statusResolved = true;
                       
                       [self performSegueWithIdentifier:@"ChatViewController" sender:self];
                   }
                   
                   if ([[lastMessage objectForKey:@"type"]  isEqual: @"ChatRequestFail"]) {
                       statusResolved = true;
                       
                       _requestStatus.text = @"ChatRequestFail";
                   }
                   
                   [self updateStatus];
               }else if (json.httpResponse.statusCode == 503){
                   //[self ResyncSession];
               } else {
                   [self updateStatus];
               }
           } progressBlock:^(FSNConnection *c) {}];
    [connection start];
}

- (void) checkAvailability {
    FSNConnection *connection =
    [FSNConnection withUrl:[[NSURL alloc] initWithString:Availability_path]
                    method:FSNRequestMethodGET
                   headers:@{ X_LIVEAGENT_API_VERSION : API_V}
                parameters:@{
                              @"org_id"           : ORG_ID,
                              @"deployment_id"    : DEPLOYEMENT_ID,
                              @"Availability.ids" : BUTTON_ID
                            }
                parseBlock:^id(FSNConnection *c, NSError **error) {
                    return [c.responseData dictionaryFromJSONWithError:error];
                }
           completionBlock:^(FSNConnection *json) {
               if (json.didSucceed) {
                   NSDictionary *dictionary = (NSDictionary *)json.parseResult;
                   
                   NSArray* messages = [dictionary objectForKey:@"messages"];
                   NSDictionary *lastMessage = messages.firstObject;
                   
                   NSArray* events = [lastMessage objectForKey:@"message"];
                   NSDictionary *results = events.firstObject;
                   
                   bool isAvailable = [results objectForKey:@"isAvailable"];
                   
                   if ((bool)[lastMessage objectForKey:@"isAvailable"] == true) {
                       [self updateStatus];
                   } else {
                       _requestStatus.text = @"no agent is currently online.";
                   }
               } else {
                   _requestStatus.text = @"can not connect.";
               }
           } progressBlock:^(FSNConnection *c) {}];
    [connection start];
}

- (IBAction)requestChat:(id)sender {
    [self requestSession];
}

 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  
 }


@end
