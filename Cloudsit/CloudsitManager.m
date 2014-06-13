//
//  CloudsitManager.m
//  Cloudsit
//
//  Created by Ivan Sadikov on 7/06/14.
//  Copyright (c) 2014 Ivan Sadikov. All rights reserved.
//

#import "CloudsitManager.h"

#define API_KEY                                 @"51f36cc5e948614af8195a03b0f299faca59146a"
#define API_URL                                 @"http://api.worldweatheronline.com/free/v1"

#define DefaultLocation                         @"Christchurch, New Zealand"

@interface CloudsitManager()
@property (nonatomic, strong) NSString *currentLocation;
@end

@implementation CloudsitManager

- (NSString *)location {
    return self.currentLocation;
}

- (id)initWithRequestManager:(BOOL)loadManager {
    self = [super init];
    if (self) {
        if (loadManager) {
            self.requestManager = [[RequestManager alloc] init];
            self.requestManager.delegate = self;
        }
    }
    
    return self;
}

- (void)setURLStringForRefresh:(NSString *)url {
    [self.requestManager setURLString:url andHTTPMethod:RequestManagerHTTPMethodGET];
}

- (NSString *)urlWithParameters:(NSString *)location andFormat:(NSString *)format andNumberOfDays:(int)days andKey:(NSString *)key {
    return [NSString stringWithFormat:@"%@/weather.ashx?q=%@&format=%@&extra=localObsTime&num_of_days=%d&key=%@", API_URL, location, format, days, key];
}

- (void)refreshDataForLocation:(NSString *)location {
    if (!location) {
        location = DefaultLocation;
    }
    self.currentLocation = location;
    
    if (self.requestManager) {
        NSString *url = [self urlWithParameters:location andFormat:@"json" andNumberOfDays:5 andKey:API_KEY];
        
        [self.requestManager cancelRequest];
        [self.requestManager setURLString:url andHTTPMethod:RequestManagerHTTPMethodGET];
        [self.requestManager sendRequest];
        
        [self.delegate managerDidSendRequestWithURL:self];
    }
}

- (void)setValue:(id)value forKey:(NSString *)key inDictionary:(NSDictionary *)dict {
    [dict setValue:value forKey:[NSString stringWithFormat:@"%@", key]];
}

- (NSDictionary *)weatherWithDate:(NSString *)dateString andMaxTemperature:(NSString *)maxTemp andMinTemperature:(NSString *)minTemp
andWeatherCode:(NSString *)weatherCode andWeatherDesc:(NSString *)weatherDesc {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSDateFormatter *weekFormatter = [[NSDateFormatter alloc] init];
    [weekFormatter setDateFormat:@"EEE"];
    
    NSString *weekday = [weekFormatter stringFromDate:[dateFormatter dateFromString:dateString]];
    
    return @{@"date" : [dateFormatter dateFromString:dateString], @"maxTemp" : maxTemp, @"minTemp" : minTemp, @"weatherCode" : weatherCode, @"weekday" : weekday, @"weatherDesc" : weatherDesc };
}

- (NSDictionary *)currentConditionWithDate:(NSString *)dateString andTemperature:(NSString *)temp andWeatherCode:(NSString *)weatherCode andMinTemp:(NSString *)minTemp andMaxTemp:(NSString *)maxTemp andWeatherDesc:(NSString *)weatherDesc {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm a"]; //2014-06-07 08:00 PM
        
    return @{ @"date" : [dateFormatter dateFromString:dateString], @"temp" : temp, @"weatherCode" : weatherCode , @"maxTemp" : maxTemp, @"minTemp" : minTemp, @"weatherDesc" : weatherDesc };
}

