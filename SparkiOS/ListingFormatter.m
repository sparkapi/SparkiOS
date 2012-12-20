//
//  ListingFormatter.m
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

#import "ListingFormatter.h"

@implementation ListingFormatter

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


+ (NSString*)displayPrice:(NSNumber*)price
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

+ (NSString*)getListingTitle:(NSDictionary*)standardFieldsJSON
{
    if(!standardFieldsJSON)
        return nil;
    
    NSMutableString* address = [[NSMutableString alloc] init];
    NSString* StreetNumber = [standardFieldsJSON objectForKey:@"StreetNumber"];
    if(StreetNumber && ![StreetNumber isKindOfClass:[NSNull class]])
        [address appendFormat:@"%@ ", StreetNumber];
    NSString* StreetDirPrefix = [standardFieldsJSON objectForKey:@"StreetDirPrefix"];
    if(StreetDirPrefix && ![StreetDirPrefix isKindOfClass:[NSNull class]])
        [address appendFormat:@"%@ ", StreetDirPrefix];
    NSString* StreetName = [standardFieldsJSON objectForKey:@"StreetName"];
    if(StreetName && ![StreetName isKindOfClass:[NSNull class]])
        [address appendFormat:@"%@ ", StreetName];
    NSString* StreetDirSuffix = [standardFieldsJSON objectForKey:@"StreetDirSuffix"];
    if(StreetDirSuffix && ![StreetDirSuffix isKindOfClass:[NSNull class]])
        [address appendFormat:@"%@ ", StreetDirSuffix];
    NSString* StreetSuffix = [standardFieldsJSON objectForKey:@"StreetDirSuffix"];
    if(StreetSuffix && ![StreetSuffix isKindOfClass:[NSNull class]])
        [address appendFormat:@"%@", StreetSuffix];
    return [address capitalizedString];
}

+ (NSString*)getListingSubtitle:(NSDictionary*)standardFieldsJSON
{
    if(!standardFieldsJSON)
        return nil;
        
    NSMutableString* subtitle = [[NSMutableString alloc] init];
    NSString *City = [standardFieldsJSON objectForKey:@"City"];
    if(City)
        [subtitle appendString:City];
    NSString* StateOrProvince = [standardFieldsJSON objectForKey:@"StateOrProvince"];
    if(StateOrProvince)
    {
        if([subtitle length] > 0)
            [subtitle appendString:@", "];
        [subtitle appendString:StateOrProvince];
    }
    if([subtitle length] > 0)
        [subtitle appendString:@" - "];
    NSNumber *BedsTotal = [standardFieldsJSON objectForKey:@"BedsTotal"];
    if(BedsTotal)
        [subtitle appendFormat:@"%@br ", BedsTotal];
    NSString *BathsTotal = [standardFieldsJSON objectForKey:@"BathsTotal"];
    if(BathsTotal)
        [subtitle appendFormat:@"%@ba ", BathsTotal];
    NSNumber* ListPrice = [standardFieldsJSON objectForKey:@"ListPrice"];
    if(ListPrice)
        [subtitle appendFormat:@"%@", [self displayPrice:ListPrice]];
    return subtitle;
}

@end
