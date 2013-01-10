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

#import "JSONHelper.h"

@implementation ListingFormatter

static NSNumberFormatter *currencyFormatter;
static NSDateFormatter *iso8601DateTimeFormatter;
static NSDateFormatter *dateTimeFormatter;

+(void) initialize
{
    @synchronized(self)
    {
        if(!currencyFormatter)
        {
            currencyFormatter = [[NSNumberFormatter alloc] init];
            [currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        }
        
        if(!iso8601DateTimeFormatter)
        {
            iso8601DateTimeFormatter = [[NSDateFormatter alloc] init];
            [iso8601DateTimeFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
        }
        
        if (!dateTimeFormatter)
        {
            dateTimeFormatter = [[NSDateFormatter alloc] init];
            [dateTimeFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        }
    }
}

+ (NSDate*)parseISO8601Date:(NSString*)string
{
    return string ? [iso8601DateTimeFormatter dateFromString:string] : nil;
}

+ (NSString*)formatDateTime:(NSDate*)date
{
    return date ? [dateTimeFormatter stringFromDate:date] : nil;
}

+ (NSString*)formatPriceShort:(NSNumber*)price
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

+ (NSString*)formatPrice:(NSNumber*)price
{
    return (price && [price floatValue] > 0.0) ?
        [currencyFormatter stringFromNumber:price] :
        nil;
}

+ (NSString*)getListingTitle:(NSDictionary*)standardFieldsJSON
{
    if(!standardFieldsJSON)
        return nil;
    
    NSMutableString* address = [[NSMutableString alloc] init];
    NSString* StreetNumber = [JSONHelper getJSONString:standardFieldsJSON key:@"StreetNumber"];
    if(StreetNumber && [self isStandardField:StreetNumber])
        [address appendFormat:@"%@ ", StreetNumber];
    NSString* StreetDirPrefix = [JSONHelper getJSONString:standardFieldsJSON key:@"StreetDirPrefix"];
    if(StreetDirPrefix && [self isStandardField:StreetDirPrefix])
        [address appendFormat:@"%@ ", StreetDirPrefix];
    NSString* StreetName = [JSONHelper getJSONString:standardFieldsJSON key:@"StreetName"];
    if(StreetName && [self isStandardField:StreetName])
        [address appendFormat:@"%@ ", StreetName];
    NSString* StreetDirSuffix = [JSONHelper getJSONString:standardFieldsJSON key:@"StreetDirSuffix"];
    if(StreetDirSuffix && [self isStandardField:StreetDirSuffix])
        [address appendFormat:@"%@ ", StreetDirSuffix];
    NSString* StreetSuffix = [JSONHelper getJSONString:standardFieldsJSON key:@"StreetSuffix"];
    if(StreetSuffix && [self isStandardField:StreetSuffix])
        [address appendFormat:@"%@", StreetSuffix];
    return [address capitalizedString];
}

+ (BOOL) isStandardField:(NSString*)value
{
    return value && [value rangeOfString:@"***"].location == NSNotFound;
}

+ (NSString*)getListingSubtitle:(NSDictionary*)standardFieldsJSON
{
    if(!standardFieldsJSON)
        return nil;
        
    NSMutableString* subtitle = [[NSMutableString alloc] init];
    NSString *City = [JSONHelper getJSONString:standardFieldsJSON key:@"City"];
    if(City)
        [subtitle appendString:City];
    NSString* StateOrProvince = [JSONHelper getJSONString:standardFieldsJSON key:@"StateOrProvince"];
    if(StateOrProvince)
    {
        if([subtitle length] > 0)
            [subtitle appendString:@", "];
        [subtitle appendString:StateOrProvince];
    }
    if([subtitle length] > 0)
        [subtitle appendString:@" - "];
    NSNumber *BedsTotal = [JSONHelper getJSONNumber:standardFieldsJSON key:@"BedsTotal"];
    if(BedsTotal)
        [subtitle appendFormat:@"%@br ", BedsTotal];
    NSString *BathsTotal = [JSONHelper getJSONString:standardFieldsJSON key:@"BathsTotal"];
    if(BathsTotal)
        [subtitle appendFormat:@"%@ba ", BathsTotal];
    NSNumber* ListPrice = [JSONHelper getJSONNumber:standardFieldsJSON key:@"ListPrice"];
    if(ListPrice)
        [subtitle appendFormat:@"%@", [self formatPriceShort:ListPrice]];
    return subtitle;
}

@end
