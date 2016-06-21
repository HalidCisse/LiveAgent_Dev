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
#import "Constants.h"
#import <CCActivityHUD/CCActivityHUD.h>
#import "ChatViewController.h"
#import "AFNetworking.h"

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
    //LiveAgentApi.sessionSequence = @"1";
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
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager.requestSerializer setValue:@""     forHTTPHeaderField:X_LIVEAGENT_SESSION_KEY];
    [manager.requestSerializer setValue:@"null" forHTTPHeaderField:X_LIVEAGENT_AFFINITY];
    [manager.requestSerializer setValue:@"null" forHTTPHeaderField:X_LIVEAGENT_SEQUENCE];
    [manager.requestSerializer setValue:API_V   forHTTPHeaderField:X_LIVEAGENT_API_VERSION];
    
    [manager GET:SessionId_path parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        NSDictionary *dictionary = (NSDictionary *)responseObject;
        
        LiveAgentApi.sessionId   = [dictionary objectForKey:@"id"];
        LiveAgentApi.sessionKey  = [dictionary objectForKey:@"key"];
        LiveAgentApi.sessionAffinityToken = [dictionary objectForKey:@"affinityToken"];
        LiveAgentApi.sessionSequence      = [NSString stringWithFormat:@"%d", 2];
        
        [self requestChat];
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void) requestChat {

    NSDictionary *parameters;

    if (LiveAgentApi.agentId.length > 0)
    {
        parameters = @{    Param_SessionId          :LiveAgentApi.sessionId,
                           Param_OrganizationId     :ORG_ID,
                           Param_DeploymentId       :DEPLOYEMENT_ID,
                           Param_ButtonId           :BUTTON_ID,
                           Param_AgentId            :LiveAgentApi.agentId,
                           Param_UserAgent          :USER_AGENT,
                           Param_Language           :LANG,
                           Param_ScreenResolution   :SCREEN_RES,
                           Param_VisitorName        :LiveAgentApi.clientName,
                           Param_PrechatDetails     :@[],
                           Param_PrechatEntities    :@[],
                           Param_ReceiveQueueUpdates:@YES,
                           Param_IsPost             :@YES
                           };
    }else {
        parameters = @{    Param_SessionId          :LiveAgentApi.sessionId,
                           Param_OrganizationId     :ORG_ID,
                           Param_DeploymentId       :DEPLOYEMENT_ID,
                           Param_ButtonId           :BUTTON_ID,
                           Param_UserAgent          :USER_AGENT,
                           Param_Language           :LANG,
                           Param_ScreenResolution   :SCREEN_RES,
                           Param_VisitorName        :LiveAgentApi.clientName,
                           Param_PrechatDetails     :@[],
                           Param_PrechatEntities    :@[],
                           Param_ReceiveQueueUpdates:@YES,
                           Param_IsPost             :@YES
                           };
    }

    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];

    AFJSONRequestSerializer *serializer = [AFJSONRequestSerializer serializer];
    [serializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [serializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    manager.requestSerializer = serializer;

    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];

    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",nil];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];

    [manager.requestSerializer setValue:LiveAgentApi.sessionKey forHTTPHeaderField:X_LIVEAGENT_SESSION_KEY];
    [manager.requestSerializer setValue:@"null" forHTTPHeaderField:X_LIVEAGENT_AFFINITY];
    [manager.requestSerializer setValue:@"1" forHTTPHeaderField:X_LIVEAGENT_SEQUENCE];
    [manager.requestSerializer setValue:API_V forHTTPHeaderField:X_LIVEAGENT_API_VERSION];

    [manager POST:ChasitorInit_path parameters:parameters progress:nil
          success:^(NSURLSessionDataTask *task, id responseObject) {

              LiveAgentApi.hasEnded = false;
              [self checkAvailability];
          }
          failure:^(NSURLSessionDataTask *task, NSError *error) {
              NSInteger statusCode = ((NSHTTPURLResponse*)task.response).statusCode;

              if (statusCode == 200 || statusCode == 204) {
                  LiveAgentApi.hasEnded = false;
                  [self checkAvailability];
              } else {
                  [self.activityHUD showWithText:@"failed to connect" shimmering:YES];
                  [self.activityHUD dismissWithText:@"failed to connect" delay:3 success:NO];

                  LiveAgentApi.agentName = @"";
                  LiveAgentApi.agentId   = @"";

                  NSString* errResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];

                  NSLog(@"Error: %@", error);
                  NSLog(@"response %@",errResponse);
                  NSLog(@"response code %ld",statusCode);
              }
          } ];
}

- (void) updateStatus {
    
    if (_statusResolved) {
        return;
    }
    
    [self.activityHUD showWithText:@"waiting for an agent..." shimmering:YES];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [LiveAgentApi fillHeaders:manager];
    
    [manager GET:Messages_path parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSDictionary *dictionary = (NSDictionary *)responseObject;
        
        NSArray* messages = [dictionary objectForKey:@"messages"];
        NSDictionary *lastMessage = messages.firstObject;
        
        NSLog(@"%@", [lastMessage objectForKey:@"type"]);
        
        if ([[lastMessage objectForKey:@"type"]  isEqual: @"ChatRequestSuccess"]) {
            _requestStatus.text = @"ChatRequestSuccess";
        }
        
        if ([[lastMessage objectForKey:@"type"]  isEqual: @"ChatEstablished"]) {
            [self.activityHUD dismiss];
            _statusResolved = true;
            
            NSDictionary *message  =[lastMessage objectForKey:@"message"];
            LiveAgentApi.agentName =[message objectForKey:@"name"];
            LiveAgentApi.agentId   =[message objectForKey:@"userId"];
            
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
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
        [self updateStatus];
    }];
}

- (void) checkAvailability {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activityHUD showWithText:@"connecting..." shimmering:YES];
    });
    
    AFHTTPSessionManager *request = [AFHTTPSessionManager manager];
    
    [request.requestSerializer setValue:API_V forHTTPHeaderField:X_LIVEAGENT_API_VERSION];
    
    [request GET:Availability_path parameters:@{
                                                @"org_id"           : ORG_ID,
                                                @"deployment_id"    : DEPLOYEMENT_ID,
                                                @"Availability.ids" : BUTTON_ID
                                                }
        progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSDictionary *dictionary = (NSDictionary *)responseObject;
        NSArray* messages = [dictionary objectForKey:@"messages"];
        NSDictionary *lastMessage = messages.firstObject;
        
        NSDictionary* message = [lastMessage objectForKey:@"message"];
        NSArray* results = [message objectForKey:@"results"];
        
        NSDictionary *availability = results.firstObject;
        
        if ((bool)[availability objectForKey:@"isAvailable"]) {
            [self updateStatus];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.activityHUD dismissWithText:@"no agent is currently online." delay:3 success:NO];
            });
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [self.activityHUD dismissWithText:@"can not connect." delay:0.7 success:NO];
    }];
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
