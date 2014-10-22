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

- (instancetype) initWithAddress: (NSUInteger)address andData:(NSData*)data NS_DESIGNATED_INITIALIZER;
- (AddressDataPair*) extend:(AddressDataPair*)adp;
- (NSComparisonResult)compare:(AddressDataPair*)object;
@end

@interface SiKFirmware : NSObject

@property (nonatomic, readonly) NSArray* sortedAddressDataPairs;

- (instancetype) initWithDict:(NSDictionary*)dict NS_DESIGNATED_INITIALIZER; // Dictionary with AddressDataPair values - only exposed for testing purposes

+ (SiKFirmware*) firmwareFromString:(NSString*)s;

@end
