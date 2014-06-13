//
//  RequestManager.m
//  Cloudsit
//
//  Created by Ivan Sadikov on 7/06/14.
//  Copyright (c) 2014 Ivan Sadikov. All rights reserved.
//

#import "RequestManager.h"

@interface RequestManager()
@property (nonatomic, strong) NSString *urlString;
@property (nonatomic, strong) NSString *httpMethod;
@property (nonatomic, strong) NSMutableData *responseData;
@end


@implementation RequestManager

static const NSTimeInterval kTimeOutInterval = 180.0;

#pragma mark - RequestManager methods

- (id)initWithURLString:(NSString *)url andHTTPMethod:(RequestManagerHTTPMethod)httpMethod {
    self = [super init];
    if (self) {
        [self setURLString:url andHTTPMethod:httpMethod];
    }
    
    return self;
}

- (void)setURLString:(NSString *)url andHTTPMethod:(RequestManagerHTTPMethod)httpMethod {
    if (self) {
        // set url string
        //self.urlString = [self urlEncodedString:url];
        self.urlString = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        // set http method
        if (httpMethod == RequestManagerHTTPMethodGET) {
            self.httpMethod = @"GET";
        } else if (httpMethod == RequestManagerHTTPMethodPOST) {
            self.httpMethod = @"POST";
        } else {
            self.httpMethod = nil;
        }
        
        // prepare responseData
        if (!self.responseData) {
            self.responseData = [[NSMutableData alloc] init];
        }
    }
}

- (void)sendRequest {    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.urlString]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:kTimeOutInterval];
    [request setValue:@"CloudsitRequest" forHTTPHeaderField:@"User-Agent"];
    [request setHTTPMethod:self.httpMethod];
    
    // we are going to send only GET requests
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [self.connection start];
    
    // call delegate
    [self.delegate requestManager:self startProceedingRequest:request];
}

- (void)cancelRequest {
    if (self.connection) {
        [self.connection cancel];
    }
    
    self.connection = nil;
    
    self.responseData = nil;
    self.httpMethod = nil;
    self.urlString = nil;
}

- (void)handleResponseData:(NSData *)data {
    id result = [self parseJSONResponse:data withError:nil];
    [self.delegate requestManager:self didLoadResult:result];
}

- (id)parseJSONResponse:(NSData *)data withError:(NSError *)responseError {
    NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    SBJSON *jsonParser = [[SBJSON alloc] init];
    id result = [jsonParser objectWithString:response];
    
    if (result == nil) {
        return response;
    }
    
    return result;
}

#pragma mark - NSURLConnectionDelegate methods

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.delegate requestManager:self didReceiveResponse:response];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self handleResponseData:self.responseData];
    [self cancelRequest];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.delegate requestManager:self didFailWithError:error];
    [self cancelRequest];
}

@end
