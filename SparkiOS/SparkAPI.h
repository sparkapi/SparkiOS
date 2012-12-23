//
//  SparkAPI.h
//  SparkiOS
//
//  Created by David Ragones on 12/17/12.
//
//  Copyright (c) 2013 Financial Business Systems, Inc. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import <Foundation/Foundation.h>

@interface SparkAPI : NSObject

@property (strong, nonatomic) NSString *openIdSparkId;
@property (strong, nonatomic) NSString *oauthAccessToken;
@property (strong, nonatomic) NSString *oauthRefreshToken;

// authenticate

+ (NSURL*)getSparkOpenIdURL;
+ (NSURL*)getSparkOpenIdAttributeExchangeURL;
+ (NSURL*)getSparkOpenIdLogoutURL;
+ (NSURL*)getSparkHybridOpenIdURL;

+ (BOOL) hybridAuthenticate:(NSURLRequest*)request
             success:(void(^)(SparkAPI* sparkAPI))success
             failure:(void(^)(NSString* openIdMode, NSString* openIdError, NSError *httpError))failure;

+ (BOOL) openIdAuthenticate:(NSURLRequest*)request
                         success:(void(^)(SparkAPI* sparkAPI, NSDictionary* parameters))success
                         failure:(void(^)(NSString* openIdMode, NSString* openIdError))failure;

// interface

- initWithAccessToken:(NSString*)accessToken
         refreshToken:(NSString*)refreshToken
               openId:(NSString*)openIdSparkId;

- (void) get:(NSString*)apiCommand
  parameters:(NSDictionary*)parameters
     success:(void(^)(NSArray *resultsJSON))success
     failure:(void(^)(NSInteger sparkErrorCode,
                      NSString* sparkErrorMessage,
                      NSError *httpError))failure;

- (void) post:(NSString*)apiCommand
   parameters:(NSDictionary*)parameters
      success:(void(^)(NSArray *resultsJSON))success
      failure:(void(^)(NSInteger sparkErrorCode,
                       NSString* sparkErrorMessage,
                       NSError *httpError))failure;

- (void) put:(NSString*)apiCommand
  parameters:(NSDictionary*)parameters
     success:(void(^)(NSArray *resultsJSON))success
     failure:(void(^)(NSInteger sparkErrorCode,
                      NSString* sparkErrorMessage,
                      NSError *httpError))failure;

- (void) delete:(NSString*)apiCommand
     parameters:(NSDictionary*)parameters
        success:(void(^)(NSArray *resultsJSON))success
        failure:(void(^)(NSInteger sparkErrorCode,
                 NSString* sparkErrorMessage,
                 NSError *httpError))failure;

- (void) api:(NSString*)apiCommand
  httpMethod:(NSString*)httpMethod
  parameters:(NSDictionary*)parameters
     success:(void(^)(NSArray *resultsJSON))success
     failure:(void(^)(NSInteger sparkErrorCode,
                      NSString* sparkErrorMessage,
                      NSError *httpError))failure;

@end
