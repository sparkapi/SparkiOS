//
//  ViewListingsViewController.m
//  SparkiOS
//
//  Created by David Ragones on 12/18/12.
//  Copyright (c) 2012 Financial Business Systems, Inc. All rights reserved.
//

#import "ViewListingsViewController.h"

#import "MyAccountViewController.h"

@interface ViewListingsViewController ()

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

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (void)myAccountAction:(id)sender
{
    MyAccountViewController* myAccountViewController =
        [[MyAccountViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [self.navigationController pushViewController:myAccountViewController animated:YES];
}

- (void)searchAction:(id)sender
{
    NSLog(@"search");
}

@end
