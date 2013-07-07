//
//  FollowMePointAnnotation.m
//  iGCS
//
//  Created by Claudio Natoli on 7/07/13.
//
//

#import "FollowMePointAnnotation.h"

@implementation FollowMePointAnnotation

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate {
    if ((self = [super init])) {
        _coordinate = coordinate;
        _title = @"FOLLOWME point";
        _viewIdentifer = @"FOLLOWME";
        _color = [UIColor redColor];
    }
    return self;
}

@end
