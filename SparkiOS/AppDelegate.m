//
//  AppDelegate.m
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

#import "AppDelegate.h"
#import "Keys.h"
#import "LoginViewController.h"
#import "MyAccountViewController.h"
#import "PDKeychainBindings.h"
#import "UIHelper.h"
#import "ViewListingsViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    PDKeychainBindings *keychain = [PDKeychainBindings sharedKeychainBindings];
    NSString* accessToken = [keychain objectForKey:SPARK_ACCESS_TOKEN];
    NSString* refreshToken = [keychain objectForKey:SPARK_REFRESH_TOKEN];
    NSString* openIdSparkid = [keychain objectForKey:SPARK_OPENID];

    UIViewController *vc = nil;
    if((accessToken && refreshToken) || openIdSparkid)
    {
        self.sparkAPI = [[SparkAPI alloc] initWithAccessToken:accessToken
                                                 refreshToken:refreshToken
                                                       openId:openIdSparkid];
        vc = [UIHelper getHomeViewController];
    }
    else
    {
        vc = [[LoginViewController alloc] initWithNibName:([UIHelper iPhone] ? @"LoginViewController" : @"LoginViewController-iPad")
                                                   bundle:nil];
        vc.title = @"Login";
    }
    
    UIViewController *rootVC = nil;    
    if([UIHelper iPhone])
        rootVC = [UIHelper getNavigationController:vc];
    else
        rootVC = [vc isKindOfClass:[LoginViewController class]] ? vc : [UIHelper getSplitViewController];
    
    self.window.rootViewController = rootVC;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
