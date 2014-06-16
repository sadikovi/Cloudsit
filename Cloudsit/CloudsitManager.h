//
//  CloudsitManager.h
//  Cloudsit
//
//  Created by Ivan Sadikov on 7/06/14.
//  Copyright (c) 2014 Ivan Sadikov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RequestManager.h"
#import "SettingsManager.h"
#import "DateManager.h"

@protocol CloudsitManagerDelegate;

enum {
    CloudsitManagerStateReady,
    CloudsitManagerStateProceeding,
    CloudsitManagerStateFinished
} typedef CloudsitManagerState;

@interface CloudsitManager : NSObject
<RequestManagerDelegate>

#define CloudsitManagerDataCurrentConditionKey  @"current-condition-key"
#define CloudsitManagerDataWeatherKey           @"weather-key"
#define CloudsitManagerDataLocationKey          @"location-key"

@property (nonatomic, strong) RequestManager *requestManager;
@property (nonatomic, strong, readonly) NSString *location;
@property (nonatomic, weak) id <CloudsitManagerDelegate> delegate;

- (id)initWithRequestManager:(BOOL)loadManager;
- (void)setURLStringForRefresh:(NSString *)url;
- (void)refreshDataForLocation:(NSString *)location;

@end


@protocol CloudsitManagerDelegate
- (void)managerDidSendRequestWithURL:(CloudsitManager *)manager;
- (void)manager:(CloudsitManager *)manager didReceiveResult:(NSDictionary *)result;
- (void)manager:(CloudsitManager *)manager didFailWithError:(NSError *)error;
@end