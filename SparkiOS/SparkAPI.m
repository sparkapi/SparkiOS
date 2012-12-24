//
//  SparkAPI.m
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

#import "SparkAPI.h"

#import "AFHTTPClient.h"
#import "SBJson.h"

#define SPARK_LOG_LEVEL_ERROR 4
#define SPARK_LOG_LEVEL_WARNING 3
#define SPARK_LOG_LEVEL_INFO 2
#define SPARK_LOG_LEVEL_FINE 1

@interface SparkAPI ()

@end

@implementation SparkAPI

// configuration ***************************************************************

static NSString* sparkClientId = @"<YOUR OAUTH2 CLIENT KEY>";
static NSString* sparkClientSecret = @"<YOUR OAUTH2 CLIENT SECRET>";
static NSString* sparkCallbackURL = @"https://sparkplatform.com/oauth2/callback";

// constants *******************************************************************

static NSString* sparkOpenIdURL = @"https://sparkplatform.com/openid";
static NSString* sparkOpenIdLogoutURL = @"https://sparkplatform.com/openid/logout";

static NSString* sparkAPIEndpoint = @"https://sparkapi.com/";
static NSString* sparkAPIVersion = @"/v1";

static NSString* sparkUserAgent = @"Spark iOS API 1.0";

static NSString* httpGet = @"GET";
static NSString* httpPost = @"POST";
static NSString* httpPut = @"PUT";
static NSString* httpDelete = @"DELETE";

// class vars ******************************************************************

static AFHTTPClient *httpClient;

// instance vars ***************************************************************

@synthesize oauthAccessToken, oauthRefreshToken, openIdSparkId, applicationName, logLevel;

// class interface *************************************************************

+(void) initialize
{
    @synchronized(self)
    {
        if(!httpClient)
        {
            httpClient = [[AFHTTPClient alloc] initWithBaseURL:
                                    [NSURL URLWithString:sparkAPIEndpoint]];
            [httpClient setDefaultHeader:@"User-Agent" value:sparkUserAgent];
            [httpClient setDefaultHeader:@"X-SparkApi-User-Agent" value:sparkUserAgent];
            httpClient.parameterEncoding = AFJSONParameterEncoding;
        }
    }
}

+ (NSString*)encodeURL:(NSString*)string
{
    return (__bridge NSString *)(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)string, NULL, CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"), CFStringConvertNSStringEncodingToEncoding(NSASCIIStringEncoding)));
}

