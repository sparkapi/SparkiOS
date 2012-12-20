//
//  MyAccountViewController.m
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

#import "MyAccountViewController.h"

#import "AppDelegate.h"
#import "SparkAPI.h"

@interface MyAccountViewController ()

@property (strong, nonatomic) NSDictionary *myAccountJSON;

@end

@implementation MyAccountViewController

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
    
    self.title = @"My Account";
    
    SparkAPI *sparkAPI =
        ((AppDelegate*)[[UIApplication sharedApplication] delegate]).sparkAPI;
    [sparkAPI get:@"/v1/my/account"
       parameters:nil
          success:^(id responseJSON) {
              NSArray *resultsJSON = (NSArray*)responseJSON;
              if(resultsJSON && [responseJSON count] > 0)
              {
                  self.myAccountJSON = [responseJSON objectAtIndex:0];
                  [self.tableView reloadData];
              }
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
    return self.myAccountJSON ? 1 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 8;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MyAccountCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
    }
        
    if(indexPath.row == 0)
    {
        cell.detailTextLabel.text = @"Name";
        cell.textLabel.text = [self.myAccountJSON objectForKey:@"Name"];
    }
    else if(indexPath.row == 1)
    {
        cell.detailTextLabel.text = @"Office";
        cell.textLabel.text = [self.myAccountJSON objectForKey:@"Office"];
    }
    else if(indexPath.row == 2)
    {
        cell.detailTextLabel.text = @"Company";
        cell.textLabel.text = [self.myAccountJSON objectForKey:@"Company"];
    }
    else if(indexPath.row == 3)
    {
        cell.detailTextLabel.text = @"Address";
        cell.textLabel.text = [self getFirstItem:@"Addresses" key:@"Address"];
    }
    else if(indexPath.row == 4)
    {
        cell.detailTextLabel.text = @"MLS";
        cell.textLabel.text = [self.myAccountJSON objectForKey:@"Mls"];
    }
    else if(indexPath.row == 5)
    {
        cell.detailTextLabel.text = @"Email";
        cell.textLabel.text = [self getFirstItem:@"Emails" key:@"Address"];
    }
    else if(indexPath.row == 6)
    {
        cell.detailTextLabel.text = @"Phone";
        cell.textLabel.text = [self getFirstItem:@"Phones" key:@"Number"];
    }
    else if(indexPath.row == 7)
    {
        cell.detailTextLabel.text = @"Website";
        cell.textLabel.text = [self getFirstItem:@"Websites" key:@"Uri"];
    }
    
    return cell;
}

- (NSString*) getFirstItem:(NSString*)arrayKey key:(NSString*)itemKey
{
    NSArray* arrayJSON = [self.myAccountJSON objectForKey:arrayKey];
    return arrayJSON && [arrayJSON count] > 0 ?
        [((NSDictionary*)[arrayJSON objectAtIndex:0]) objectForKey:itemKey] :
        nil;
}

@end
