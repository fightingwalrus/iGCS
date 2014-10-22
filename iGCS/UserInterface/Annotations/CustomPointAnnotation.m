//
//  CustomPointAnnotation.m
//  iGCS
//
//  Created by Claudio Natoli on 7/07/13.
//
//

#import "CustomPointAnnotation.h"
#import "MiscUtilities.h"

@implementation CustomPointAnnotation

- (NSString*) subtitle {
    return [NSString stringWithFormat:@"%@, %@",
            [MiscUtilities prettyPrintCoordAxis:_coordinate.latitude  as:GCSLatitude],
            [MiscUtilities prettyPrintCoordAxis:_coordinate.longitude as:GCSLongitude]];
}

@end
