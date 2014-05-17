//
//  SiKFirmware.h
//  iGCS
//
//  Created by Claudio Natoli on 17/05/2014.
//
//

#import <Foundation/Foundation.h>

@interface AddressDataPair : NSObject
@property (nonatomic, readonly) NSUInteger address;
@property (nonatomic, readonly) NSData *data;

- (id) initWithAddress: (NSUInteger)address andData:(NSData*)data;
- (AddressDataPair*) extend:(AddressDataPair*)adp;
- (NSComparisonResult)compare:(AddressDataPair*)object;
@end

@interface SiKFirmware : NSObject

@property (nonatomic, readonly) NSArray* sortedAddressDataPairs;

- (id) initWithDict:(NSDictionary*)dict; // Dictionary with AddressDataPair values - only exposed for testing purposes

+ (SiKFirmware*) firmwareFromString:(NSString*)s;

@end
