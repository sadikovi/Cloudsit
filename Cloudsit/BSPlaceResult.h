//
//  BSPlaceResult.h
//  Cloudsit
//
//  Created by Ivan Sadikov on 13/06/14.
//  Copyright (c) 2014 Ivan Sadikov. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * BSPlaceResult is a class for BSPlaceManager to store data from PlaceAutocomplete.
 * Used to store data of the cities [mostly] and geocode objects.
 *
 */
@interface BSPlaceResult : NSObject

// description of the place (full)
@property (nonatomic, strong) NSString *description;
// place id
@property (nonatomic, strong) NSString *placeid;
// types of the object (for cities it is going to be goecode and locations)
@property (nonatomic, strong) NSArray *types;
// place name
@property (nonatomic, strong) NSString *name;
// place location
@property (nonatomic, strong) NSString *location;
// search string for weather
@property (nonatomic, strong) NSString *searchLocation;

/**
 * Init methdos.
 *
 */
- (id)initWithDescription:(NSString *)desc andPlaceId:(NSString *)pId andTypes:(NSArray *)pTypes;
- (id)initWithDescription:(NSString *)desc andPlaceId:(NSString *)pId andTypes:(NSArray *)pTypes andPlaceName:(NSString *)name andPlaceLocation:(NSString *)location;
- (id)initWithDescription:(NSString *)desc andPlaceId:(NSString *)pId andTypes:(NSArray *)pTypes andPlaceName:(NSString *)name andPlaceLocation:(NSString *)location andSearchLocation:(NSString *)searchLocation;

/**
 * Class methods for creating object BSPlaceResult.
 *
 */
+ (BSPlaceResult *)placeResultWithDescription:(NSString *)desc andPlaceId:(NSString *)pId andTypes:(NSArray *)pTypes;
+ (BSPlaceResult *)placeResultWithDescription:(NSString *)desc andPlaceId:(NSString *)pId andTypes:(NSArray *)pTypes andPlaceName:(NSString *)name andPlaceLocation:(NSString *)location;
+ (BSPlaceResult *)placeResultWithDescription:(NSString *)desc andPlaceId:(NSString *)pId andTypes:(NSArray *)pTypes andPlaceName:(NSString *)name andPlaceLocation:(NSString *)location andSearchLocation:(NSString *)searchLocation;

@end
