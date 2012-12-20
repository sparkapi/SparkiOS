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

@interface SparkAPI ()

@end

@implementation SparkAPI

@synthesize accessToken, refreshToken;

// constants
static NSString* sparkClientId = @"";
static NSString* sparkClientSecret = @"";

static NSString* sparkOpenIdURL = @"https://sparkplatform.com/openid";
static NSString* sparkOAuth2GrantURL = @"https://sparkplatform.com/v1/oauth2/grant";
static NSString* sparkOAuth2CallbackURL = @"https://sparkplatform.com/oauth2/callback";

static NSString* httpGet = @"GET";
static NSString* httpPost = @"POST";
static NSString* httpPut = @"PUT";
static NSString* httpDelete = @"DELETE";

// class vars

static AFHTTPClient *httpClient;

// class interface *************************************************************

+(void) initialize
{
    @synchronized(self)
    {
        if(!httpClient)
        {
            httpClient = [[AFHTTPClient alloc] initWithBaseURL:
                                    [NSURL URLWithString:@"https://sparkapi.com/"]];
            [httpClient setDefaultHeader:@"User-Agent" value:@"Spark iOS API 1.0"];
            [httpClient setDefaultHeader:@"X-SparkApi-User-Agent" value:@"Spark iOS API 1.0"];
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

+ (NSURL*)getSparkOpenIdURL
{
    NSMutableString *urlString = [[NSMutableString alloc] init];
    [urlString appendString:sparkOpenIdURL];
    [urlString appendString:@"?openid.mode=checkid_setup"];
    [urlString appendString:@"&openid.spark.client_id="];
    [urlString appendString:sparkClientId];
    [urlString appendString:@"&openid.return_to="];
    [urlString appendString:[self encodeURL:sparkOAuth2CallbackURL]];
    [urlString appendString:@"&openid.spark.combined_flow=true"];
    return [NSURL URLWithString:urlString];
}

+ (NSURL*)getSparkOAuth2URL
{
    return [NSURL URLWithString:sparkOAuth2GrantURL];
}

+ (NSString*) getHybridOpenIdSparkCode:(NSURLRequest*)request
{
    NSDictionary *parameterDictionary = [self getParameterDictionary:request.URL];
    NSString* openIdMode = nil;
    NSString* openIdSparkCode = nil;
    return (parameterDictionary &&
           (openIdMode = [parameterDictionary objectForKey:@"openid.mode"]) &&
           [@"id_res" isEqualToString:openIdMode] &&
           (openIdSparkCode =[parameterDictionary objectForKey:@"openid.spark.code"])) ?
           openIdSparkCode:
           nil;
}

+ (void) OAuth2Grant:(NSString*)openIdSparkCode delegate:(id <SparkAPIDelegate>) delegate
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:sparkClientId forKey:@"client_id"];
    [dictionary setObject:sparkClientSecret forKey:@"client_secret"];
    [dictionary setObject:@"authorization_code" forKey:@"grant_type"];
    [dictionary setObject:openIdSparkCode forKey:@"code"];
    [dictionary setObject:sparkOAuth2CallbackURL forKey:@"redirect_uri"];
     
     [httpClient postPath:@"/v1/oauth2/grant" parameters:dictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
         NSString *text = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
         NSDictionary* dictionary = [text JSONValue];
         SparkAPI *sparkAPI =
            [[SparkAPI alloc] initWithAccessToken:[dictionary objectForKey:@"access_token"]
                                     refreshToken:[dictionary objectForKey:@"refresh_token"]];
        if(delegate)
            [delegate didAuthorize:sparkAPI];
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Failure: %@", error);
     }];
}

// instance methods ************************************************************

- initWithAccessToken:(NSString*)access refreshToken:(NSString*)refresh
{
    if (self = [super init])
    {
        accessToken = access;
        refreshToken = refresh;
        [httpClient setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"OAuth %@",accessToken]];
    }
    return self;
}

- (void) get:(NSString*)apiCommand
  parameters:(NSDictionary*)parameters
     success:(void(^)(id responseJSON))success
     failure:(void(^)(NSError *error))failure
{
    [self api:apiCommand
   parameters:parameters
   httpMethod:httpGet
      success:success
      failure:failure];
}

- (void) api:(NSString*)apiCommand
  parameters:(NSDictionary*)parameters
  httpMethod:(NSString*)httpMethod
     success:(void(^)(id responseJSON))success
     failure:(void(^)(NSError *error))failure
{
    [httpClient getPath:apiCommand
             parameters:parameters
                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                    NSDictionary *responseJSON = [responseString JSONValue];
                    if(success)
                        success([self getResultsArray:responseJSON]);
                }
                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    if(failure)
                        failure(error);
                }];
}

- (NSArray*) getResultsArray:(NSDictionary*)responseJSON
{
    NSDictionary* responsePayload = [self getResponsePayload:responseJSON];
    return [self getResponseSuccess:responsePayload] ? [responsePayload objectForKey:@"Results"] : nil;
}

- (NSDictionary*) getResponsePayload:(NSDictionary*)responseJSON
{
    return responseJSON ? [responseJSON objectForKey:@"D"] : nil;
}

- (BOOL) getResponseSuccess:(NSDictionary*)responsePayload
{
    return responsePayload ? [[responsePayload objectForKey:@"Success"] boolValue] : NO;
}

@end
