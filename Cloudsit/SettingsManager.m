//
//  SettingsManager.m
//  Cloudsit
//
//  Created by Ivan Sadikov on 13/06/14.
//  Copyright (c) 2014 Ivan Sadikov. All rights reserved.
//

#import "SettingsManager.h"

@interface SettingsManager()
@property (nonatomic) BOOL fahrenheit;
@end

@implementation SettingsManager


+ (SettingsManager *)defaultManager {
    static SettingsManager *sharedObject = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedObject = [self new];
    });
    
    return sharedObject;
}

- (BOOL)isFahrenheit {
    return self.fahrenheit;
}

- (void)setFahrenheitDegrees:(BOOL)set {
    self.fahrenheit = set;
}

- (NSDictionary *)activeLocation {
    for (NSDictionary *location in self.locations) {
        if ([location objectForKey:LOCATIONS_ACTIVE_KEY]) {
            return location;
        }
    }
    
    return nil;
}

- (void)loadPropertiesFromDefaults {
    // load locations
    self.locations = (NSArray *)[[NSUserDefaults standardUserDefaults] objectForKey:SETTINGS_LOCATIONS_KEY];
    
    // load isFahrenheit property
    if ([[NSUserDefaults standardUserDefaults] objectForKey:SETTINGS_IS_FAHRENHEIT_KEY]) {
        self.fahrenheit = YES;
    } else {
        self.fahrenheit = NO;
    }
    
    // load last weather data
    self.weatherData = [(NSDictionary *)[NSUserDefaults standardUserDefaults] objectForKey:SETTINGS_WEATHER_DATA_KEY];
    // load last update time
    self.lastUpdate = (NSDate *)[[NSUserDefaults standardUserDefaults] objectForKey:SETTINGS_LAST_UPDATE_KEY];
}

- (void)storePropertiesToDefaults {
    [[NSUserDefaults standardUserDefaults] setObject:self.locations forKey:SETTINGS_LOCATIONS_KEY];
    if (self.fahrenheit) {
        [[NSUserDefaults standardUserDefaults] setBool:self.fahrenheit forKey:SETTINGS_IS_FAHRENHEIT_KEY];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:SETTINGS_IS_FAHRENHEIT_KEY];
    }
    [[NSUserDefaults standardUserDefaults] setObject:self.weatherData forKey:SETTINGS_WEATHER_DATA_KEY];
    [[NSUserDefaults standardUserDefaults] setObject:self.lastUpdate forKey:SETTINGS_LAST_UPDATE_KEY];
}

- (id)init {
    self = [super init];
    if (self) {
        [self loadPropertiesFromDefaults];
    }
    
    return self;
}

#pragma mark - Location

+ (NSDictionary *)locationWithName:(NSString *)name andLocation:(NSString *)location andDesc:(NSString *)desc andSearch:(NSString *)searchLocation withActive:(BOOL) isActive {
    NSMutableDictionary *place = [NSDictionary dictionaryWithObjectsAndKeys:
                                name, LOCATIONS_NAME_KEY,
                                location, LOCATIONS_LOCATION_KEY,
                                desc, LOCATIONS_DESCRIPTION_KEY,
                                searchLocation, LOCATIONS_SEARCH_LOC_KEY,
                                nil];
    if (isActive) {
        [place setObject:@"YES" forKey:LOCATIONS_ACTIVE_KEY];
    }
    
    return place;
}

+ (void)location:(NSMutableDictionary *)location setActive:(BOOL)isActive {
    if (isActive) {
        [location setObject:@"YES" forKey:LOCATIONS_ACTIVE_KEY];
    }
}

+ (void)setLocationIsNotActive:(NSMutableDictionary *)location {
    [location removeObjectForKey:LOCATIONS_ACTIVE_KEY];
}

+ (BOOL)isLocationActive:(NSDictionary *)location {
    return (![location objectForKey:LOCATIONS_ACTIVE_KEY])? NO : YES;
}

#pragma mark - Fonts

- (UIFont *)systemFont {
    return [UIFont fontWithName:SETTINGS_FONT_SYSTEM_NAME size:SETTINGS_FONT_SYSTEM_SIZE];
}

- (UIFont *)systemFontDetail {
    return [UIFont fontWithName:SETTINGS_FONT_SYSTEM_DET_NAME size:SETTINGS_FONT_SYSTEM_DET_SIZE];
}

#pragma mark - UIImage

- (UIImage *)imageMask:(UIImage *)mask withColor:(UIColor *)color {
    CGImageRef maskImage = mask.CGImage;
    CGFloat width = mask.size.width;
    CGFloat height = mask.size.height;
    CGRect bounds = CGRectMake(0, 0, width, height);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef bitmapContext = CGBitmapContextCreate(NULL, width, height, 8, 0, colorSpace, kCGImageAlphaPremultipliedLast);
    CGContextClipToMask(bitmapContext, bounds, maskImage);
    CGContextSetFillColorWithColor(bitmapContext, color.CGColor);
    CGContextFillRect(bitmapContext, bounds);
    
    CGImageRef cImage = CGBitmapContextCreateImage(bitmapContext);
    UIImage *coloredImage = [UIImage imageWithCGImage:cImage];
    
    CGContextRelease(bitmapContext);
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(cImage);
    
    return coloredImage;
}

@end
