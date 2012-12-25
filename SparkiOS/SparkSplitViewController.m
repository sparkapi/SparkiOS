//
//  SparkSplitViewController.m
//  SparkiOS
//
//  Created by David Ragones on 12/21/12.
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

#import "SparkSplitViewController.h"

#import "ListingFormatter.h"

@interface SparkSplitViewController ()

@end

@implementation SparkSplitViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

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
