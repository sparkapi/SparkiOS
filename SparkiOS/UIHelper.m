//
//  UIHelper.m
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

#import "UIHelper.h"

#import "AppDelegate.h"
#import "iOSConstants.h"
#import "SparkAPI.h"

@implementation UIHelper

+ (BOOL)iPad
{
	return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
}

+ (BOOL)iPhone
{
	return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
}

+ (BOOL) iPhone5
{
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    return [self iPhone] && (screenBounds.size.height == IPHONE5_HEIGHT);
}

+ (BOOL) isOAuth
{
    SparkAPI* sparkAPI = [self getSparkAPI];
    return sparkAPI.oauthAccessToken && sparkAPI.oauthRefreshToken;
}

+ (SparkAPI*)getSparkAPI
{
    return ((AppDelegate*)[[UIApplication sharedApplication] delegate]).sparkAPI;

}

@end
