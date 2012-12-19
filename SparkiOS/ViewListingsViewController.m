//
//  ViewListingsViewController.m
//  SparkiOS
//
//  Created by David Ragones on 12/18/12.
//  Copyright (c) 2012 Financial Business Systems, Inc. All rights reserved.
//

#import "ViewListingsViewController.h"

#import "AppDelegate.h"
#import "MyAccountViewController.h"
#import "SparkAPI.h"
#import "UIImageView+AFNetworking.h"

@interface ViewListingsViewController ()

@property (strong, nonatomic) UITextField *searchField;
@property (strong, nonatomic) NSArray *listingsJSON;

@end

@implementation ViewListingsViewController

static NSString* nullString = @"<null>";

static NSNumberFormatter *currencyFormatter;

+(void) initialize
{
    @synchronized(self)
    {
        if(!currencyFormatter)
        {
            currencyFormatter = [[NSNumberFormatter alloc] init];
            [currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
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
    self.navigationItem.titleView = self.searchField;
    
    //self.tableView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
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
        
    // address
    NSMutableString* address = [[NSMutableString alloc] init];
    NSString* StreetNumber = [standardFieldsJSON objectForKey:@"StreetNumber"];
    if(StreetNumber && ![nullString isEqualToString:StreetNumber])
        [address appendFormat:@"%@ ", StreetNumber];
    NSString* StreetDirPrefix = [standardFieldsJSON objectForKey:@"StreetDirPrefix"];
    if(StreetDirPrefix && ![nullString isEqualToString:StreetDirPrefix])
        [address appendFormat:@"%@ ", StreetDirPrefix];
    NSString* StreetName = [standardFieldsJSON objectForKey:@"StreetName"];
    if(StreetName && ![nullString isEqualToString:StreetName])
        [address appendFormat:@"%@ ", StreetName];
    NSString* StreetDirSuffix = [standardFieldsJSON objectForKey:@"StreetDirSuffix"];
    if(StreetDirSuffix && ![nullString isEqualToString:StreetDirPrefix])
        [address appendFormat:@"%@ ", StreetDirSuffix];
    NSString* StreetSuffix = [standardFieldsJSON objectForKey:@"StreetDirSuffix"];
    if(StreetSuffix && ![nullString isEqualToString:StreetSuffix])
        [address appendFormat:@"%@", StreetSuffix];
    cell.textLabel.text = [address capitalizedString];
    
    // beds, baths, price
    NSMutableString* subtitle = [[NSMutableString alloc] init];
    NSNumber *BedsTotal = [standardFieldsJSON objectForKey:@"BedsTotal"];
    if(BedsTotal)
        [subtitle appendFormat:@"%@br ", BedsTotal];
    NSString *BathsTotal = [standardFieldsJSON objectForKey:@"BathsTotal"];
    if(BathsTotal)
        [subtitle appendFormat:@"%@ba ", BathsTotal];
    NSNumber* ListPrice = [standardFieldsJSON objectForKey:@"ListPrice"];
    if(ListPrice)
        [subtitle appendFormat:@"%@", [self displayPrice:ListPrice]];
    cell.detailTextLabel.text = subtitle;
    
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

- (NSString*)displayPrice:(NSNumber*)price
{
    if(price && [price floatValue] > 0.0)
    {
        NSMutableString *buffer = [[NSMutableString alloc] init];
        int trimmedPrice = [price floatValue] / 1000;
        if(trimmedPrice < 1000)
        {
            [currencyFormatter setGeneratesDecimalNumbers:NO];
            [currencyFormatter setMaximumFractionDigits:0];
            [buffer appendString:[currencyFormatter stringFromNumber:[NSNumber numberWithInt:trimmedPrice]]];
            [buffer appendString:@"K"];
        }
        else
        {
            [currencyFormatter setGeneratesDecimalNumbers:YES];
            float trimmedPriceFloat = trimmedPrice / 1000.0;
            if(trimmedPrice % 1000 == 0)
                [currencyFormatter setMaximumFractionDigits:0];
            else
                [currencyFormatter setMaximumFractionDigits:2];
            [buffer appendString:[currencyFormatter stringFromNumber:[NSNumber numberWithFloat:trimmedPriceFloat]]];
            [buffer appendString:@"M"];
        }
        return buffer;
    }
    return nil;
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
              if(self.listingsJSON && [self.listingsJSON count] > 0)
              {
                  self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
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
