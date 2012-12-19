//
//  ListingFormatter.h
//  SparkiOS
//
//  Created by David Ragones on 12/18/12.
//  Copyright (c) 2012 Financial Business Systems, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ListingFormatter : NSObject

+ (NSString*)getListingAddress:(NSDictionary*)standardFieldsJSON;

+ (NSString*)getListingBedsBathsPrice:(NSDictionary*)standardFieldsJSON;

@end
