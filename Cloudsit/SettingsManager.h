//
//  SettingsManager.h
//  Cloudsit
//
//  Created by Ivan Sadikov on 13/06/14.
//  Copyright (c) 2014 Ivan Sadikov. All rights reserved.
//

#import <Foundation/Foundation.h>


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

+ (SettingsManager *)defaultManager;
- (void)storePropertiesToDefaults;
- (void)loadPropertiesFromDefaults;
- (void)setFahrenheitDegrees:(BOOL)set;

+ (NSDictionary *)locationWithName:(NSString *)name andLocation:(NSString *)location andDesc:(NSString *)desc andSearch:(NSString *)searchLocation withActive:(BOOL) isActive;
+ (void)location:(NSMutableDictionary *)location setActive:(BOOL)isActive;
+ (void)setLocationIsNotActive:(NSMutableDictionary *)location;
+ (BOOL)isLocationActive:(NSDictionary *)location;

- (UIFont *)systemFont;
- (UIFont *)systemFontDetail;

@end
