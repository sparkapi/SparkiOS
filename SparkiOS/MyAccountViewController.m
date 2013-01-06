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

#import "iOSConstants.h"
#import "LoginViewController.h"
#import "Keys.h"
#import "JSONHelper.h"
#import "SparkAPI.h"
#import "UIHelper.h"

@interface MyAccountViewController ()

@property (strong, nonatomic) UIActivityIndicatorView *activityView;
@property (strong, nonatomic) NSDictionary *myAccountJSON;

@end

@implementation MyAccountViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"My Account";
    
    UIBarButtonItem *logoutButton =
    [[UIBarButtonItem alloc] initWithTitle:@"Logout"
                                     style:UIBarButtonItemStyleBordered
                                    target:self
                                    action:@selector(logoutAction:)];
    //searchButton.tintColor = [UIColor blueColor];
    self.navigationItem.rightBarButtonItem = logoutButton;
    
    if([UIHelper isOAuth])
    {
        self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.activityView.center = [UIHelper iPhone] ?
            CGPointMake(self.view.center.x,self.view.center.y - NAVBAR_HEIGHT) :
            CGPointMake(160,IPAD_HEIGHT_INSIDE_NAVBAR/2);
        [self.view addSubview:self.activityView];
        [self.activityView startAnimating];
        
        SparkAPI *sparkAPI = [UIHelper getSparkAPI];
        [sparkAPI get:@"/my/account"
           parameters:nil
              success:^(NSArray *resultsJSON) {
                  if(resultsJSON && [resultsJSON count] > 0)
                  {
                      self.myAccountJSON = [resultsJSON objectAtIndex:0];
                      [self.tableView reloadData];
                      [self.activityView stopAnimating];
                  }
              }
              failure:^(NSInteger sparkErrorCode,
                        NSString* sparkErrorMessage,
                        NSError *httpError) {
                  [self.activityView stopAnimating];
                  [UIHelper handleFailure:self code:sparkErrorCode message:sparkErrorMessage error:httpError];
              }];
    }
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return [UIHelper iPhone] ? (interfaceOrientation == UIInterfaceOrientationPortrait) : YES;
}

- (void)logoutAction:(id)sender
{
    [UIHelper logout:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.myAccountJSON || ![UIHelper isOAuth] ? 1 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [UIHelper isOAuth] ? 8 : 6;
}

- (void)myAccountJSONCell:(UITableViewCell*)cell indexPath:(NSIndexPath*)indexPath
{
    if(indexPath.row == 0)
    {
        cell.detailTextLabel.text = @"Name";
        cell.textLabel.text = [JSONHelper getJSONString:self.myAccountJSON key:@"Name"];
    }
    else if(indexPath.row == 1)
    {
        cell.detailTextLabel.text = @"Office";
        cell.textLabel.text = [JSONHelper getJSONString:self.myAccountJSON key:@"Office"];
    }
    else if(indexPath.row == 2)
    {
        cell.detailTextLabel.text = @"Company";
        cell.textLabel.text = [JSONHelper getJSONString:self.myAccountJSON key:@"Company"];
    }
    else if(indexPath.row == 3)
    {
        cell.detailTextLabel.text = @"Address";
        cell.textLabel.text = [self getFirstItem:@"Addresses" key:@"Address"];
    }
    else if(indexPath.row == 4)
    {
        cell.detailTextLabel.text = @"MLS";
        cell.textLabel.text = [JSONHelper getJSONString:self.myAccountJSON key:@"Mls"];
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
}

- (void)myAccountOpenIdCell:(UITableViewCell*)cell indexPath:(NSIndexPath*)indexPath
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if(indexPath.row == 0)
    {
        cell.detailTextLabel.text = @"ID";
        cell.textLabel.text = [defaults objectForKey:OPENID_ID];
    }
    else if(indexPath.row == 1)
    {
        cell.detailTextLabel.text = @"Full Name";
        cell.textLabel.text = [defaults objectForKey:OPENID_FRIENDLY];
    }
    else if(indexPath.row == 2)
    {
        cell.detailTextLabel.text = @"First Name";
        cell.textLabel.text = [defaults objectForKey:OPENID_FIRST_NAME];
    }
    else if(indexPath.row == 3)
    {
        cell.detailTextLabel.text = @"Middle Name";
        cell.textLabel.text = [defaults objectForKey:OPENID_MIDDLE_NAME];
    }
    else if(indexPath.row == 4)
    {
        cell.detailTextLabel.text = @"Last Name";
        cell.textLabel.text = [defaults objectForKey:OPENID_LAST_NAME];
    }
    else if(indexPath.row == 5)
    {
        cell.detailTextLabel.text = @"Email";
        cell.textLabel.text = [defaults objectForKey:OPENID_EMAIL];
    }
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
    
    if([UIHelper isOAuth])
        [self myAccountJSONCell:cell indexPath:indexPath];
    else
        [self myAccountOpenIdCell:cell indexPath:indexPath];
    
    return cell;
}

- (NSString*) getFirstItem:(NSString*)arrayKey key:(NSString*)itemKey
{
    NSArray* arrayJSON = [self.myAccountJSON objectForKey:arrayKey];
    return arrayJSON && [arrayJSON count] > 0 ?
        [JSONHelper getJSONString:((NSDictionary*)[arrayJSON objectAtIndex:0]) key:itemKey] :
        nil;
}

@end