+ (NSDictionary*)getParameterDictionary:(NSURL*)url
{
    NSArray *queryPairs = [[[[url absoluteString] componentsSeparatedByString:@"?"] lastObject] componentsSeparatedByString:@"&"];
    NSMutableDictionary *pairs = [NSMutableDictionary dictionary];
    for (NSString *queryPair in queryPairs) {
        NSArray *bits = [queryPair componentsSeparatedByString:@"="];
        if ([bits count] != 2) { continue; }
        
        NSString *key = [[bits objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *value = [[bits objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [pairs setObject:value forKey:key];
    }
    return pairs;
}

+ (NSString*)getSparkOpenIdURLString
{
    NSMutableString *urlString = [[NSMutableString alloc] init];
    [urlString appendString:sparkOpenIdURL];
    [urlString appendString:@"?openid.mode=checkid_setup"];
    [urlString appendString:@"&openid.spark.client_id="];
    [urlString appendString:[SparkAPI encodeURL:sparkClientId]];
    [urlString appendString:@"&openid.return_to="];
    [urlString appendString:[self encodeURL:sparkCallbackURL]];
    return urlString;
}

+ (NSURL*)getSparkOpenIdURL
{
    return [NSURL URLWithString:[self getSparkOpenIdURLString]];
}

+ (NSString*)getSparkOpenIdAttributeExchangeURLString
{
    NSMutableString *urlString = [[NSMutableString alloc] init];
    [urlString appendString:[self getSparkOpenIdURLString]];
    [urlString appendString:@"&openid.ax.mode=fetch_request"];
    [urlString appendFormat:@"&openid.ax.type.first_name=%@",[self encodeURL:@"http://openid.net/schema/namePerson/first"]];
    [urlString appendFormat:@"&openid.ax.type.last_name=%@",[self encodeURL:@"http://openid.net/schema/namePerson/last"]];
    [urlString appendFormat:@"&openid.ax.type.middle_name=%@",[self encodeURL:@"http://openid.net/schema/namePerson/middle"]];
    [urlString appendFormat:@"&openid.ax.type.friendly=%@",[self encodeURL:@"http://openid.net/schema/namePerson/friendly"]];
    [urlString appendFormat:@"&openid.ax.type.id=%@",[self encodeURL:@"http://openid.net/schema/person/guid"]];
    [urlString appendFormat:@"&openid.ax.type.email=%@",[self encodeURL:@"http://openid.net/schema/contact/internet/email"]];
    [urlString appendFormat:@"&openid.ax.required=%@",[self encodeURL:@"first_name,last_name,middle_name,friendly,id,email"]];
    return urlString;
}

+ (NSURL*)getSparkOpenIdAttributeExchangeURL
{
    return [NSURL URLWithString:[self getSparkOpenIdAttributeExchangeURLString]];
}

+ (NSURL*)getSparkHybridOpenIdURL
{
    NSMutableString *urlString = [[NSMutableString alloc] init];
    [urlString appendString:[self getSparkOpenIdURLString]];
    [urlString appendString:@"&openid.spark.combined_flow=true"];
    return [NSURL URLWithString:urlString];
}

+ (NSURL*)getSparkOpenIdLogoutURL
{
    return [NSURL URLWithString:sparkOpenIdLogoutURL];
}

+ (BOOL) hybridAuthenticate:(NSURLRequest*)request
                    success:(void(^)(SparkAPI* sparkAPI))success
                    failure:(void(^)(NSString* openIdMode, NSString* openIdError, NSError *httpError))failure
{
    NSDictionary *parameterDictionary = [self getParameterDictionary:request.URL];
    NSString* openIdMode = nil;
    NSString* openIdSparkCode = nil;
    if(parameterDictionary &&
       (openIdMode = [parameterDictionary objectForKey:@"openid.mode"]) &&
       [@"id_res" isEqualToString:openIdMode] &&
       (openIdSparkCode =[parameterDictionary objectForKey:@"openid.spark.code"]))
    {
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        [dictionary setObject:[SparkAPI encodeURL:sparkClientId] forKey:@"client_id"];
        [dictionary setObject:sparkClientSecret forKey:@"client_secret"];
        [dictionary setObject:@"authorization_code" forKey:@"grant_type"];
        [dictionary setObject:openIdSparkCode forKey:@"code"];
        [dictionary setObject:sparkCallbackURL forKey:@"redirect_uri"];
        
        [httpClient postPath:[NSString stringWithFormat:@"%@/oauth2/grant", sparkAPIVersion]
                  parameters:dictionary
                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                         NSDictionary* dictionary = [self getResponseJSON:responseObject];
                         SparkAPI *sparkAPI =
                         [[SparkAPI alloc] initWithAccessToken:[dictionary objectForKey:@"access_token"]
                                                  refreshToken:[dictionary objectForKey:@"refresh_token"]
                                                        openId:nil];
                         if(success)
                             success(sparkAPI);
                         
                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                         if(failure)
                             failure(openIdMode, nil, error);
                     }];
        
        return YES;
    }
    else if([@"error" isEqualToString:openIdMode])
    {
        if(failure)
            failure(openIdMode, [parameterDictionary objectForKey:@"openid.error"], nil);
        return YES;
    }
    
    return NO;
}

+ (BOOL) openIdAuthenticate:(NSURLRequest*)request
                    success:(void(^)(SparkAPI* sparkAPI, NSDictionary* parameters))success
                    failure:(void(^)(NSString* openIdMode, NSString* openIdError))failure
{
    NSDictionary *parameterDictionary = [self getParameterDictionary:request.URL];
    NSString* openIdMode = nil;
    if (parameterDictionary &&
            (openIdMode = [parameterDictionary objectForKey:@"openid.mode"]) &&
            [@"id_res" isEqualToString:openIdMode])
    {
        NSString* openIdSparkId = [parameterDictionary objectForKey:@"openid.ax.value.id"];
        SparkAPI *sparkAPI =
        [[SparkAPI alloc] initWithAccessToken:nil
                                 refreshToken:nil
                                       openId:openIdSparkId];
        if(success)
            success(sparkAPI,parameterDictionary);
        
        return YES;
    }
    else if([@"error" isEqualToString:openIdMode])
    {
        if(failure)
            failure(openIdMode, [parameterDictionary objectForKey:@"openid.error"]);
        return YES;
    }
    
    return NO;
}
// interface *******************************************************************

- initWithAccessToken:(NSString*)access
         refreshToken:(NSString*)refresh
               openId:(NSString*)openId
{
    if (self = [super init])
    {
        oauthAccessToken = access;
        oauthRefreshToken = refresh;
        openIdSparkId = openId;
        
        if(oauthRefreshToken)
            [httpClient setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"OAuth %@",oauthAccessToken]];
        
        logLevel = SPARK_LOG_LEVEL_INFO;
    }
    return self;
}

- (void)setApplicationName:(NSString *)value
{
    applicationName = value;
    [httpClient setDefaultHeader:@"X-SparkApi-User-Agent" value:value];
}

+ (NSDictionary*)getResponseJSON:(id)responseObject
{
    NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
    return [responseString JSONValue];
}

- (void)handleSuccess:(id)responseObject
         successBlock:(void(^)(NSArray *resultsJSON))success
{
    if(!responseObject)
        return;
    
    NSDictionary *responseJSON = [SparkAPI getResponseJSON:responseObject];
    NSDictionary *responsePayload = [self getResponsePayload:responseJSON];
    if([self getResponseSuccess:responsePayload] && success)
        success([responsePayload objectForKey:@"Results"]);
}

- (void)handleSessionExpiration:(NSString*)apiCommand
                     httpMethod:(NSString*)httpMethod
                     parameters:(NSDictionary*)parameters
                        success:(void(^)(NSArray *resultsJSON))success
                        failure:(void(^)(NSInteger sparkErrorCode,
                                         NSString* sparkErrorMessage,
                                         NSError *httpError))failure
{
    NSMutableDictionary* dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setObject:[SparkAPI encodeURL:sparkClientId] forKey:@"client_id"];
    [dictionary setObject:sparkClientSecret forKey:@"client_secret"];
    [dictionary setObject:@"refresh_token" forKey:@"grant_type"];
    [dictionary setObject:self.oauthRefreshToken forKey:@"refresh_token"];
    [dictionary setObject:sparkCallbackURL forKey:@"redirect_uri"];
    
    [httpClient postPath:[NSString stringWithFormat:@"%@/oauth2/grant", sparkAPIVersion]
              parameters:dictionary
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     NSDictionary *responseJSON = [SparkAPI getResponseJSON:responseObject];
                     self.oauthAccessToken = [responseJSON objectForKey:@"access_token"];
                     self.oauthRefreshToken = [responseJSON objectForKey:@"refresh_token"];
                     [httpClient setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"OAuth %@",self.oauthAccessToken]];
                     
                     [self api:apiCommand
                    httpMethod:httpMethod
                    parameters:parameters
                       success:success
                       failure:failure];
                 }
                  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                      if(failure)
                          failure(-1,nil,error);
                  }];
}

