//
//  ViewListingViewController.m
//  SparkiOS
//
//  Created by David Ragones on 12/18/12.
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

#import "ViewListingViewController.h"

#import <QuartzCore/QuartzCore.h>

#import "AppDelegate.h"
#import "ListingFormatter.h"
#import "UIImageView+AFNetworking.h"

@interface ViewListingViewController ()

@property (strong, nonatomic) NSDictionary *listingJSON;
@property (strong, nonatomic) NSDictionary *standardFields;
@property (strong, nonatomic) NSMutableArray *standardFieldsSorted;

@property (strong, nonatomic) UIPageControl *pageControl;
@property (strong, nonatomic) NSMutableArray* imageViews;

@property (strong, nonatomic) UITableViewCell *detailLineCell;

@end

@implementation ViewListingViewController

static NSDateFormatter* simpleDateFormatter;
static NSDateFormatter* simpleDateTimeFormatter;

+(void) initialize
{
    @synchronized(self)
    {
        if (!simpleDateFormatter)
        {
            simpleDateFormatter = [[NSDateFormatter alloc] init];
            [simpleDateFormatter setDateFormat:@"M/d/yy"];
        }
        
        if (!simpleDateTimeFormatter)
        {
            simpleDateTimeFormatter = [[NSDateFormatter alloc] init];
            [simpleDateTimeFormatter setDateFormat:@"M/d/yy h:mma"];
        }
    }
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:@"1" forKey:@"_limit"];
    [parameters setObject:@"Photos" forKey:@"_expand"];
    [parameters setObject:[NSString stringWithFormat:@"ListingId Eq '%@'", self.ListingId] forKey:@"_filter"];
    
    SparkAPI *sparkAPI =
        ((AppDelegate*)[[UIApplication sharedApplication] delegate]).sparkAPI;
    [sparkAPI get:@"/v1/listings"
       parameters:parameters
          success:^(id responseJSON) {
              NSArray *listingsJSON = (NSArray*)responseJSON;
              if(listingsJSON && [listingsJSON count] > 0)
              {
                  self.listingJSON = [listingsJSON objectAtIndex:0];
                  [self.tableView reloadData];
              }
          }
          failure:^(NSError* error) {
              NSLog(@"error>%@",error);
          }];
    
    [sparkAPI get:@"/v1/standardfields"
       parameters:parameters
          success:^(id responseJSON) {
              self.standardFields = [(NSArray*)responseJSON objectAtIndex:0];
              [self.tableView reloadData];
          }
          failure:^(NSError* error) {
              NSLog(@"error>%@",error);
          }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.listingJSON && self.standardFields ? 3 : 0;
}

