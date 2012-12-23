//
//  LoginViewController.m
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

#import "LoginViewController.h"

#import "AppDelegate.h"
#import "iOSConstants.h"
#import "Keys.h"
#import "SparkAPI.h"
#import "UIHelper.h"
#import "ViewListingsViewController.h"
#import "MyAccountViewController.h"

@interface LoginViewController ()

@property (strong, nonatomic) UIWebView *webView;

@end

@implementation LoginViewController

@synthesize sparkButton, loginType;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) sparkLogin
{
    self.webView =
        [[UIWebView alloc] initWithFrame:CGRectMake(0,0,
                                                    [UIHelper iPhone] ? IPHONE_WIDTH : IPAD_WIDTH,
                                                    [UIHelper iPhone] ?
                                                        ([UIHelper iPhone5] ? IPHONE5_HEIGHT_INSIDE_NAVBAR : IPHONE_HEIGHT_INSIDE_NAVBAR) :
                                                        IPAD_HEIGHT_INSIDE_STATUS)];
    self.webView.hidden = YES;
    self.webView.delegate = self;
    [self.webView loadRequest:[NSURLRequest requestWithURL:[SparkAPI getSparkOpenIdLogoutURL]]];
    [self.view addSubview:self.webView];
}

// UIWebViewDelegate ***********************************************************

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)processAuthentication:(SparkAPI*)sparkAPI parameters:(NSDictionary*)parameters
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    AppDelegate *appDelegate = ((AppDelegate*)[[UIApplication sharedApplication] delegate]);
    appDelegate.sparkAPI = sparkAPI;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if(sparkAPI.oauthAccessToken)
        [defaults setObject:sparkAPI.oauthAccessToken forKey:SPARK_ACCESS_TOKEN];
    if(sparkAPI.oauthRefreshToken)
        [defaults setObject:sparkAPI.oauthRefreshToken forKey:SPARK_REFRESH_TOKEN];
    if(sparkAPI.openIdSparkId)
    {
        [defaults setObject:sparkAPI.openIdSparkId forKey:SPARK_OPENID];

        NSString *value = [parameters objectForKey:@"openid.ax.value.id"];
        if(value)
            [defaults setObject:value forKey:OPENID_ID];
        value = [parameters objectForKey:@"openid.ax.value.friendly"];
        if(value)
            [defaults setObject:value forKey:OPENID_FRIENDLY];
        value = [parameters objectForKey:@"openid.ax.value.first_name"];
        if(value)
            [defaults setObject:value forKey:OPENID_FIRST_NAME];
        value = [parameters objectForKey:@"openid.ax.value.middle_name"];
        if(value)
            [defaults setObject:value forKey:OPENID_MIDDLE_NAME];
        value = [parameters objectForKey:@"openid.ax.value.last_name"];
        if(value)
            [defaults setObject:value forKey:OPENID_LAST_NAME];
        value = [parameters objectForKey:@"openid.ax.value.email"];
        if(value)
            [defaults setObject:value forKey:OPENID_EMAIL];
    }

    if([UIHelper iPhone])
        [self.navigationController setViewControllers:[NSArray arrayWithObject:[UIHelper getHomeViewController]]
                                         animated:YES];
    else
    {
        AppDelegate* appDelegate = [UIHelper getAppDelegate];
        appDelegate.window.rootViewController = [UIHelper getSplitViewController];
    }
}

- (NSString*)handleOpenIdError:(NSString*)openIdMode openIdError:(NSString*)openIdError
{
    if([@"cancel" isEqualToString:openIdMode])
        return @"OpenId authentication cancelled";
    else if([@"error" isEqualToString:openIdMode])
        return [NSString stringWithFormat:@"OpenId error:%@",openIdError];
    else
        return nil;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{    
    if(self.loginType.on)
    {
        if([SparkAPI hybridAuthenticate:request
                          success:^(SparkAPI *sparkAPI) {
                              [self processAuthentication:sparkAPI parameters:nil];
                          }
                          failure:^(NSString* openIdMode, NSString* openIdError, NSError *httpError) {
                              NSString* message = nil;
                              if(openIdMode)
                                  message = [self handleOpenIdError:openIdMode openIdError:openIdError];
                              [UIHelper handleFailure:message error:httpError];
                          }])
            return NO;
    }
    else
    {
        if([SparkAPI openIdAuthenticate:request
                                 success:^(SparkAPI *sparkAPI, NSDictionary *parameters) {
                                     [self processAuthentication:sparkAPI parameters:parameters];
                                 }
                                 failure:^(NSString* openIdMode, NSString* openIdError) {
                                     NSString* message = nil;
                                     if(openIdMode)
                                         message = [self handleOpenIdError:openIdMode openIdError:openIdError];
                                     [UIHelper handleFailure:message error:nil];
                                 }])
            return NO;
    }
    
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSURLRequest* urlRequest = webView.request;
        
    if([[urlRequest.URL absoluteString] isEqualToString:[[SparkAPI getSparkOpenIdLogoutURL] absoluteString]])
    {
        [self.webView loadRequest:[NSURLRequest requestWithURL:(self.loginType.on ?
                                                                [SparkAPI getSparkHybridOpenIdURL] :
                                                                [SparkAPI getSparkOpenIdAttributeExchangeURL])]];
    }
    else
    {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        self.webView.hidden = NO;
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

@end
