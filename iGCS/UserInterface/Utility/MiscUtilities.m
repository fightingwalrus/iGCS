//
//  MiscUtilities.m
//  iGCS
//
//  Created by Claudio Natoli on 21/07/13.
//
//

#import "MiscUtilities.h"

@implementation MiscUtilities

+ (NSString*) coordinateToNiceLatLong:(float)val isLat:(bool)isLat {
    char letter = (val > 0) ? 'E' : 'W';
    if (isLat) {
        letter = (val > 0) ? 'N' : 'S';
    }
    
    val = fabs(val);
    
    int deg = (int)val;
    val = (val - deg) * 60;
    
    int min = (int)val;
    float sec = (val - min) * 60;
    
    return [NSString stringWithFormat:@"%02d° %02d' %02.2f%c", deg, min, sec, letter];
}


@end
