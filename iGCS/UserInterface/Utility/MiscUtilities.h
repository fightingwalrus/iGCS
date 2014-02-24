//
//  MiscUtilities.h
//  iGCS
//
//  Created by Claudio Natoli on 21/07/13.
//
//

#import <Foundation/Foundation.h>

@interface MiscUtilities : NSObject

typedef NS_ENUM(int8_t, GCSGeoCoord) {
    GCSLatitude,
    GCSLongitude
};

+ (float) getTextWidth:(NSString*)label withContext:(CGContextRef)ctx;
+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize rotation:(double)ang;
+ (UIImage *)image:(UIImage*)img withColor:(UIColor*)color;
+ (UIImage *)imageWithColor:(UIColor*)color;

+ (NSString*)prettyPrintCoordAxis:(float)val as:(GCSGeoCoord)eLatLong;
+ (NSString *)UUIDUsingDefaultAllocator;

@end
