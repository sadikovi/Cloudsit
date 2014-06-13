//
//  RequestManager.h
//  Cloudsit
//
//  Created by Ivan Sadikov on 7/06/14.
//  Copyright (c) 2014 Ivan Sadikov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBJSON.h"

@protocol RequestManagerDelegate;

@interface RequestManager : NSObject

enum {
    RequestManagerHTTPMethodPOST,
    RequestManagerHTTPMethodGET
} typedef RequestManagerHTTPMethod;

@property (nonatomic, weak) id<RequestManagerDelegate> delegate;
@property (nonatomic, strong) NSURLConnection *connection;

- (id)initWithURLString:(NSString *)urlString andHTTPMethod:(RequestManagerHTTPMethod)httpMethod;
- (void)setURLString:(NSString *)urlString andHTTPMethod:(RequestManagerHTTPMethod)httpMethod;
- (void)sendRequest;
- (void)cancelRequest;

@end


@protocol RequestManagerDelegate
- (void)requestManager:(RequestManager *)manager startProceedingRequest:(NSURLRequest *)request;
- (void)requestManager:(RequestManager *)manager didReceiveResponse:(NSURLResponse *)response;
- (void)requestManager:(RequestManager *)manager didLoadResult:(id)result;
- (void)requestManager:(RequestManager *)manager didFailWithError:(NSError *)error;
@end