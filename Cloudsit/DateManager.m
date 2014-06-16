//
//  DateManager.m
//  Cloudsit
//
//  Created by Ivan Sadikov on 15/06/14.
//  Copyright (c) 2014 Ivan Sadikov. All rights reserved.
//

#import "DateManager.h"

@interface DateManager()
@property (nonatomic, strong) NSDateFormatter *defaultFormatter;
@end

@implementation DateManager

+ (DateManager *)defaultManager {
    static DateManager *sharedObject = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedObject = [self new];
    });
    
    return sharedObject;
}

- (id)init {
    self = [super init];
    if (self) {
        self.defaultFormatter = [[NSDateFormatter alloc] init];
        // set default formatter as a GMT formatter not to set date
        [self.defaultFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    }
    
    return self;
}

- (NSDateFormatter *)defaultFormatter {
    if (!_defaultFormatter) {
        _defaultFormatter = [[NSDateFormatter alloc] init];
    }
    
    return _defaultFormatter;
}

- (BOOL)isShortTimeInDate:(NSString *)dateString {
    NSString *am = @"AM";
    NSString *pm = @"PM";
    
    if ([[dateString uppercaseString] rangeOfString:am].location != NSNotFound) {
        return YES;
    }
    
    if ([[dateString uppercaseString] rangeOfString:pm].location != NSNotFound) {
        return YES;
    }
    
    return NO;
}

- (NSDate *)dateFromString:(NSString *)dateString usingMask:(NSString *)mask {
    [self.defaultFormatter setDateFormat:mask];
    NSDate *date = [self.defaultFormatter dateFromString:dateString];
    
    return date;
}

- (NSString *)stringFromDate:(NSDate *)date usingMask:(NSString *)mask {
    [self.defaultFormatter setDateFormat:mask];
    return [self.defaultFormatter stringFromDate:date];
}

- (BOOL)isDayTime:(NSDate *)date {
    NSUInteger unitFlags = NSDayCalendarUnit | NSMonthCalendarUnit |NSYearCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *components = [[NSCalendar currentCalendar] components:unitFlags fromDate:date];
    
    NSInteger hour = [components hour];
    
    if (hour > 5 && hour < 18) {
        return YES;
    } else {
        return NO;
    }
}

- (NSString *)shortWeekdayFromDate:(NSDate *)date {
    NSDateFormatter *weekFormatter = [[NSDateFormatter alloc] init];
    [weekFormatter setDateFormat:@"EEE"];
    
    return [weekFormatter stringFromDate:date];
}

- (NSString *)longWeekdayFromDate:(NSDate *)date {
    NSDateFormatter *weekFormatter = [[NSDateFormatter alloc] init];
    [weekFormatter setDateFormat:@"EEEE"];
    
    return [weekFormatter stringFromDate:date];
}

@end
