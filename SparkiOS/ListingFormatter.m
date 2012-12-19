//
//  ListingFormatter.m
//  SparkiOS
//
//  Created by David Ragones on 12/18/12.
//  Copyright (c) 2012 Financial Business Systems, Inc. All rights reserved.
//

#import "ListingFormatter.h"

@implementation ListingFormatter

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

+ (NSString*)getListingAddress:(NSDictionary*)standardFieldsJSON
{
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
    return [address capitalizedString];
}

+ (NSString*)getListingBedsBathsPrice:(NSDictionary*)standardFieldsJSON
{
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
    return subtitle;
}

@end
