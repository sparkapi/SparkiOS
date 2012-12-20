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
#import "LoginViewController.h"
#import "ViewListingsViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* accessToken = [defaults objectForKey:SPARK_ACCESS_TOKEN];
    NSString* refreshToken = [defaults objectForKey:SPARK_REFRESH_TOKEN];

    UIViewController *vc = nil;
    if(accessToken && refreshToken)
    {
        vc = [[ViewListingsViewController alloc] initWithStyle:UITableViewStylePlain];
        self.sparkAPI = [[SparkAPI alloc] initWithAccessToken:accessToken refreshToken:refreshToken];
    }
    else
    {
        vc = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        vc.title = @"Login";
    }
    
    UINavigationController *navigationController =
        [[UINavigationController alloc] initWithRootViewController:vc];
    navigationController.navigationBar.tintColor = [UIColor blackColor];
    navigationController.toolbar.tintColor = [UIColor blackColor];

    self.window.rootViewController = navigationController;
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
