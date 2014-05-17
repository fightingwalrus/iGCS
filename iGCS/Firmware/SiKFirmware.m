//
//  SiKFirmware.m
//  iGCS
//
//  Created by Claudio Natoli on 17/05/2014.
//
//

#import "SiKFirmware.h"

@implementation AddressDataPair : NSObject
- (id) initWithAddress: (NSUInteger)address andData:(NSData*)data {
    self = [super init];
    if (self) {
        _address = address;
        _data    = data;
    }
    return self;
}

// Create a new AddressDataPair, extending this.data with adp.data
- (AddressDataPair*) extend:(AddressDataPair*)adp {
    NSMutableData *newData = [NSMutableData dataWithCapacity:_data.length + adp.data.length];
    [newData appendData:_data];
    [newData appendData:adp.data];
    return [[AddressDataPair alloc] initWithAddress:_address andData:newData];
}

- (NSComparisonResult)compare:(AddressDataPair*)object {
    return (_address == object.address ? NSOrderedSame : (_address < object.address ? NSOrderedAscending : NSOrderedDescending));
}

- (NSUInteger) nextAddress {
    return _address + _data.length;
}

@end


@implementation SiKFirmware


- (id) initWithDict:(NSDictionary*)dict {
    self = [super init];
    if (self) {
        _sortedAddressDataPairs = [[dict allValues] sortedArrayUsingSelector: @selector(compare:)];
    }
    return self;
}

+ (AddressDataPair*) parseLine:(NSString*)s {
    // FIXME: implement me
    return [[AddressDataPair alloc] initWithAddress:0 andData:nil];
}

// insert the pair into the dictionary, merging as we go
+ (NSMutableDictionary*) insertAddressDataPair:(AddressDataPair*)adp into:(NSMutableDictionary*)dict {
    
    // look for a pair that immediately follows this one
    NSNumber *nextAddress = [NSNumber numberWithUnsignedInteger:[adp nextAddress]];
    AddressDataPair *nextPair = [dict objectForKey:nextAddress];
    if (nextPair != nil) {
        // found one, remove from dict and merge to the end of adp
        [dict removeObjectForKey:nextAddress];
        adp = [adp extend:nextPair];
    }
    
    // iterate the existing pairs, looking for one that precedes adp
    for (NSNumber *key in [dict allKeys]) {
        AddressDataPair *prevPair = [dict objectForKey:key];
        if ([prevPair nextAddress] == adp.address) {
            // found one, so merge adp to the end of it
            prevPair = [prevPair extend:adp];
            [dict setObject:prevPair forKey:key];
            return dict;
        }
    }
    
    // otherwise, just insert it, keyed on address
    [dict setObject:adp forKey:[NSNumber numberWithUnsignedInteger:adp.address]];
    return dict;
}

+ (SiKFirmware*) firmwareFromString:(NSString*)s {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    // My kingdom for map, filter and reduce...
    NSArray* lines = [s componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    for (NSString *line in lines) {
        AddressDataPair *ad = [SiKFirmware parseLine:line];
        if (ad != nil) {
            dict = [SiKFirmware insertAddressDataPair:ad into:dict];
        }
    }

    return [[SiKFirmware alloc] initWithDict:dict];
}

@end

