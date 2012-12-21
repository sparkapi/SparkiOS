//
//  SlideshowViewController.h
//  SparkiOS
//
//  Created by David Ragones on 12/20/12.
//  Copyright (c) 2012 Financial Business Systems, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SlideshowViewController : UIViewController
    <UIScrollViewDelegate>
{
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIPageControl *pageControl;
}

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIPageControl *pageControl;

@property (strong, nonatomic) NSArray *photosJSON;

- (void)setContent;

@end
