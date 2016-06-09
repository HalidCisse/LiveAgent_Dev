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

@interface ViewController ()

@property NSString* sessionId;
@property NSString* sessionKey;
@property NSString* sessionAffinityToken;
@property NSString* liveAgentSequence;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self GetSessionId];
}

- (void)GetSessionId {
    
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
               NSDictionary *dictionary = (NSDictionary *)json.parseResult;
               
               _sessionId = [dictionary objectForKey:@"id"];
               _sessionKey = [dictionary objectForKey:@"key"];
               _sessionAffinityToken= [dictionary objectForKey:@"affinityToken"];
               
               [self chatRequest];
           } progressBlock:^(FSNConnection *c) {}];
    [connection start];
}

- (void) chatRequest {
    
    NSDictionary* headers    = [NSDictionary dictionaryWithObjectsAndKeys:
                                self.sessionKey, X_LIVEAGENT_SESSION_KEY,
                                self.sessionAffinityToken, X_LIVEAGENT_AFFINITY,
                                @"null", X_LIVEAGENT_SEQUENCE,
                                API_V, X_LIVEAGENT_API_VERSION,
                                nil];
    
    FSNConnection *connection =
    [FSNConnection withUrl:[[NSURL alloc] initWithString:ChasitorInit_path]
                    method:FSNRequestMethodGET
                   headers:headers
                parameters:nil
                parseBlock:^id(FSNConnection *c, NSError **error) {
                    return [c.responseData dictionaryFromJSONWithError:error];
                }
           completionBlock:^(FSNConnection *json) {
               if (json.didSucceed) {
                   
               }
           } progressBlock:^(FSNConnection *c) {}];
    [connection start];
}


@end
