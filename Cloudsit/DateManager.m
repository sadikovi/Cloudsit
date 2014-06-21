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

// singleton for DateManager
+ (DateManager *)defaultManager {
    static DateManager *sharedObject = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedObject = [self new];
    });
    
    return sharedObject;
}

// init method for manager, date formatter is instanciated here
- (id)init {
    self = [super init];
    if (self) {
        self.defaultFormatter = [[NSDateFormatter alloc] init];
        // set default formatter as a GMT formatter not to set date
        [self.defaultFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    }
    
    return self;
}

// set method for default formatter
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
    [self.defaultFormatter setDateFormat:@"HH"];
    NSString *hourString = [self.defaultFormatter stringFromDate:date];
    NSInteger hour = [hourString intValue];
    
    // hour constansts, so day time is between 6 AM and 6 PM
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