- (void)handleFailure:(NSError*)httpError
                  api:(NSString*)apiCommand
           httpMethod:(NSString*)httpMethod
           parameters:(NSDictionary*)parameters
              success:(void(^)(NSArray *resultsJSON))success
              failure:(void(^)(NSInteger sparkErrorCode,
                               NSString* sparkErrorMessage,
                               NSError *httpError))failure
{
    if(!httpError)
        return;

    [self logWarning:[NSString stringWithFormat:@"%@ failure>%@ - %@", httpMethod, apiCommand, httpError]];
    
    NSInteger sparkErrorCode = -1;
    NSString* sparkErrorMessage = nil;

    NSDictionary *responseJSON = [[httpError.userInfo objectForKey:NSLocalizedRecoverySuggestionErrorKey] JSONValue];
    NSDictionary *responsePayload = [self getResponsePayload:responseJSON];
    
    if(responsePayload)
    {
        NSNumber *code = [responsePayload objectForKey:@"Code"];
        if(code)
            sparkErrorCode = [code integerValue];
        sparkErrorMessage = [responsePayload objectForKey:@"Message"];

        if(sparkErrorCode == 1020)
        {
            [self handleSessionExpiration:apiCommand
                               httpMethod:httpMethod
                               parameters:parameters
                                  success:success
                                  failure:failure];
            return;
        }
    }
 
    if(failure)
        failure(sparkErrorCode, sparkErrorMessage, httpError);
}

- (void) get:(NSString*)apiCommand
  parameters:(NSDictionary*)parameters
     success:(void(^)(NSArray *resultsJSON))success
     failure:(void(^)(NSInteger sparkErrorCode,
                      NSString* sparkErrorMessage,
                      NSError *httpError))failure
{
    [httpClient getPath:[NSString stringWithFormat:@"%@%@",sparkAPIVersion,apiCommand]
             parameters:parameters
                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    [self logInfo:[NSString stringWithFormat:@"get success>%@", apiCommand]];
                    [self handleSuccess:responseObject
                           successBlock:success];
                }
                failure:^(AFHTTPRequestOperation *operation, NSError *httpError) {
                    [self handleFailure:httpError
                                    api:apiCommand
                             httpMethod:httpGet
                             parameters:parameters
                                success:success
                                failure:failure];
                }];
}

