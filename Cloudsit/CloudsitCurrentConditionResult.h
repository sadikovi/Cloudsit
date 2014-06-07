//
//  CloudsitCurrentConditionResult.h
//  Cloudsit
//
//  Created by Ivan Sadikov on 8/06/14.
//  Copyright (c) 2014 Ivan Sadikov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CloudsitCurrentConditionResult : NSObject

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSString *temperature;
@property (nonatomic, strong) NSString *weatherCode;

- (id)initWithDate:(NSString *)dateString andTemperature:(NSString *)temp andWeatherCode:(NSString *)weatherCode;

@end
