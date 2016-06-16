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
#import <CCActivityHUD/CCActivityHUD.h>
#import "ChatViewController.h"

@interface ChatRequestController ()

- (IBAction)requestChat:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *requestStatus;
@property bool statusResolved;
@property CCActivityHUD *activityHUD;

@end

@implementation ChatRequestController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUp];
}

- (void)viewDidAppear:(BOOL)animated{
    LiveAgentApi.hasEnded = true;
    _statusResolved = false;
}

- (void) setUp {
    
    self.title             = @"Support client";
    
    LiveAgentApi.messages  = [[NSMutableArray alloc] init];
    
    LiveAgentApi.sessionKey           = @"";
    LiveAgentApi.sessionAffinityToken = @"null";
    LiveAgentApi.sessionSequence      = @"1";
    LiveAgentApi.hasEnded             = false;
    LiveAgentApi.messages             = [[NSMutableArray alloc] init];
    
    _activityHUD = [CCActivityHUD new];
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
    
    if (_statusResolved) {
        return;
    }
    
    [self.activityHUD showWithText:@"waiting for an agent..." shimmering:YES];
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
                       [self.activityHUD dismiss];
                       _statusResolved = true;
                       
                       [self performSegueWithIdentifier:@"ChatViewController" sender:self];
                   }
                   
                   if ([[lastMessage objectForKey:@"type"]  isEqual: @"QueueUpdate"]) {
                       [self.activityHUD dismiss];
                       [self.activityHUD showWithProgress];
                   }
                   
                   if ([[lastMessage objectForKey:@"type"]  isEqual: @"ChatRequestFail"]) {
                       _statusResolved = true;
                       
                       [self.activityHUD dismissWithText:@"chat request failed." delay:0.7 success:NO];
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
    
    [self.activityHUD showWithText:@"connecting..." shimmering:YES];
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
                   
                   NSDictionary* message = [lastMessage objectForKey:@"message"];
                   NSArray* results = [message objectForKey:@"results"];
                   
                   NSDictionary *availability = results.firstObject;
                   
                   if ((bool)[availability objectForKey:@"isAvailable"]) {
                       [self updateStatus];
                   } else {
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [self.activityHUD dismissWithText:@"no agent is currently online." delay:0.7 success:NO];
                       });
                   }
               } else {
                   [self.activityHUD dismissWithText:@"can not connect." delay:0.7 success:NO];
               }
           } progressBlock:^(FSNConnection *c) {}];
    [connection start];
}

- (IBAction)requestChat:(id)sender {
    [self requestSession];
}

- (void)didDismissModalControllerDelegate:(ChatViewController *)viewController{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ChatViewController"]) {
        UINavigationController *navigator = segue.destinationViewController;
        ChatViewController *chatView = (ChatViewController *)navigator.topViewController;
        chatView.delegateModal = self;
    }
}

@end
