Spark iOS API and Example App
=============================

The `SparkAPI` object is designed as a standalone Objective-C interface for use with the [Spark API](http://www.sparkplatform.com/docs/overview/api).  It implements Spark [authentication](http://www.sparkplatform.com/docs/authentication/authentication) via the Hybrid or OpenID methods.  API calls per HTTP method provide a high-level Spark API interface and return a JSON results array on success while handling erros like session expiration for the client.

This project includes an example iPad and iPhone app that makes use of `SparkAPI` object to authenticate via Hybrid or OpenID methods, search listings, view listings, view an individual listing with photos and standard fields, and view a user account.  View app [screenshots](./SparkiOS/blob/master/Spark iOS Screenshots.pdf) for iPad and iPhone.

## Requirements

* iOS 5 or later
* XCode 4.2 or later
* Running the code on an iOS device requires an active Apple Developer account

## Configuration

Once you [register](http://www.sparkplatform.com/register/developers) as a Spark developer and receive your Spark Client Id and Client Secret, open the SparkAPI.m file and set the `sparkClientId` and `sparkClientSecret` constants.  The `sparkCallbackURL` can also be customized but you most likely will want to use the default value.

``` objective-c
@implementation SparkAPI

// configuration ***************************************************************

static NSString* sparkClientKey = @"<YOUR OAUTH2 CLIENT KEY>";
static NSString* sparkClientSecret = @"<YOUR OAUTH2 CLIENT SECRET>";
static NSString* sparkCallbackURL = @"https://sparkplatform.com/oauth2/callback";
```

## API Examples

### Authentication

SparkAPI provides two class methods for processing authentication and returning a SparkAPI object upon success: 

* **hybridAuthenticate** implements the Spark [OpenID+OAuth 2 Hybrid Protocol](http://www.sparkplatform.com/docs/authentication/openid_oauth2_authentication)
* **openIdAuthenticate** implements the Spark [OpenID Attribute Exchange Extension](http://www.sparkplatform.com/docs/authentication/openid_authentication).  

Both utilize callback blocks that receive asynchronous responses from the Spark API on success or failure.

``` objective-c
+ (BOOL) hybridAuthenticate:(NSURLRequest*)request
             success:(void(^)(SparkAPI* sparkAPI))success
             failure:(void(^)(NSString* openIdMode, NSString* openIdError, NSError *httpError))failure;

+ (BOOL) openIdAuthenticate:(NSURLRequest*)request
                         success:(void(^)(SparkAPI* sparkAPI, NSDictionary* parameters))success
                         failure:(void(^)(NSString* openIdMode, NSString* openIdError))failure;
```

These authentication methods are typically placed in a UIWebViewDelegate object to respond to a NSURLRequest generated after the user provides their Spark credentials.  See [LoginViewController.m](./SparkiOS/blob/master/SparkiOS/LoginViewController.m) for an example.

``` objective-c
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if([SparkAPI hybridAuthenticate:request
                            success:^(SparkAPI *sparkAPI) {
                                [self processAuthentication:sparkAPI parameters:nil];
                            }
                            failure:^(NSString* openIdMode, NSString* openIdError, NSError *httpError) {
                                NSString* message = nil;
                                if(openIdMode)
                                    message = [self handleOpenIdError:openIdMode openIdError:openIdError];
                                [UIHelper handleFailure:message error:httpError];
                            }])
        return NO;
    else
        return YES;
}
```

### Making API calls

Once an authenticated `SparkAPI` object is instantiated, api methods corresponding to the four HTTP methods are available as well as general `api` method.  Similar to the authentication methods, all utilize callback blocks that receive asynchronous responses from the Spark API on success or failure.  

On success, the results JSON array is parsed from the Spark response object and provided as an argument to the success block.

On failure, `sparkErrorCode` and `sparkErrorMessage` are parsed from the returned JSON and provided as arguments to the failure block.

Session renewal is handled automatically by the `SparkAPI` object when a session token expire [error code](http://www.sparkplatform.com/docs/supporting_documentation/error_codes) is returned by the API.

``` objective-c
- (void) get:(NSString*)apiCommand
  parameters:(NSDictionary*)parameters
     success:(void(^)(NSArray *resultsJSON))success
     failure:(void(^)(NSInteger sparkErrorCode,
                      NSString* sparkErrorMessage,
                      NSError *httpError))failure;

- (void) post:(NSString*)apiCommand
   parameters:(NSDictionary*)parameters
      success:(void(^)(NSArray *resultsJSON))success
      failure:(void(^)(NSInteger sparkErrorCode,
                       NSString* sparkErrorMessage,
                       NSError *httpError))failure;

- (void) put:(NSString*)apiCommand
  parameters:(NSDictionary*)parameters
     success:(void(^)(NSArray *resultsJSON))success
     failure:(void(^)(NSInteger sparkErrorCode,
                      NSString* sparkErrorMessage,
                      NSError *httpError))failure;

- (void) delete:(NSString*)apiCommand
     parameters:(NSDictionary*)parameters
        success:(void(^)(NSArray *resultsJSON))success
        failure:(void(^)(NSInteger sparkErrorCode,
                 NSString* sparkErrorMessage,
                 NSError *httpError))failure;

- (void) api:(NSString*)apiCommand
  httpMethod:(NSString*)httpMethod
  parameters:(NSDictionary*)parameters
     success:(void(^)(NSArray *resultsJSON))success
     failure:(void(^)(NSInteger sparkErrorCode,
                      NSString* sparkErrorMessage,
                      NSError *httpError))failure;
```

Below is an example API call to the `/my/account` Spark API endpoint from the example app.  On success, the table view interface is updated.  On failure, an alert view is presented to the user.

``` objective-c
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
```

### Logging

The `SparkAPI` object contains basic log level metering to control output of log messages to the console.  By default, the `logLevel` property is set to `SPARK_LOG_LEVEL_INFO` to output each API call to the console.  To output only errors to the console, set the `logLevel` property to `SPARK_LOG_LEVEL_ERROR`.

## Dependencies

* [AFNetworking 1.0.1](https://github.com/AFNetworking/AFNetworking)
* [SBJSON 3.1](http://stig.github.com/json-framework/)

## Compatability

Tested OSs: iOS 6, iOS 5

Tested XCode versions: 4.5

Tested Devices: iPad 3, iPad mini, iPad 1, iPhone 5, iPhone 4