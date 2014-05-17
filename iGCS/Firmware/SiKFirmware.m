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

// ref: http://stackoverflow.com/questions/2501033/nsstring-hex-to-bytes
+ (NSData*)hexStrToNSData:(NSString*)s {
    const char *chars = [s UTF8String];
    int i = 0, len = s.length;
    
    assert(len % 2 == 0);
    
    NSMutableData *data = [NSMutableData dataWithCapacity:len / 2];
    char byteChars[3] = {'\0','\0','\0'};
    unsigned long wholeByte;
    
    while (i < len) {
        byteChars[0] = chars[i++];
        byteChars[1] = chars[i++];
        wholeByte = strtoul(byteChars, NULL, 16);
        [data appendBytes:&wholeByte length:1];
    }
    
    return data;
}

+ (AddressDataPair*) parseLine:(NSString*)s {
    // ignore lines not beginning with :
    if ([s characterAtIndex:0] != ':') {
        return nil;
    }
    
    // parse the header off the line
    NSString *hexStr = [s substringWithRange: NSMakeRange(1, s.length - 3)]; // Remove first char, and last 2
    NSData *data = [SiKFirmware hexStrToNSData:hexStr];
    NSUInteger n = data.length;
    assert(n >= 3);
    unsigned char* bytes = ((unsigned char*)data.bytes);
    unsigned char command = bytes[2];
    
    // only type 0 records are interesting
    if (command != 0) {
        return nil;
    }
    NSUInteger address = (((NSUInteger)bytes[0]) << 8) + bytes[1];
    return [[AddressDataPair alloc] initWithAddress:address
                                            andData:[data subdataWithRange:NSMakeRange(3, n - 3)]];
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

