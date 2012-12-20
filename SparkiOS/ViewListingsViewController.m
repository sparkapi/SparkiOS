//
//  ViewListingsViewController.m
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

#import "ViewListingsViewController.h"

#import "AppDelegate.h"
#import "iOSConstants.h"
#import "ListingFormatter.h"
#import "MyAccountViewController.h"
#import "SparkAPI.h"
#import "UIImageView+AFNetworking.h"
#import "ViewListingViewController.h"

@interface ViewListingsViewController ()

@property (strong, nonatomic) UITextField *searchField;
@property (strong, nonatomic) UIActivityIndicatorView *activityView;
@property (strong, nonatomic) NSArray *listingsJSON;

@end

@implementation ViewListingsViewController

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
    
    self.navigationItem.leftBarButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:@"Account"
                                         style:UIBarButtonItemStyleBordered
                                        target:self
                                        action:@selector(myAccountAction:)];
    
    UIBarButtonItem *searchButton =
        [[UIBarButtonItem alloc] initWithTitle:@"Search"
                                         style:UIBarButtonItemStyleBordered
                                        target:self
                                        action:@selector(searchAction:)];
    searchButton.tintColor = [UIColor blueColor];
    self.navigationItem.rightBarButtonItem = searchButton;
    
    self.searchField = [[UITextField alloc] initWithFrame:CGRectMake(0,0,200,31)];
    self.searchField.font = [UIFont systemFontOfSize:14];
    self.searchField.borderStyle = UITextBorderStyleRoundedRect;
    self.searchField.delegate = self;
    self.searchField.text = @"PropertyType Eq 'A'";
    self.navigationItem.titleView = self.searchField;
    
    self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.activityView.center = CGPointMake(self.view.center.x,self.view.center.y - NAVBAR_HEIGHT);
    [self.view addSubview:self.activityView];
    [self.activityView startAnimating];
    
    self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self searchAction:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.listingsJSON ? 1 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.listingsJSON ? [self.listingsJSON count] : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ViewListingsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary* listingJSON = [self.listingsJSON objectAtIndex:indexPath.row];
    NSDictionary* standardFieldsJSON = [listingJSON objectForKey:@"StandardFields"];
        
    cell.textLabel.text = [ListingFormatter getListingAddress:standardFieldsJSON];    
    cell.detailTextLabel.text = [ListingFormatter getListingBedsBathsPrice:standardFieldsJSON];
    
    // photo
    NSArray* photosJSON = [standardFieldsJSON objectForKey:@"Photos"];
    if(photosJSON && [photosJSON count] > 0)
    {
        NSDictionary* photoJSON = [photosJSON objectAtIndex:0];
        [cell.imageView setImageWithURL:[NSURL URLWithString:[photoJSON objectForKey:@"UriThumb"]] placeholderImage:[UIImage imageNamed:@"DefaultListingPhoto.png"]];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary* listingJSON = [self.listingsJSON objectAtIndex:indexPath.row];
    NSDictionary* standardFieldsJSON = [listingJSON objectForKey:@"StandardFields"];
    NSString* ListingId = [standardFieldsJSON objectForKey:@"ListingId"];
    ViewListingViewController *viewListingVC = [[ViewListingViewController alloc] initWithStyle:UITableViewStyleGrouped];
    viewListingVC.ListingId = ListingId;
    [self.navigationController pushViewController:viewListingVC animated:YES];
}

- (void)myAccountAction:(id)sender
{
    MyAccountViewController* myAccountViewController =
        [[MyAccountViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [self.navigationController pushViewController:myAccountViewController animated:YES];
}

- (void)searchAction:(id)sender
{
    if([self.searchField isFirstResponder])
        [self.searchField resignFirstResponder];
    
    if(!self.searchField.text || [self.searchField.text length] == 0)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Search Error"
                                                            message:@"Please enter search filter."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    if(self.listingsJSON)
    {
        self.listingsJSON = nil;
        self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
        [self.activityView startAnimating];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.tableView reloadData];
    }
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:@"50" forKey:@"_limit"];
    [parameters setObject:@"PrimaryPhoto" forKey:@"_expand"];
    [parameters setObject:@"ListingId,StreetNumber,StreetDirPrefix,StreetName,StreetDirSuffix,StreetSuffix,BedsTotal,BathsTotal,ListPrice" forKey:@"_select"];
    [parameters setObject:self.searchField.text forKey:@"_filter"];
    [parameters setObject:@"-ListPrice" forKey:@"_orderby"];
    
    SparkAPI *sparkAPI =
    ((AppDelegate*)[[UIApplication sharedApplication] delegate]).sparkAPI;
    [sparkAPI get:@"/v1/listings"
       parameters:parameters
          success:^(id responseJSON) {
              self.listingsJSON = (NSArray*)responseJSON;
              [self.activityView stopAnimating];
              if(self.listingsJSON && [self.listingsJSON count] > 0)
              {
                  self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
                  self.view.backgroundColor = [UIColor whiteColor];
                  [self.tableView reloadData];
              }
              else
                  self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
          }
          failure:^(NSError* error) {
              NSLog(@"error>%@",error);
          }];
}

// UITextFieldDelegate *********************************************************

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self searchAction:nil];
}

@end
