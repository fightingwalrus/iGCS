//
//  MiscUtilities.h
//  iGCS
//
//  Created by Claudio Natoli on 21/07/13.
//
//

#import <Foundation/Foundation.h>

@interface MiscUtilities : NSObject

+ (NSString*) coordinateToNiceLatLong:(float)val isLat:(bool)isLat;

@end
