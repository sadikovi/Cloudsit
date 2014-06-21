//
//  WeatherManager.m
//  Cloudsit
//
//  Created by Ivan Sadikov on 15/06/14.
//  Copyright (c) 2014 Ivan Sadikov. All rights reserved.
//

#import "WeatherManager.h"
/*
395 Moderate or heavy snow in area with thunder
392 Patchy light snow in area with thunder
389 Moderate or heavy rain in area with thunder
386 Patchy light rain in area with thunder
377 Moderate or heavy showers of ice pellets
374 Light showers of ice pellets
371 Moderate or heavy snow showers
368 Light snow showers
365 Moderate or heavy sleet showers
362 Light sleet showers
359 Torrential rain shower
356 Moderate or heavy rain shower
353 Light rain shower
350 Ice pellets
338 Heavy snow
335 Patchy heavy snow
332 Moderate snow
329 Patchy moderate snow
326 Light snow
323 Patchy light snow
320 Moderate or heavy sleet
317 Light sleet
314 Moderate or Heavy freezing rain
311 Light freezing rain

308 Heavy rain
305 Heavy rain at times
302 Moderate rain
299 Moderate rain at times
296 Light rain
293 Patchy light rain
284 Heavy freezing drizzle
281 Freezing drizzle
266 Light drizzle
263 Patchy light drizzle
260 Freezing fog
248 Fog
230 Blizzard
227 Blowing snow
200 Thundery outbreaks in nearby
185 Patchy freezing drizzle nearby
182 Patchy sleet nearby
179 Patchy snow nearby
176 Patchy rain nearby
143 Mist
122 Overcast
119 Cloudy
116 Partly Cloudy
113 Clear/Sunny
 */


#define DAY_TIME_POSTFIX    @"-0"
#define NIGHT_TIME_POSTFIX  @"-1"

@interface WeatherManager()
@property (nonatomic, strong) NSDictionary *codes;
@end

@implementation WeatherManager

/**
 * Singleton for Weather manager
 *
 */
+ (WeatherManager *)defaultManager {
    static WeatherManager *sharedObject = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedObject = [self new];
    });
    
    return sharedObject;
}

- (id)init {
    self = [super init];
    if (self) {
        self.codes = [NSDictionary dictionary];
        self.codes = [self dictionaryWithCodesAndImageNames];
    }
    
    return self;
}

- (NSDictionary *)dictionaryWithCodesAndImageNames {
    NSDictionary *codesAndImages = [NSDictionary dictionaryWithObjectsAndKeys:
                                    @"weather-snowy-h", @"395",         // Moderate or heavy snow in area with thunder
                                    @"weather-snowy-s", @"392",         // Patchy light snow in area with thunder
                                    @"weather-thunder-rainy-h", @"389", // Moderate or heavy rain in area with thunder
                                    @"weather-thunder-rainy-s", @"386", // Patchy light rain in area with thunder
                                    
                                    @"weather-snowy-m", @"377",         // Moderate or heavy showers of ice pellets
                                    @"weather-snowy-s", @"374",         // Light showers of ice pellets
                                    @"weather-snowy-m", @"371",         // Moderate or heavy snow showers
                                    @"weather-snowy-s", @"368",         // Light snow showers
                                    @"weather-rainy-snowy", @"365",     // Moderate or heavy sleet showers
                                    @"weather-rainy-snowy", @"362",     // Light sleet showers
                                    @"weather-rainy-h", @"359",         // Torrential rain shower
                                    @"weather-rainy-h", @"356",         // Moderate or heavy rain shower
                                    
                                    @"weather-rainy-h", @"353",         // Light rain shower
                                    @"weather-rainy-snowy", @"350",     // Ice pellets
                                    @"weather-snowy-h", @"338",         // Heavy snow
                                    @"weather-snowy-h", @"335",         // Patchy heavy snow
                                    @"weather-snowy-m", @"332",         // Moderate snow
                                    
                                    @"weather-snowy-m", @"329",         // Patchy moderate snow
                                    @"weather-snowy-s", @"326",         // Light snow
                                    @"weather-snowy-s", @"323",         // Patchy light snow
                                    @"weather-rainy-snowy", @"320",     // Moderate or heavy sleet
                                    @"weather-rainy-snowy", @"317",     // Light sleet
                                    @"weather-rainy-m", @"314",         // Moderate or Heavy freezing rain
                                    @"weather-rainy-s", @"311",         // Light freezing rain
                                    
                                    @"weather-rainy-h", @"308",         // Heavy rain
                                    @"weather-rainy-h", @"305",         // Heavy rain at times
                                    @"weather-rainy-m", @"302",         // Moderate rain
                                    @"weather-rainy-m", @"299",         // Moderate rain at times
                                    @"weather-rainy-m", @"296",         // Light rain
                                    @"weather-rainy-m", @"293",         // Patchy light rain
                                    @"weather-rainy-m", @"284",         // Heavy freezing drizzle
                                    
                                    @"weather-rainy-s", @"281",         // Freezing drizzle
                                    @"weather-rainy-s", @"266",         // Light drizzle
                                    @"weather-rainy-s", @"263",         // Patchy light drizzle
                                    @"weather-cloudy-fog", @"260",      // Freezing fog
                                    @"weather-cloudy-fog", @"248",      // Fog
                                    @"weather-windy", @"230",           // Blizzard
                                    
                                    @"weather-snowy-m", @"227",         // Blowing snow
                                    @"weather-thunder", @"200",         // Thundery outbreaks in nearby
                                    @"weather-rainy-snowy", @"185",     // Patchy freezing drizzle nearby
                                    @"weather-rainy-snowy", @"182",     // Patchy sleet nearby
                                    @"weather-snowy-s", @"179",         // Patchy snow nearby
                                    @"weather-rainy-s", @"176",         // Patchy rain nearby
                                    
                                    @"weather-cloudy-fog", @"143",      // Mist
                                    @"weather-cloudy", @"122",          // Overcast
                                    @"weather-cloudy", @"119",          // Cloudy
                                    @"weather-partlycloudy", @"116",    // Partly Cloudy
                                    @"weather-sunny", @"113",           // Clear/Sunny
                                    nil];
    
    
    return codesAndImages;
}

- (UIImage *)imageForWeatherCode:(NSString *)code andDayTime:(BOOL)isDayTime {
    NSString *imageName = (NSString *)[self.codes objectForKey:code];
    
    if (isDayTime) {
        if ([UIImage imageNamed:imageName] == nil) {
            return [UIImage imageNamed:[imageName stringByAppendingString:DAY_TIME_POSTFIX]];
        } else {
            return [UIImage imageNamed:imageName];
        }
    } else {
        if ([UIImage imageNamed:imageName] == nil) {
            return [UIImage imageNamed:[imageName stringByAppendingString:NIGHT_TIME_POSTFIX]];
        } else {
            return [UIImage imageNamed:imageName];
        }
    }
}

@end
