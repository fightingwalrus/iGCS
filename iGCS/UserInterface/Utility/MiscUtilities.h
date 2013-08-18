//
//  MiscUtilities.h
//  iGCS
//
//  Created by Claudio Natoli on 21/07/13.
//
//

#import <Foundation/Foundation.h>

@interface MiscUtilities : NSObject

+ (float) getTextWidth:(NSString*)label withContext:(CGContextRef)ctx;
+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize rotation:(double)ang;
+ (UIImage *)image:(UIImage*)img withColor:(UIColor*)color;
+ (NSString*)coordinateToNiceLatLong:(float)val isLat:(bool)isLat;
+ (NSString *)UUIDUsingDefaultAllocator;

@end
