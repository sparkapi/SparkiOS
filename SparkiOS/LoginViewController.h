//
//  LoginViewController.h
//  SparkiOS
//
//  Created by David Ragones on 12/17/12.
//  Copyright (c) 2012 Financial Business Systems, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController <UIWebViewDelegate>
{
    IBOutlet UIButton *sparkButton;
    IBOutlet UISwitch *loginType;
}

@property (strong, nonatomic) UIButton *sparkButton;
@property (strong, nonatomic) UISwitch *loginType;

@property (strong, nonatomic) UIWebView *webView;

@end
