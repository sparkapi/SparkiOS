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

#import "iOSConstants.h"
#import "Keys.h"
#import "LoginViewController.h"
#import "MyAccountViewController.h"
#import "PDKeychainBindings.h"
#import "SlideshowViewController.h"
#import "SparkAPI.h"
#import "SparkSplitViewController.h"
#import "ViewListingsViewController.h"

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

+ (AppDelegate*)getAppDelegate
{
    return (AppDelegate*)[[UIApplication sharedApplication] delegate];
}

+ (SparkAPI*)getSparkAPI
{
    return ([self getAppDelegate]).sparkAPI;

}

+ (UIViewController*)getHomeViewController
{
    SparkAPI* sparkAPI = [self getSparkAPI];
    return (sparkAPI.oauthAccessToken && sparkAPI.oauthRefreshToken) ?
        [[ViewListingsViewController alloc] initWithStyle:UITableViewStylePlain] :
        [[MyAccountViewController alloc] initWithStyle:UITableViewStyleGrouped];
}

+ (UINavigationController*)getNavigationController:(UIViewController*)rootViewController
{
    UINavigationController *navigationController =
    [[UINavigationController alloc] initWithRootViewController:rootViewController];
    navigationController.navigationBar.tintColor = [UIColor blackColor];
    navigationController.toolbar.tintColor = [UIColor blackColor];
    return navigationController;
}

+ (UISplitViewController*)getSplitViewController
{
    SparkSplitViewController *svc = [[SparkSplitViewController alloc] init];
    svc.slideshowVC =
        [[SlideshowViewController alloc] initWithNibName:@"SlideshowViewController"
                                                  bundle:nil];
    
    UIViewController *homeVC = [self getHomeViewController];
    UINavigationController* homeNav = [UIHelper getNavigationController:homeVC];
    homeNav.delegate = svc;
    UIViewController *vc1 = homeNav;
    UIViewController *vc2 =
        [UIHelper getNavigationController:svc.slideshowVC];
    if([homeVC isKindOfClass:[ViewListingsViewController class]])
    {
        ((ViewListingsViewController*)homeVC).listingsDelegate = svc;
        ((ViewListingsViewController*)homeVC).listingDelegate = svc;
    }
    svc.viewControllers = [NSArray arrayWithObjects:vc1, vc2, nil];
    return svc;
}

+ (void)iPhone5Shift:(UIView*)v
{
    v.center = CGPointMake(v.center.x, v.center.y + NAVBAR_HEIGHT);
}

+ (void)handleFailure:(NSString*)message
                error:(NSError*)error
{
    NSString* errorMessage = nil;
    if(message)
        errorMessage = message;
    else if (error)
        errorMessage = error.localizedDescription;
    
    NSLog(@"error>%@",error);
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:errorMessage
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
    
}

+ (void)handleFailure:(UIViewController*)viewController
                 code:(NSInteger)sparkErrorCode
              message:(NSString*)sparkErrorMessage
                error:(NSError*)error
{
    NSString* message = nil;
    if(sparkErrorCode >= 1000 && sparkErrorMessage)
    {
        message = [NSString stringWithFormat:@"%d: %@", sparkErrorCode, sparkErrorMessage];

        if(sparkErrorCode == 1000)
        {
            [self handleFailure:message error:nil];
            [self logout:viewController];
            return;
        }
    }

    [self handleFailure:message error:error];
}

+ (void)logout:(UIViewController*)viewController
{
    PDKeychainBindings *keychain = [PDKeychainBindings sharedKeychainBindings];
    [keychain removeObjectForKey:SPARK_ACCESS_TOKEN];
    [keychain removeObjectForKey:SPARK_REFRESH_TOKEN];
    [keychain removeObjectForKey:SPARK_OPENID];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:OPENID_ID];
    [defaults removeObjectForKey:OPENID_FRIENDLY];
    [defaults removeObjectForKey:OPENID_FIRST_NAME];
    [defaults removeObjectForKey:OPENID_MIDDLE_NAME];
    [defaults removeObjectForKey:OPENID_LAST_NAME];
    [defaults removeObjectForKey:OPENID_EMAIL];
    
    LoginViewController *loginVC = [[LoginViewController alloc] initWithNibName:([UIHelper iPhone] ? @"LoginViewController" : @"LoginViewController-iPad") bundle:nil];
    loginVC.title = @"Login";
    
    if([UIHelper iPhone])
        [viewController.navigationController setViewControllers:[NSArray arrayWithObject:loginVC] animated:YES];
    else
    {
        AppDelegate *appDelegate = [UIHelper getAppDelegate];
        appDelegate.window.rootViewController = loginVC;
    }
}

@end
