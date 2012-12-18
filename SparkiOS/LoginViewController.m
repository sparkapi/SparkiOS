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
#import "UIHelper.h"
#import "ViewListingsViewController.h"

@interface LoginViewController ()

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
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0,0,IPHONE_WIDTH,[UIHelper iPhone5] ? IPHONE5_HEIGHT_INSIDE_NAVBAR : IPHONE_HEIGHT_INSIDE_NAVBAR)];
    self.webView.hidden = YES;
    self.webView.delegate = self;
    [self.webView loadRequest:[NSURLRequest requestWithURL:[SparkAPI getSparkOpenIdURL]]];
    [self.view addSubview:self.webView];
}

// UIWebViewDelegate ***********************************************************

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString* openIdSparkCode = [SparkAPI getHybridOpenIdSparkCode:request];
    if(openIdSparkCode)
    {
        [SparkAPI OAuth2Grant:openIdSparkCode delegate:self];
        return NO;
    }
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    self.webView.hidden = NO;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

// SparkAPIDelegate ************************************************************

- (void)didAuthorize:(SparkAPI*)sender
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    AppDelegate *appDelegate = ((AppDelegate*)[[UIApplication sharedApplication] delegate]);
    appDelegate.sparkAPI = sender;
    
    NSMutableArray *viewControllers = [[NSMutableArray alloc] initWithCapacity:1];
    [viewControllers addObject:[[ViewListingsViewController alloc] initWithStyle:UITableViewStylePlain]];
    [self.navigationController setViewControllers:viewControllers animated:YES];
}

@end