- (NSDictionary *)processResult:(id)result withError: (NSError **)error {
    if ([result isKindOfClass:[NSDictionary class]]) {
        if ([[result objectForKey:@"data"] isKindOfClass:[NSDictionary class]]) {
            NSDictionary *data = (NSDictionary *)[result objectForKey:@"data"];
            
            if ([data objectForKey:@"error"]) {
                NSArray *errorDesc = (NSArray *)[data objectForKey:@"error"];
                NSString *msg = [[errorDesc objectAtIndex:0] objectForKey:@"msg"];
                *error = [NSError errorWithDomain:@"Cloudsit" code:-10002 userInfo:@{ @"msg" : msg }];
                
                return nil;
            } else {
                NSMutableDictionary *resultData = [NSMutableDictionary dictionary];
                [self setValue:self.currentLocation forKey:CloudsitManagerDataLocationKey inDictionary:resultData];
                
                NSMutableArray *resultWeather = [NSMutableArray array];
                
                // for current min/max temperatures
                
                NSArray *weathers = (NSArray *)[data objectForKey:@"weather"];
                for (id weather in weathers) {
                    [resultWeather addObject:[self weatherWithDate:[weather objectForKey:@"date"]
                                               andMaxTemperature:[weather objectForKey:@"tempMaxC"]
                                               andMinTemperature:[weather objectForKey:@"tempMinC"]
                                                  andWeatherCode:[weather objectForKey:@"weatherCode"]
                                                    andWeatherDesc:[[[weather objectForKey:@"weatherDesc"] objectAtIndex:0] objectForKey:@"value"]
                    ]];
                }
                
                [self setValue:resultWeather forKey:CloudsitManagerDataWeatherKey inDictionary:resultData];
                
                NSArray *currentCondition = (NSArray *)[data objectForKey:@"current_condition"];
                NSString *currentTemperature = [[currentCondition objectAtIndex:0] objectForKey:@"temp_C"];
                NSString *currentMinTemp = [[weathers objectAtIndex:0] objectForKey:@"tempMinC"];
                NSString *currentMaxTemp = [[weathers objectAtIndex:0] objectForKey:@"tempMaxC"];
                NSDictionary *currentWeatherCondition = [[[currentCondition objectAtIndex:0] objectForKey:@"weatherDesc"] objectAtIndex:0];
                NSString *currentWeatherDesc = [currentWeatherCondition objectForKey:@"value"];
                
                [self setValue:[self currentConditionWithDate:[[currentCondition objectAtIndex:0] objectForKey:@"localObsDateTime"]
                                               andTemperature:currentTemperature
                                               andWeatherCode:[[currentCondition objectAtIndex:0] objectForKey:@"weatherCode"]
                                                   andMinTemp:currentMinTemp
                                                   andMaxTemp:currentMaxTemp
                                               andWeatherDesc:currentWeatherDesc]
                        forKey:CloudsitManagerDataCurrentConditionKey
                  inDictionary:resultData];
                
                return resultData;
            }
        } else if ([[result objectForKey:@"results"] isKindOfClass:[NSDictionary class]]) {
            NSDictionary *results = (NSDictionary *)[result objectForKey:@"results"];
            if ([[results objectForKey:@"error"] isKindOfClass:[NSDictionary class]]) {
                NSString *msg = (NSString *)[[results objectForKey:@"error"] objectForKey:@"message"];
                *error = [NSError errorWithDomain:@"Cloudsit" code:-10003 userInfo:@{ @"msg" : msg }];
            }
            
            return nil;
        } else {
            *error = [NSError errorWithDomain:@"Cloudsit" code:-10004 userInfo:@{ @"msg" : @"Unexpected error. Please, try it later" }];
            return nil;
        }
    } else {
        *error = [NSError errorWithDomain:@"Cloudsit" code:-10001 userInfo:@{ @"msg" : @"Result does not match appropriate format" }];
        return nil;
    }
}

#pragma mark - RequestManagerDelegate methods

- (void)requestManager:(RequestManager *)manager startProceedingRequest:(NSURLRequest *)request {
    //NSLog(@"Request is starting");
}

- (void)requestManager:(RequestManager *)manager didReceiveResponse:(NSURLResponse *)response {
    //NSLog(@"Response is received");
}

- (void)requestManager:(RequestManager *)manager didLoadResult:(id)result {
    NSError *error;
    NSDictionary *resultData = [self processResult:result withError:&error];
    //NSLog(@"Result: %@", result);
    NSLog(@"Result data: %@", resultData);
    
    if (error) {
        [self.delegate manager:self didFailWithError:error];
    } else {
        [self.delegate manager:self didReceiveResult:resultData];
    }
}

- (void)requestManager:(RequestManager *)manager didFailWithError:(NSError *)error {
    [self.delegate manager:self didFailWithError:error];
}

@end
