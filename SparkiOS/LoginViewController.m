//
//  LoginViewController.m
//  SparkiOS
//
//  Created by David Ragones on 12/17/12.
//  Copyright (c) 2012 Financial Business Systems, Inc. All rights reserved.
//

#import "LoginViewController.h"

#import "iOSConstants.h"
#import "UIHelper.h"

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
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.sparkplatform.com"]]];
    [self.view addSubview:self.webView];
}

// UIWebViewDelegate ***********************************************************

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    self.webView.hidden = NO;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
}

@end
