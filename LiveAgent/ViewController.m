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
#import "LiveAgentApi.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextField *chatBox;
- (IBAction)startChat:(UIButton *)sender;
- (IBAction)chatSend:(id)sender;
- (IBAction)showChatView:(id)sender;


@property NSString* sessionId;
@property NSString* sessionKey;
@property NSString* sessionAffinityToken;
@property NSString* sessionSequence;
@property BOOL*     hasEnded;

@property NSArray* messages;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.sessionAffinityToken = @"null";
    self.sessionSequence    = @"1";
    self.hasEnded = false;
    
    _messages = @[];
    
    LiveAgentApi.sessionKey = @"";
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
                   
                   _sessionSequence = [NSString stringWithFormat:@"%d", _sessionSequence.intValue + 1];
                   [self requestChat];
               }
           } progressBlock:^(FSNConnection *c) {}];
    [connection start];
}

- (void) requestChat {
    
    NSDictionary *parameters = @{    Param_SessionId          :self.sessionId,
                                     Param_OrganizationId     :ORG_ID,
                                     Param_DeploymentId       :DEPLOYEMENT_ID,
                                     Param_ButtonId           :BUTTON_ID,
                                     Param_UserAgent          :USER_AGENT,
                                     Param_Language           :LANG,
                                     Param_ScreenResolution   :SCREEN_RES,
                                     Param_VisitorName        :@"Customer 1",
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
                  
                   NSArray* messages = [dictionary objectForKey:@"messages"];
                   NSDictionary *lastMessage = messages.firstObject;
                   
                   NSLog(@"%@", [lastMessage objectForKey:@"type"]);
                   
                   if ([[lastMessage objectForKey:@"type"]  isEqual: @"ChatRequestSuccess"]) {
                       [self requestMessages];
                       return;
                   }
                   
                   if ([[lastMessage objectForKey:@"type"]  isEqual: @"ChatEstablished"]) {
                       [self requestMessages];
                       return;
                   }
                   
                   if ([[lastMessage objectForKey:@"type"]  isEqual: @"ChatRequestFail"]) {
                       
                       //failed do something
                       return;
                   }
                   
                   if ([[lastMessage objectForKey:@"type"]  isEqual: @"ChatMessage"]) {
                       NSDictionary *ChatMessage = [lastMessage objectForKey:@"message"];
                       NSString *chat = [ChatMessage objectForKey:@"text"];
                       
                       NSLog(@"New Chat message : %@" , chat);
                   }
                   
                   if ([[lastMessage objectForKey:@"type"]  isEqual: @"AgentTyping"]) {
                       NSLog(@"Chat AgentTyping");
                   }
                   
                   if ([[lastMessage objectForKey:@"type"]  isEqual: @"AgentNotTyping"]) {
                       NSLog(@"Chat AgentNotTyping");
                   }
                   
                   if ([[lastMessage objectForKey:@"type"]  isEqual: @"ChatEnd"]) {
                       NSLog(@"Chat end by agent");
                   }
                   
                   if (!self.hasEnded) {
                       [self requestMessages];
                   }
               }else if (json.httpResponse.statusCode == 503 && !self.hasEnded){
                   [self ResyncSession];
               } else {
                   if (!self.hasEnded) {
                       [self requestMessages];
                   }
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

- (void) pushMessage:(NSString *)chatMessage {
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
    [manager.requestSerializer setValue:self.sessionAffinityToken forHTTPHeaderField:X_LIVEAGENT_AFFINITY];
    [manager.requestSerializer setValue:self.sessionSequence forHTTPHeaderField:X_LIVEAGENT_SEQUENCE];
    [manager.requestSerializer setValue:API_V forHTTPHeaderField:X_LIVEAGENT_API_VERSION];
    
    [manager POST:ChatMessage_path parameters:@{@"text":chatMessage} progress:nil
          success:^(NSURLSessionDataTask *task, id responseObject){
              _sessionSequence = [NSString stringWithFormat:@"%d", _sessionSequence.intValue + 1];
          } failure:^(NSURLSessionDataTask *task, NSError *error){
              if (task.response.statusCode == 200 || task.response.statusCode == 204){
                  _sessionSequence = [NSString stringWithFormat:@"%d", _sessionSequence.intValue + 1];
              } else if (task.response.statusCode == 503) {
                  [self ResyncSession];
              } else {
                  NSString* errResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
                  
                  NSLog(@"Error: %@", error);
                  NSLog(@"response %@",errResponse);
                  NSLog(@"response code %ld",task.response.statusCode);
              }
          }];
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

- (IBAction)chatSend:(id)sender {
    [self pushMessage:_chatBox.text];
}

- (IBAction)showChatView:(id)sender {
}
@end
