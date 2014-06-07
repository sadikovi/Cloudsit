//
//  CloudsitWeatherResult.m
//  Cloudsit
//
//  Created by Ivan Sadikov on 7/06/14.
//  Copyright (c) 2014 Ivan Sadikov. All rights reserved.
//

#import "CloudsitWeatherResult.h"

@implementation CloudsitWeatherResult


- (id)initWithDate:(NSString *)dateString andMaxTemperature:(NSString *)maxTemp andMinTemperature:(NSString *)minTemp andWeatherCode:(NSString *)weatherCode {
    self = [super init];
    if (self) {
        [self setupWithDate:dateString andMaxTemperature:maxTemp andMinTemperature:minTemp andWeatherCode:weatherCode];
    }
    
    return self;
}

- (void)setupWithDate:(NSString *)dateString andMaxTemperature:(NSString *)maxTemp andMinTemperature:(NSString *)minTemp andWeatherCode:(NSString *)weatherCode {
    if (self) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        self.date = [dateFormatter dateFromString:dateString];
        self.temperatureMax = maxTemp;
        self.temperatureMin = minTemp;
        self.weatherCode = weatherCode;
    }
}

- (NSString *)weekday {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEE"];
    
    return [dateFormatter stringFromDate:self.date];
}

@end
