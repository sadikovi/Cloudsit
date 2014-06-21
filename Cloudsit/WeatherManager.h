//
//  WeatherManager.h
//  Cloudsit
//
//  Created by Ivan Sadikov on 15/06/14.
//  Copyright (c) 2014 Ivan Sadikov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeatherManager : NSObject

+ (WeatherManager *)defaultManager;
- (UIImage *)imageForWeatherCode:(NSString *)code andDayTime:(BOOL)isDayTime;

@end
