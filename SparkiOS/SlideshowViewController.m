//
//  SlideshowViewController.m
//  SparkiOS
//
//  Created by David Ragones on 12/20/12.
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

#import "SlideshowViewController.h"

#import "UIImageView+AFNetworking.h"

@interface SlideshowViewController ()

@property (strong, nonatomic) NSMutableArray* imageViews;

@end

@implementation SlideshowViewController

@synthesize scrollView, pageControl;

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setContent];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)setContent
{
    if(self.scrollView.subviews)
        for(UIView* v in self.scrollView.subviews)
            [v removeFromSuperview];
    
    CGFloat xLocation = 0;
    int photoCount = (self.photosJSON ? [self.photosJSON count] : 1);
    self.imageViews = [[NSMutableArray alloc] init];
    for(int i = 0; i < photoCount; ++i)
    {
        UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(xLocation,0,704,704)];
        [self.imageViews addObject:imageView];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.scrollView addSubview:imageView];
        if(i == 0)
            [imageView setImageWithURL:[NSURL URLWithString:[[self.photosJSON objectAtIndex:0] objectForKey:@"Uri800"]]];
        xLocation += 704;
    }
    
    [self.scrollView setContentSize:CGSizeMake(photoCount * 704, 704)];
    self.pageControl.numberOfPages = photoCount;
}

// UIScrollViewDelegate ********************************************************

- (void)scrollViewDidEndDecelerating:(UIScrollView *)sv
{
    int page = floor((sv.contentOffset.x - 704 / 2) / 704) + 1;
    [self.pageControl setCurrentPage:page];
    
    NSDictionary *photoJSON = [self.photosJSON objectAtIndex:page];
    UIImageView *imageView = [self.imageViews objectAtIndex:page];
    [imageView setImageWithURL:[NSURL URLWithString:[photoJSON objectForKey:@"Uri800"]]];
}

@end
