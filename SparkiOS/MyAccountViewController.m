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
#import "SparkAPI.h"
#import "UIHelper.h"

@interface MyAccountViewController ()

@property (strong, nonatomic) UIActivityIndicatorView *activityView;
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
        self.activityView.center = CGPointMake(self.view.center.x,self.view.center.y - NAVBAR_HEIGHT);
        [self.view addSubview:self.activityView];
        [self.activityView startAnimating];
        
        SparkAPI *sparkAPI = [UIHelper getSparkAPI];
        [sparkAPI get:@"/v1/my/account"
           parameters:nil
              success:^(id responseJSON) {
                  NSArray *resultsJSON = (NSArray*)responseJSON;
                  if(resultsJSON && [responseJSON count] > 0)
                  {
                      self.myAccountJSON = [responseJSON objectAtIndex:0];
                      [self.tableView reloadData];
                      [self.activityView stopAnimating];
                  }
              }
              failure:^(NSError* error) {
                  NSLog(@"error>%@",error);
              }];
    }
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)logoutAction:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:SPARK_ACCESS_TOKEN];
    [defaults removeObjectForKey:SPARK_REFRESH_TOKEN];
    [defaults removeObjectForKey:SPARK_OPENID];
    [defaults removeObjectForKey:OPENID_ID];
    [defaults removeObjectForKey:OPENID_FRIENDLY];
    [defaults removeObjectForKey:OPENID_FIRST_NAME];
    [defaults removeObjectForKey:OPENID_MIDDLE_NAME];
    [defaults removeObjectForKey:OPENID_LAST_NAME];
    [defaults removeObjectForKey:OPENID_EMAIL];
    
    LoginViewController *loginVC = [[LoginViewController alloc] initWithNibName:([UIHelper iPhone] ? @"LoginViewController" : @"LoginViewController-iPad") bundle:nil];
    loginVC.title = @"Login";
    
    if([UIHelper iPhone])
        [self.navigationController setViewControllers:[NSArray arrayWithObject:loginVC] animated:YES];
    else
    {
        AppDelegate *appDelegate = [UIHelper getAppDelegate];
        appDelegate.window.rootViewController = loginVC;
    }
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
        [((NSDictionary*)[arrayJSON objectAtIndex:0]) objectForKey:itemKey] :
        nil;
}

@end
