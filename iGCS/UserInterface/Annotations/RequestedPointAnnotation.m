//
//  FollowMePointAnnotation.m
//  iGCS
//
//  Created by Claudio Natoli on 7/07/13.
//
//

#import "RequestedPointAnnotation.h"

@implementation RequestedPointAnnotation

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate {
    if ((self = [super init])) {
        _coordinate = coordinate;
        _title = @"Next \"Follow Me\" request";
        _viewIdentifer = @"REQUESTED";
        _color = [UIColor orangeColor];
        _doAnimation = NO;
    }
    return self;
}

@end
