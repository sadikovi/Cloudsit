//
//  DateManager.h
//  Cloudsit
//
//  Created by Ivan Sadikov on 15/06/14.
//  Copyright (c) 2014 Ivan Sadikov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateManager : NSObject

+ (DateManager *)defaultManager;

- (BOOL)isDayTime:(NSDate *)date;
- (NSString *)shortWeekdayFromDate:(NSDate *)date;
- (NSString *)longWeekdayFromDate:(NSDate *)date;
- (NSDate *)dateFromString:(NSString *)dateString usingMask:(NSString *)mask;
- (NSString *)stringFromDate:(NSDate *)date usingMask:(NSString *)mask;

@end