- (void) post:(NSString*)apiCommand
  parameters:(NSDictionary*)parameters
     success:(void(^)(NSArray *resultsJSON))success
      failure:(void(^)(NSInteger sparkErrorCode,
                       NSString* sparkErrorMessage,
                       NSError *httpError))failure
{
    [httpClient postPath:[NSString stringWithFormat:@"%@%@",sparkAPIVersion,apiCommand]
              parameters:parameters
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     [self logInfo:[NSString stringWithFormat:@"post success>%@", apiCommand]];
                     [self handleSuccess:responseObject
                            successBlock:success];
                 }
                 failure:^(AFHTTPRequestOperation *operation, NSError *httpError) {
                     [self handleFailure:httpError
                                     api:apiCommand
                              httpMethod:httpPost
                              parameters:parameters
                                 success:success
                                 failure:failure];
                 }];
}

- (void) put:(NSString*)apiCommand
   parameters:(NSDictionary*)parameters
      success:(void(^)(NSArray *resultsJSON))success
     failure:(void(^)(NSInteger sparkErrorCode,
                      NSString* sparkErrorMessage,
                      NSError *httpError))failure
{
    [httpClient putPath:[NSString stringWithFormat:@"%@%@",sparkAPIVersion,apiCommand]
             parameters:parameters
                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    [self logInfo:[NSString stringWithFormat:@"put success>%@", apiCommand]];
                    [self handleSuccess:responseObject
                           successBlock:success];
                }
                failure:^(AFHTTPRequestOperation *operation, NSError *httpError) {
                    [self handleFailure:httpError
                                    api:apiCommand
                             httpMethod:httpPut
                             parameters:parameters
                                success:success
                                failure:failure];
                }];
}

- (void) delete:(NSString*)apiCommand
  parameters:(NSDictionary*)parameters
     success:(void(^)(NSArray *resultsJSON))success
        failure:(void(^)(NSInteger sparkErrorCode,
                         NSString* sparkErrorMessage,
                         NSError *httpError))failure
{
    [httpClient deletePath:[NSString stringWithFormat:@"%@%@",sparkAPIVersion,apiCommand]
             parameters:parameters
                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    [self logInfo:[NSString stringWithFormat:@"delete success>%@", apiCommand]];
                    [self handleSuccess:responseObject
                           successBlock:success];
                }
                failure:^(AFHTTPRequestOperation *operation, NSError *httpError) {
                    [self handleFailure:httpError
                                    api:apiCommand
                             httpMethod:httpDelete
                             parameters:parameters
                                success:success
                                failure:failure];
                }];
}

- (void) api:(NSString*)apiCommand
  httpMethod:(NSString*)httpMethod
  parameters:(NSDictionary*)parameters
     success:(void(^)(NSArray *resultsJSON))success
     failure:(void(^)(NSInteger sparkErrorCode,
                      NSString* sparkErrorMessage,
                      NSError *httpError))failure
{
    if([httpPost isEqualToString:httpMethod])
    {
        [self post:apiCommand
        parameters:parameters
           success:success
           failure:failure];
    }
    else if([httpPut isEqualToString:httpMethod])
    {
        [self put:apiCommand
       parameters:parameters
          success:success
          failure:failure];
    }
    else if([httpDelete isEqualToString:httpMethod])
    {
        [self delete:apiCommand
          parameters:parameters
             success:success
             failure:failure];
    }
    else // ([httpGet isEqualToString:httpMethod])
    {
        [self get:apiCommand
       parameters:parameters
          success:success
          failure:failure];
    }

}

- (NSDictionary*) getResponsePayload:(NSDictionary*)responseJSON
{
    return responseJSON ? [responseJSON objectForKey:@"D"] : nil;
}

- (BOOL) getResponseSuccess:(NSDictionary*)responsePayload
{
    return responsePayload ? [[responsePayload objectForKey:@"Success"] boolValue] : NO;
}

// logging

- (NSString*)getLogLevelLabel:(NSInteger)level
{
    if(level == SPARK_LOG_LEVEL_ERROR)
        return @"ERROR";
    else if (level == SPARK_LOG_LEVEL_WARNING)
        return @"WARNING";
    else if (level == SPARK_LOG_LEVEL_INFO)
        return @"INFO";
    else if (level == SPARK_LOG_LEVEL_FINE)
        return @"FINE";
    else
        return nil;
}

- (void)log:(NSInteger)level message:(NSString*)message
{
    if(level >= self.logLevel)
        NSLog(@"SparkAPI %@: %@", [self getLogLevelLabel:level], message);
}

- (void)logError:(NSString*)message
{
    [self log:SPARK_LOG_LEVEL_ERROR message:message];
}

- (void)logWarning:(NSString*)message
{
    [self log:SPARK_LOG_LEVEL_WARNING message:message];
}
- (void)logInfo:(NSString*)message
{
    [self log:SPARK_LOG_LEVEL_INFO message:message];
}

- (void)logFine:(NSString*)message
{
    [self log:SPARK_LOG_LEVEL_FINE message:message];
}

@end
