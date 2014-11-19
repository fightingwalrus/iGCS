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

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate
                             title:(NSString*)title
                            viewID:(NSString*)viewIdentifier
                             color:(UIColor*)color
                      andAnimation:(BOOL)doAnimation {
    if ((self = [super init])) {
        _coordinate = coordinate;
        _title = title;
        _viewIdentifier = viewIdentifier;
        _color = color;
        _doAnimation = doAnimation;
    }
    return self;
}

- (NSString*) subtitle {
    return [NSString stringWithFormat:@"%@, %@",
            [MiscUtilities prettyPrintCoordAxis:_coordinate.latitude  as:GCSLatitude],
            [MiscUtilities prettyPrintCoordAxis:_coordinate.longitude as:GCSLongitude]];
}

@end