- (NSInteger)getNumberOfDetailRows
{
    NSDictionary* standardFieldsJSON = [self.listingJSON objectForKey:@"StandardFields"];
    NSString *propertyType = [standardFieldsJSON objectForKey:@"PropertyType"];
    
    NSArray* keyArray = [self.standardFields keysSortedByValueUsingComparator:^(id obj1, id obj2) {
        NSString *label1 = [obj1 objectForKey:@"Label"];
        NSString *label2 = [obj2 objectForKey:@"Label"];
        return (NSComparisonResult)[label1 compare:label2];
    }];
    
    self.standardFieldsSorted = [[NSMutableArray alloc] init];
    
    for(NSString* key in keyArray)
    {
        NSDictionary *standardField = [self.standardFields objectForKey:key];
        NSArray *mlsVisible = [standardField objectForKey:@"MlsVisible"];
        for(NSString* type in mlsVisible)
        {
            if([type isEqualToString:propertyType])
            {
                [self.standardFieldsSorted addObject:standardField];
                continue;
            }
        }
    }
    
    return [self.standardFieldsSorted count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == 2 ? [self getNumberOfDetailRows] : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *DefaultCellIdentifier = @"ViewListingCell";
    static NSString *DetailLineCellIdentifier = @"ViewListingDetailLineCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:(indexPath.section == 2 ? DetailLineCellIdentifier : DefaultCellIdentifier)];
    
    // Configure the cell...
    if(!cell)
    {
        if(indexPath.section == 2)
        {
            NSArray *bundleArray = [[NSBundle mainBundle] loadNibNamed:DetailLineCellIdentifier owner:self options:nil];
            cell = [bundleArray objectAtIndex:0];
        }
        else
            cell =
                [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:DefaultCellIdentifier];
    }
    
    NSDictionary* standardFieldsJSON = [self.listingJSON objectForKey:@"StandardFields"];
    if(indexPath.section == 0)
    {
        cell.textLabel.text = [ListingFormatter getListingAddress:standardFieldsJSON];
        cell.detailTextLabel.text = [ListingFormatter getListingBedsBathsPrice:standardFieldsJSON];
                        
    }
    else if (indexPath.section == 1)
    {
        NSArray* photosJSON = [standardFieldsJSON objectForKey:@"Photos"];
        NSDictionary *photoJSON = [photosJSON objectAtIndex:indexPath.row];
        
        UIScrollView* scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,0,300,200)];
        scrollView.pagingEnabled = YES;
        scrollView.backgroundColor = [UIColor blackColor];
        scrollView.layer.cornerRadius = 5;
        [cell.contentView addSubview:scrollView];
        scrollView.delegate = self;
        CGFloat xLocation = 0;
        int photoCount = (photosJSON ? [photosJSON count] : 1);
        self.imageViews = [[NSMutableArray alloc] init];
        for(int i = 0; i < photoCount; ++i)
        {
            UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(xLocation,0,300,200)];
            [self.imageViews addObject:imageView];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            imageView.layer.cornerRadius = 5;
            [scrollView addSubview:imageView];
            if(i == 0)
                [imageView setImageWithURL:[NSURL URLWithString:[photoJSON objectForKey:@"Uri300"]]];
            xLocation += 300;
        }
        
        [scrollView setContentSize:CGSizeMake(photoCount * 300, 200)];
        
        self.pageControl = [[UIPageControl alloc] init];
        self.pageControl.center = CGPointMake(150,180);
        self.pageControl.numberOfPages = photoCount;
        [cell.contentView addSubview:self.pageControl];
        [self.pageControl.superview bringSubviewToFront:self.pageControl];
    }
    else if (indexPath.section == 2)
    {
        NSDictionary *standardField = [self.standardFieldsSorted objectAtIndex:indexPath.row];
        UILabel *keyLabel = (UILabel*)[cell viewWithTag:1];
        keyLabel.text = [standardField objectForKey:@"Label"];
        UILabel *valueLabel = (UILabel*)[cell viewWithTag:2];
        valueLabel.text = [self getDetailText:indexPath];
        CGFloat height = [self getDetailTextHeight:valueLabel.text];
        valueLabel.frame = CGRectMake(valueLabel.frame.origin.x,
                                       valueLabel.frame.origin.y,
                                       valueLabel.frame.size.width,
                                       height);
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (NSString*) getDetailText:(NSIndexPath*)indexPath
{
    NSDictionary* standardFieldsJSON = [self.listingJSON objectForKey:@"StandardFields"];
    NSDictionary *standardField = [self.standardFieldsSorted objectAtIndex:indexPath.row];
    NSString* resourceUri = [standardField objectForKey:@"ResourceUri"];
    NSString* type = [standardField objectForKey:@"Type"];
    NSNumber* hasList = [standardField objectForKey:@"HasList"];
    NSObject* object = [standardFieldsJSON objectForKey:[resourceUri lastPathComponent]];
    if([object isKindOfClass:[NSNull class]])
        return nil;
    else if(hasList && [hasList isKindOfClass:[NSNumber class]] && [hasList boolValue] && [object isKindOfClass:[NSDictionary class]])
    {
        NSMutableString *buffer = [[NSMutableString alloc] init];
        for(NSString* key in [((NSDictionary*)object) keyEnumerator])
        {
            if([buffer length] > 0)
                [buffer appendString:@","];
            [buffer appendString:key];
        }
        return buffer;
    }
    else if(([type isEqualToString:@"Date"])  && [object isKindOfClass:[NSDate class]])
        return [simpleDateFormatter stringFromDate:(NSDate*)object];
    else if([type isEqualToString:@"DateTime"] && [object isKindOfClass:[NSDate class]])
        return [simpleDateTimeFormatter stringFromDate:(NSDate*)object];
    else if(([type isEqualToString:@"Integer"] || [type isEqualToString:@"Decimal"]) && [object isKindOfClass:[NSNumber class]])
        return [((NSNumber*)object) stringValue];
    else if([type isEqualToString:@"Character"] && [object isKindOfClass:[NSString class]])
        return (NSString*)object;
    else if([type isEqualToString:@"Boolean"] && [object isKindOfClass:[NSNumber class]])
        return [((NSNumber*)object) boolValue] ? @"true" : @"false";
    else //if([type isEqualToString:@"NULL"])
        return nil;
}

- (CGFloat) getDetailTextHeight:(NSString*)detailText
{
    if(!detailText)
        return 21;
    
    CGSize stringSize = [detailText sizeWithFont:[UIFont systemFontOfSize:14]
                               constrainedToSize:CGSizeMake(290, 9999)
                                   lineBreakMode:UILineBreakModeWordWrap];
    return stringSize.height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
    {
        return 44;
    }
    else if(indexPath.section == 1)
    {
        return 200;
    }
    else
    {
        CGFloat height = [self getDetailTextHeight:[self getDetailText:indexPath]];
        return 16.0 + (height < 21.0 ? 21.0 : height);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 5;
}

// UIScrollViewDelegate ********************************************************

- (void)scrollViewDidEndDecelerating:(UIScrollView *)sv
{
    int page = floor((sv.contentOffset.x - 300 / 2) / 300) + 1;
    [self.pageControl setCurrentPage:page];
 
    NSDictionary* standardFieldsJSON = [self.listingJSON objectForKey:@"StandardFields"];
    NSArray* photosJSON = [standardFieldsJSON objectForKey:@"Photos"];
    NSDictionary *photoJSON = [photosJSON objectAtIndex:page];
    
    UIImageView *imageView = [self.imageViews objectAtIndex:page];
    [imageView setImageWithURL:[NSURL URLWithString:[photoJSON objectForKey:@"Uri300"]]];    
}

@end
