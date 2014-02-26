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

@synthesize coordinate     = _coordinate;
@synthesize title          = _title;
@synthesize viewIdentifier = _viewIdentifer;
@synthesize color          = _color;
@synthesize doAnimation    = _doAnimation;

- (NSString*) subtitle {
    return [NSString stringWithFormat:@"%@, %@",
            [MiscUtilities prettyPrintCoordAxis:_coordinate.latitude  as:GCSLatitude],
            [MiscUtilities prettyPrintCoordAxis:_coordinate.longitude as:GCSLongitude]];
}

@end
