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
@property NSString* sessionSequence;
@property BOOL* hasEnded;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.sessionAffinityToken = @"null";
    self.sessionSequence    = @"null";
    self.hasEnded = false;
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
                   
                   _sessionId = [dictionary objectForKey:@"id"];
                   _sessionKey = [dictionary objectForKey:@"key"];
                   _sessionAffinityToken= [dictionary objectForKey:@"affinityToken"];
                   
                   [self requestChat];
               }
           } progressBlock:^(FSNConnection *c) {}];
    [connection start];
}

- (void) requestChat {
    
    NSDictionary *parameters =@{     Param_SessionId          :self.sessionId,
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
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    AFJSONRequestSerializer *serializer = [AFJSONRequestSerializer serializer];
    [serializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [serializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    manager.requestSerializer = serializer;
    
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",nil];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
//    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    
    [manager.requestSerializer setValue:self.sessionKey forHTTPHeaderField:X_LIVEAGENT_SESSION_KEY];
    [manager.requestSerializer setValue:@"null" forHTTPHeaderField:X_LIVEAGENT_AFFINITY];
    [manager.requestSerializer setValue:@"1" forHTTPHeaderField:X_LIVEAGENT_SEQUENCE];
    [manager.requestSerializer setValue:API_V forHTTPHeaderField:X_LIVEAGENT_API_VERSION];
    
    [manager POST:ChasitorInit_path parameters:parameters progress:nil
          success:^(NSURLSessionDataTask *task, id responseObject) {
              
              [self requestMessages];
//              NSError* error;
//              NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseObject
//                                                                   options:kNilOptions
//                                                                     error:&error];
              
          } failure:^(NSURLSessionDataTask *task, NSError *error) {
              
              if (task.response.statusCode == 200 || task.response.statusCode == 204) {
                  [self requestMessages];
              } else {
                  NSString* errResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
                  
                  NSLog(@"Error: %@", error);
                  NSLog(@"response %@",errResponse);
                  NSLog(@"response code %ld",task.response.statusCode);
              }
          }];
}

- (void) requestMessages {
    
    FSNConnection *connection =
    [FSNConnection withUrl:[[NSURL alloc] initWithString:Messages_path]
                    method:FSNRequestMethodGET
                   headers:[self getHeaders]
                parameters:nil
                parseBlock:^id(FSNConnection *c, NSError **error) {
                    return [c.responseData dictionaryFromJSONWithError:error];
                }
           completionBlock:^(FSNConnection *json) {
               if (json.didSucceed) {
                   NSDictionary *dictionary = (NSDictionary *)json.parseResult;
                   
                   _sessionSequence = [[dictionary objectForKey:@"sequence"] description];
                   NSArray* messages = [dictionary objectForKey:@"messages"];
                   NSDictionary *lastMessage = messages.firstObject;
                   
                   if ([[lastMessage objectForKey:@"type"]  isEqual: @"ChatRequestSuccess"]) {
                       [self requestMessages];
                       return;
                   }
                   
                   if ([[lastMessage objectForKey:@"type"]  isEqual: @"ChatMessage"]) {
                       NSDictionary *ChatMessage = [lastMessage objectForKey:@"message"];
                       NSString *chat = [ChatMessage objectForKey:@"text"];
                       
                       NSLog(@"Chat message : %@" , chat);
                   }
                   
                   //NSLog(@"Messages responses : %@" , dictionary);
                   if (!self.hasEnded) {
                       [self requestMessages];
                   }
               }else if (json.httpResponse.statusCode == 503 && !self.hasEnded){
                   [self ResyncSession];
               }
                   
           } progressBlock:^(FSNConnection *c) {}];
    [connection start];
}

- (void) ResyncSession{
    
    FSNConnection *connection =
    [FSNConnection withUrl:[[NSURL alloc] initWithString:ResyncSession_path]
                    method:FSNRequestMethodGET
                   headers:[self getHeaders]
                parameters:@{Param_SessionId : self.sessionId}
                parseBlock:^id(FSNConnection *c, NSError **error) {
                    return [c.responseData dictionaryFromJSONWithError:error];
                }
           completionBlock:^(FSNConnection *json) {
               if (json.didSucceed) {
                   NSDictionary *dictionary = (NSDictionary *)json.parseResult;
                   
                   if ([dictionary objectForKey:@"isValid"]) {
                       _sessionKey = [dictionary objectForKey:@"key"];
                       _sessionAffinityToken = [dictionary objectForKey:@"affinityToken"];
                       
                       [self requestMessages];
                   }
               }
           } progressBlock:^(FSNConnection *c) {}];
    [connection start];
}

- (NSDictionary *)getHeaders {
    return @{ X_LIVEAGENT_SESSION_KEY : self.sessionKey,
              X_LIVEAGENT_AFFINITY    : self.sessionAffinityToken,
              X_LIVEAGENT_SEQUENCE    : self.sessionSequence,
              X_LIVEAGENT_API_VERSION : API_V
              };
}

- (IBAction)startChat:(UIButton *)sender {
    [self requestSession];
}
@end
