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

#import "AppDelegate.h"
#import "ListingFormatter.h"

@interface ViewListingViewController ()

@property (strong, nonatomic) NSDictionary *listingJSON;
@property (strong, nonatomic) NSArray *standardFields;

@end

@implementation ViewListingViewController

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
              self.standardFields = (NSArray*)responseJSON;
              NSLog(@"standardFields>%@",self.standardFields);
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ViewListingCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if(!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    
    NSDictionary* standardFieldsJSON = [self.listingJSON objectForKey:@"StandardFields"];
    if(indexPath.section == 0)
    {
        cell.textLabel.text = [ListingFormatter getListingAddress:standardFieldsJSON];
        cell.detailTextLabel.text = [ListingFormatter getListingBedsBathsPrice:standardFieldsJSON];
                        
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 5;
}

@end
