//
//  SlideshowViewController.m
//  SparkiOS
//
//  Created by David Ragones on 12/20/12.
//  Copyright (c) 2012 Financial Business Systems, Inc. All rights reserved.
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
