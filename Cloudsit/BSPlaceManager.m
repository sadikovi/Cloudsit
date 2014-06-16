//
//  BSPlaceManager.m
//  Cloudsit
//
//  Created by Ivan Sadikov on 13/06/14.
//  Copyright (c) 2014 Ivan Sadikov. All rights reserved.
//

#import "BSPlaceManager.h"

#define GET_METHOD @"GET"
#define URL @"https://maps.googleapis.com/maps/api/place/autocomplete"
#define API_KEY @"AIzaSyCkziRBB3NXF7DvQwEIoGMyqwCFpDAqGaw"


static const NSTimeInterval kTimeOutInterval = 180.0;
static const NSString *kLegalCharactersToBeEscaped = @"?!@#$^&%*+=,:;'\"`<>()[]{}/\\|~";

static const NSString *STATUS_OK = @"OK";

#define STATUS          @"status"
#define PREDICTIONS     @"predictions"
#define DESCRIPTION     @"description"
#define TERMS           @"terms"
#define VALUE           @"value"
#define OFFSET          @"offset"
#define ID              @"id"
#define TYPES           @"types"
#define ERROR_MESSAGE   @"error_message"

@interface BSPlaceManager()
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, strong) NSString *searchPlace;
@property (nonatomic, strong) NSURLConnection *connection;
@end

@implementation BSPlaceManager

/**
 * Encode url for sending to Google.
 *
 */
- (NSString *)URLEncodedString:(NSString *)string {
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)string, NULL, (CFStringRef)kLegalCharactersToBeEscaped, kCFStringEncodingUTF8));
}

/**
 * Standard method for parsing JSON using SBJSON.
 * Do not check error here, we just return raw response if something happens.
 *
 */
- (id)parseJsonResponse:(NSData *)data withError:(NSError *)responseError {
    NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    SBJSON *jsonParser = [[SBJSON alloc] init];
    id result = [jsonParser objectWithString:response error:&responseError];
    
    if (result == nil) {
        return response;
    }
    
    return result;
}

#pragma mark - Public Methods

- (void)searchPlace:(NSString *)place {
    self.searchPlace = [self URLEncodedString:place];
}

- (BOOL)connectionIsActive {
    if (self.connection) {
        return YES;
    } else {
        return NO;
    }
}

- (void)startRequest {
    // initialize our response data
    self.responseData = [NSMutableData data];
    
    // create request
    NSString *requestUrl = [NSString stringWithFormat:@"%@/json?input=%@&sensor=false&key=%@&types=(cities)", URL, self.searchPlace, API_KEY];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestUrl]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:kTimeOutInterval];
    [request setHTTPMethod:GET_METHOD];
    
    // always stop conncetion, if it is active.
    if ([self connectionIsActive]) {
        [self stopRequest];
    }
    
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [self.connection start];
    
    [self.delegate placeManager:self processingRequest:request];
}

- (void)stopRequest {
    if ([self connectionIsActive]) {
        [self.connection cancel];
        self.connection = nil;
    }
}


#pragma mark - NSURLConnectionDelegate Methods

- (void)connection:(NSURLConnection *)conn didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)conn willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)conn {
    id result = [self parseJsonResponse:self.responseData withError:nil];
    
    NSMutableArray *placeResults = [NSMutableArray array];
    
    // start parsing the results
    if ([result isKindOfClass:[NSDictionary class]]) {
        if ([STATUS_OK isEqual:[result objectForKey:STATUS]]) {
            NSArray *places = (NSArray *)[result objectForKey:PREDICTIONS];
            for (id place in places) {
                if ([place isKindOfClass:[NSDictionary class]]) {
                    // first, we are trying to get name and location from response data
                    NSString *name = nil;
                    NSString *location = @"";
                    NSString *searchLocation = @"";
                    NSArray *terms = (NSArray *)[place objectForKey:TERMS];
                    // if terms count > 1, it means we can get name and location separately, or at least name
                    if ([terms count] > 1) {
                        // get the first object from terms array
                        name = [NSString stringWithFormat:@"%@", [[terms objectAtIndex:0] objectForKey:VALUE]];
                        
                        // for the rest of the objects perform simple search and concatenation
                        for (int i=1; i<[terms count]; i++) {
                            NSString *partOfLocation = [[terms objectAtIndex:i] objectForKey:VALUE];
                            location = [location stringByAppendingString:partOfLocation];
                            if (i != [terms count]-1) {
                                location = [location stringByAppendingString:@", "];
                            } else {
                                searchLocation = [name stringByAppendingString:[NSString stringWithFormat:@", %@", partOfLocation]];
                            }
                        }
                    }
                    // full description
                    NSString *desc = [NSString stringWithFormat:@"%@", [place objectForKey:DESCRIPTION]];
                    // place id
                    NSString *pId = [NSString stringWithFormat:@"%@", [place objectForKey:ID]];
                    // place types
                    NSArray *types = (NSArray *)[place objectForKey:TYPES];
                    
                    BSPlaceResult *result = [BSPlaceResult placeResultWithDescription:desc andPlaceId:pId andTypes:types andPlaceName:name andPlaceLocation:location andSearchLocation:searchLocation];
                    [placeResults addObject:result];
                }
            }
            
            [self.delegate placeManager:self didReceiveResult:placeResults];
        } else {
            // something is wrong
            // raise error
            NSError *error = [NSError errorWithDomain:@"BSPlaceManagerError"
                                                 code:BSPlaceManagerResponseStatusError
                                             userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                       [result objectForKey:STATUS], STATUS,
                                                       [result objectForKey:ERROR_MESSAGE], ERROR_MESSAGE, nil]];
            
            [self.delegate placeManager:self didFailWithError:error];
        }
    } else {
        // if response result is not NSDictionary
        // raise error
        NSError *error = [NSError errorWithDomain:@"BSPlaceManagerError"
                                             code:BSPlaceManagerResponseStatusError
                                         userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                   @"RESPONSE_RESULT_ERROR", STATUS,
                                                   @"Response object is not NSDictionary instance", ERROR_MESSAGE, nil]];
        
        [self.delegate placeManager:self didFailWithError:error];
    }
    
    // release connection
    [conn cancel];
    conn = nil;
}

- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error {
    [self.delegate placeManager:self didFailWithError:error];
    
    // release connection
    [conn cancel];
    conn = nil;
}

@end