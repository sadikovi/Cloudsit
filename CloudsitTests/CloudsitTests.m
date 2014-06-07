//
//  CloudsitTests.m
//  CloudsitTests
//
//  Created by Ivan Sadikov on 7/06/14.
//  Copyright (c) 2014 Ivan Sadikov. All rights reserved.
//

#import "CloudsitTests.h"
#import "RequestManager.h"

@implementation CloudsitTests

- (void)setUp
{
    [super setUp];

    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testExample
{
    //STFail(@"Unit tests are not implemented yet in CloudsitTests");
    NSLog(@"Run tests");
    [self firstTest];
}

- (void)firstTest {
    NSString *url = @"http://httpbin.org/get";
    RequestManager *manager = [[RequestManager alloc] initWithURLString:url andHTTPMethod:RequestManagerHTTPMethodGET];
    manager.delegate = self;
    [manager sendRequest];
}

- (void)requestManager:(RequestManager *)manager startProceedingRequest:(NSURLRequest *)request {
    // do nothing
    NSLog(@"Request started");
}

- (void)requestManager:(RequestManager *)manager didReceiveResponse:(NSURLResponse *)response {
    // do nothing
    NSLog(@"Response received");
}

- (void)requestManager:(RequestManager *)manager didLoadResult:(id)result {
    NSLog(@"Result obtained");
    
    if (![result isKindOfClass:[NSDictionary class]]) {
        STFail(@"Request is not a dictionary");
    }
}

- (void)requestManager:(RequestManager *)manager didFailWithError:(NSError *)error {
    STFail(@"Request is failed");
}
 
 
@end
