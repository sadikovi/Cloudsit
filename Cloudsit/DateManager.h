//
//  DateManager.h
//  Cloudsit
//
//  Created by Ivan Sadikov on 15/06/14.
//  Copyright (c) 2014 Ivan Sadikov. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 * DateManager is a default manager to deal with dates and provide necessary methods.
 * It has default dateFormatter with timezone as GMT.
 *
 */
@interface DateManager : NSObject

/**
 * Default manager as a singleton.
 *
 */
+ (DateManager *)defaultManager;

/**
 * Returns YES when datetime is between 6 AM and 6 PM. Otherwise, it assumes that it is night time.
 *
 */
- (BOOL)isDayTime:(NSDate *)date;

/**
 * Returns short week day name for the date (e.g. Mon, Thu, Fri).
 *
 */
- (NSString *)shortWeekdayFromDate:(NSDate *)date;

/**
 * Long week day name for the date (e.g. Monday, Thursday, Friday).
 *
 */
- (NSString *)longWeekdayFromDate:(NSDate *)date;

/**
 * Returns NSDate instance converted from date string using mask (e.g. yyyy-MM-dd HH:mm:ss).
 *
 */
- (NSDate *)dateFromString:(NSString *)dateString usingMask:(NSString *)mask;

/**
 * Returns string representing date using mask (e.g. yyyy-MM-dd HH:mm:ss).
 *
 */
- (NSString *)stringFromDate:(NSDate *)date usingMask:(NSString *)mask;

@end
