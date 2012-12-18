//
//  UIHelper.m
//  SparkiOS
//
//  Created by David Ragones on 12/17/12.
//  Copyright (c) 2012 Financial Business Systems, Inc. All rights reserved.
//

#import "UIHelper.h"

#import "iOSConstants.h"

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

@end
