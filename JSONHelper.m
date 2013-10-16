//
//  JSONHelper.m
//  SparkiOS
//
//  Created by David Ragones on 1/4/13.
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

#import "JSONHelper.h"

@implementation JSONHelper

+ (NSString*)getJSONString:(NSDictionary*)json key:(NSString*)key
{
    id value = [json objectForKey:key];
    return value && [value isKindOfClass:[NSString class]] ? value : nil;
}

+ (NSNumber*)getJSONNumber:(NSDictionary*)json key:(NSString*)key
{
    id value = [json objectForKey:key];
    return value && [value isKindOfClass:[NSNumber class]] ? value : nil;
}

@end
