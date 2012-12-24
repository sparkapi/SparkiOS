Spark iOS API and Example App
=============================

The SparkAPI object is designed as a standalone Objective-C interface for use with the [Spark API](http://www.sparkplatform.com/docs/overview/api).  

This project also includes an example iPad and iPhone app that makes use of SparkAPI object to [authenticate](http://www.sparkplatform.com/docs/authentication/authentication) via Hybrid and OpenID methods, search listings, view listings, view an individual listing, and view a user account.

## Requirements

* iOS 5 or later
* XCode 4.2 or later
* Running the code on an iOS device requires an active Apple Developer account

## Configuration

Once you [register](http://www.sparkplatform.com/register/developers) as a Spark developer and receive your Spark Client Id and Client Secret, open the SparkAPI.m file and set the sparkClientId, sparkClientSecret constants.  The sparkCallbackURL can also be customized but you most likely will want to use the default value.

``` objective-c
@implementation SparkAPI

// configuration ***************************************************************

static NSString* sparkClientKey = @"<YOUR OAUTH2 CLIENT KEY>";
static NSString* sparkClientSecret = @"<YOUR OAUTH2 CLIENT SECRET>";
static NSString* sparkCallbackURL = @"https://sparkplatform.com/oauth2/callback";
```

## API Example

### Authenticate


``` objective-c
+ (BOOL) hybridAuthenticate:(NSURLRequest*)request
             success:(void(^)(SparkAPI* sparkAPI))success
             failure:(void(^)(NSString* openIdMode, NSString* openIdError, NSError *httpError))failure;

+ (BOOL) openIdAuthenticate:(NSURLRequest*)request
                         success:(void(^)(SparkAPI* sparkAPI, NSDictionary* parameters))success
                         failure:(void(^)(NSString* openIdMode, NSString* openIdError))failure;
```


### API call

## Dependencies

* [AFNetworking 1.0.1](https://github.com/AFNetworking/AFNetworking)
* [SBJSON 3.1](http://stig.github.com/json-framework/)

## Compatability

Tested OSs: iOS6, iOS5

Tested XCode versions: 4.5, 4.2

Tested Devices: iPad 3, iPad mini, iPad 1, iPhone 5, iPhone 4