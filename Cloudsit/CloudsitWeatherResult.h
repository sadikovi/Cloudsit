//
//  CloudsitWeatherResult.h
//  Cloudsit
//
//  Created by Ivan Sadikov on 7/06/14.
//  Copyright (c) 2014 Ivan Sadikov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CloudsitWeatherResult : NSObject

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSString *temperatureMax;
@property (nonatomic, strong) NSString *temperatureMin;
@property (nonatomic, strong, readonly) NSString *weekday;
@property (nonatomic, strong) NSString *weatherCode;

- (id)initWithDate:(NSString *)dateString andMaxTemperature:(NSString *)maxTemp andMinTemperature:(NSString *)minTemp andWeatherCode:(NSString *)weatherCode;

@end
