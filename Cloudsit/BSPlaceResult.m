//
//  BSPlaceResult.m
//  Cloudsit
//
//  Created by Ivan Sadikov on 13/06/14.
//  Copyright (c) 2014 Ivan Sadikov. All rights reserved.
//

#import "BSPlaceResult.h"

@implementation BSPlaceResult

- (id)initWithDescription:(NSString *)desc andPlaceId:(NSString *)pId andTypes:(NSArray *)pTypes {
    self = [super init];
    if (self) {
        self.description = desc;
        self.placeid = pId;
        self.types = pTypes;
        self.name = desc;
        self.location = nil;
        self.searchLocation = desc;
    }
    
    return self;
}

- (id)initWithDescription:(NSString *)desc andPlaceId:(NSString *)pId andTypes:(NSArray *)pTypes andPlaceName:(NSString *)name andPlaceLocation:(NSString *)location {
    self = [super init];
    if (self) {
        self.description = desc;
        self.placeid = pId;
        self.types = pTypes;
        
        if (name) {
            self.name = name;
            self.location = location;
        } else {
            self.name = desc;
            self.location = nil;
            self.searchLocation = desc;
        }
    }
    
    return self;
}

- (id)initWithDescription:(NSString *)desc andPlaceId:(NSString *)pId andTypes:(NSArray *)pTypes andPlaceName:(NSString *)name andPlaceLocation:(NSString *)location andSearchLocation:(NSString *)searchLocation {
    self = [super init];
    if (self) {
        self.description = desc;
        self.placeid = pId;
        self.types = pTypes;
        
        if (name) {
            self.name = name;
            self.location = location;
            self.searchLocation = searchLocation;
        } else {
            self.name = desc;
            self.location = nil;
            self.searchLocation = desc;
        }
    }
    
    return self;
}

+ (BSPlaceResult *)placeResultWithDescription:(NSString *)desc andPlaceId:(NSString *)pId andTypes:(NSArray *)pTypes {
    BSPlaceResult *place = [[BSPlaceResult alloc] initWithDescription:desc andPlaceId:pId andTypes:pTypes];
    
    return place;
}


+ (BSPlaceResult *)placeResultWithDescription:(NSString *)desc andPlaceId:(NSString *)pId andTypes:(NSArray *)pTypes andPlaceName:(NSString *)name andPlaceLocation:(NSString *)location {
    BSPlaceResult *place = [[BSPlaceResult alloc] initWithDescription:desc andPlaceId:pId andTypes:pTypes andPlaceName:name andPlaceLocation:location];
    
    return place;
}

+ (BSPlaceResult *)placeResultWithDescription:(NSString *)desc andPlaceId:(NSString *)pId andTypes:(NSArray *)pTypes andPlaceName:(NSString *)name andPlaceLocation:(NSString *)location andSearchLocation:(NSString *)searchLocation {
    BSPlaceResult *place = [[BSPlaceResult alloc] initWithDescription:desc andPlaceId:pId andTypes:pTypes andPlaceName:name andPlaceLocation:location andSearchLocation:searchLocation];
    
    return place;
}


@end
