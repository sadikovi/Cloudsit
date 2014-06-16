//
//  BSPlaceManager.h
//  Cloudsit
//
//  Created by Ivan Sadikov on 13/06/14.
//  Copyright (c) 2014 Ivan Sadikov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BSPlaceResult.h"
#import "SBJSON.h"

/**
 * BSPlaceManager is used to retrieve data from Google Place Autocomplete service.
 * Returns result as an array of BSPlaceResult objects.
 * Manager has only one connection per time.
 * Every new request will terminate previous one.
 *
 */

@protocol BSPlaceManagerDelegate;

typedef enum {
    BSPlaceManagerResponseStatusSuccess = 200,
    BSPlaceManagerResponseStatusError = 499
} BSPlaceManagerResponseStatus;


@interface BSPlaceManager : NSObject

@property (nonatomic, weak) id <BSPlaceManagerDelegate> delegate;

- (void)searchPlace:(NSString *)place;
- (BOOL)connectionIsActive;
- (void)startRequest;
- (void)stopRequest;

@end

@protocol BSPlaceManagerDelegate <NSObject>
- (void)placeManager:(BSPlaceManager *)manager processingRequest:(NSURLRequest *)request;
- (void)placeManager:(BSPlaceManager *)manager didReceiveResult:(NSArray *)places;
- (void)placeManager:(BSPlaceManager *)manager didFailWithError:(NSError *)error;
@end
