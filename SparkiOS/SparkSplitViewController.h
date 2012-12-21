//
//  SparkSplitViewController.h
//  SparkiOS
//
//  Created by David Ragones on 12/21/12.
//  Copyright (c) 2012 Financial Business Systems, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SlideshowViewController.h"
#import "ViewListingsViewController.h"
#import "ViewListingViewController.h"

@interface SparkSplitViewController : UISplitViewController
    <UINavigationControllerDelegate,
     ViewListingsViewControllerDelegate,
     ViewListingViewControllerDelegate>

@property (strong, nonatomic) SlideshowViewController *slideshowVC;


@end
