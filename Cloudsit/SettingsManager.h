//
//  SettingsManager.h
//  Cloudsit
//
//  Created by Ivan Sadikov on 13/06/14.
//  Copyright (c) 2014 Ivan Sadikov. All rights reserved.
//

#import <Foundation/Foundation.h>

// Settings keys
#define SETTINGS_LOCATIONS_KEY      @"cloudsit_locations_preference"
    #define LOCATIONS_NAME_KEY          @"cloudsit_locations_name_key"
    #define LOCATIONS_LOCATION_KEY      @"cloudsit_locations_location_key"
    #define LOCATIONS_DESCRIPTION_KEY   @"cloudsit_locations_description_key"
    #define LOCATIONS_ACTIVE_KEY        @"cloudsit_locations_active_key"
    #define LOCATIONS_SEARCH_LOC_KEY    @"cloudsit_locations_search_location_key"

#define SETTINGS_IS_FAHRENHEIT_KEY  @"cloudsit_fahrenheit_preference"
    #define IS_FAHRENHEIT_ACT           @"1"
    #define IS_FAHRENHEIT_NOA           @"0"

#define SETTINGS_LAST_UPDATE_KEY    @"cloudsit_last_update_preference"
#define SETTINGS_WEATHER_DATA_KEY   @"cloudsit_weather_data_preference"


// Fonts
#define SETTINGS_FONT_SYSTEM_NAME       @"HelveticaNeue-Light"
#define SETTINGS_FONT_SYSTEM_SIZE       17
#define SETTINGS_FONT_SYSTEM_DET_NAME   @"HelveticaNeue-Light"
#define SETTINGS_FONT_SYSTEM_DET_SIZE   13

@interface SettingsManager : NSObject

@property (nonatomic, strong) NSArray *locations;
@property (nonatomic, readonly, strong) NSDictionary *activeLocation;
@property (nonatomic, readonly) BOOL isFahrenheit;
@property (nonatomic, strong) NSDate *lastUpdate;
@property (nonatomic, strong) NSDictionary *weatherData;

// singleton for Settings manager
+ (SettingsManager *)defaultManager;

// store properties to NSUserDefaults
- (void)storePropertiesToDefaults;

// load properties from NSUserDefaults
- (void)loadPropertiesFromDefaults;

// set Fahrenheit temperature scale
- (void)setFahrenheitDegrees:(BOOL)set;

// returns dictionary representing location in settings
+ (NSDictionary *)locationWithName:(NSString *)name andLocation:(NSString *)location andDesc:(NSString *)desc andSearch:(NSString *)searchLocation withActive:(BOOL) isActive;
// method to set location active
+ (void)location:(NSMutableDictionary *)location setActive:(BOOL)isActive;
// set location is not active
+ (void)setLocationIsNotActive:(NSMutableDictionary *)location;

// method to determine whether location is active or not
+ (BOOL)isLocationActive:(NSDictionary *)location;

// Font methods
- (UIFont *)systemFont;
- (UIFont *)systemFontDetail;

// image methods
- (UIImage *)imageMask:(UIImage *)mask withColor:(UIColor *)color;

@end
