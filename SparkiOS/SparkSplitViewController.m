//
//  SparkSplitViewController.m
//  SparkiOS
//
//  Created by David Ragones on 12/21/12.
//  Copyright (c) 2012 Financial Business Systems, Inc. All rights reserved.
//

#import "SparkSplitViewController.h"

#import "ListingFormatter.h"

@interface SparkSplitViewController ()

@end

@implementation SparkSplitViewController

// UINavigationControllerDelegate **********************************************

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if([viewController isKindOfClass:[ViewListingsViewController class]])
    {
        self.slideshowVC.title = nil;
        self.slideshowVC.scrollView.hidden = YES;
        self.slideshowVC.pageControl.hidden = YES;
    }
}

// ViewListingsViewControllerDelegate ******************************************

- (void)selectListing:(NSDictionary*)listingJSON
{
    NSDictionary* standardFieldsJSON = [listingJSON objectForKey:@"StandardFields"];
    self.slideshowVC.title = [ListingFormatter getListingTitle:standardFieldsJSON];
    self.slideshowVC.photosJSON = [standardFieldsJSON objectForKey:@"Photos"];
    [self.slideshowVC setContent];
    
    self.slideshowVC.scrollView.hidden = NO;
    self.slideshowVC.pageControl.hidden = NO;
}

// ViewListingViewControllerDelegate ******************************************

- (void)loadListing:(NSDictionary*)listingJSON
{
    NSDictionary* standardFieldsJSON = [listingJSON objectForKey:@"StandardFields"];
    self.slideshowVC.photosJSON = [standardFieldsJSON objectForKey:@"Photos"];
    [self.slideshowVC setContent];
}

@end
