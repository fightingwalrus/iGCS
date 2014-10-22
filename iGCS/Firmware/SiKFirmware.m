//
//  SiKFirmware.m
//  iGCS
//
//  Objective-C re-mplementation of the SiK Firmware uploader.py https://github.com/tridge/SiK/blob/master/Firmware/tools/uploader.py
//
//  Created by Claudio Natoli on 17/05/2014.
//
//

#import "SiKFirmware.h"

@implementation AddressDataPair : NSObject
- (instancetype) initWithAddress: (NSUInteger)address andData:(NSData*)data {
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

- (instancetype) initWithDict:(NSDictionary*)dict {
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
    if ([s length] == 0 || [s characterAtIndex:0] != ':') {
        return nil;
    }
    
    // parse the header off the line
    NSString *hexStr = [s substringWithRange: NSMakeRange(1, s.length - 3)]; // Remove first char, and last 2
    NSData *data = [SiKFirmware hexStrToNSData:hexStr];
    NSUInteger n = data.length;
    assert(n >= 4);
    unsigned char* bytes = ((unsigned char*)data.bytes);
    unsigned char command = bytes[3];
    
    // only type 0 records are interesting
    if (command != 0) {
        return nil;
    }
    NSUInteger address = (((NSUInteger)bytes[1]) << 8) + bytes[2];
    return [[AddressDataPair alloc] initWithAddress:address
                                            andData:[data subdataWithRange:NSMakeRange(4, n - 4)]];
}

// insert the pair into the dictionary, merging as we go
+ (NSMutableDictionary*) insertAddressDataPair:(AddressDataPair*)adp into:(NSMutableDictionary*)dict {
    
    // look for a pair that immediately follows this one
    NSNumber *nextAddress = @([adp nextAddress]);
    AddressDataPair *nextPair = dict[nextAddress];
    if (nextPair != nil) {
        // found one, remove from dict and merge to the end of adp
        [dict removeObjectForKey:nextAddress];
        adp = [adp extend:nextPair];
    }
    
    // iterate the existing pairs, looking for one that precedes adp
    for (NSNumber *key in [dict allKeys]) {
        AddressDataPair *prevPair = dict[key];
        if ([prevPair nextAddress] == adp.address) {
            // found one, so merge adp to the end of it
            prevPair = [prevPair extend:adp];
            dict[key] = prevPair;
            return dict;
        }
    }
    
    // otherwise, just insert it, keyed on address
    dict[@(adp.address)] = adp;
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

