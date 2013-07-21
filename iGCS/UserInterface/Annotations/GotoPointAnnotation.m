//
//  GotoPointAnnotation.m
//  iGCS
//
//  Created by Claudio Natoli on 6/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GotoPointAnnotation.h"
#import "WaypointAnnotation.h"

@implementation GotoPointAnnotation

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate {
    if ((self = [super init])) {
        _coordinate = coordinate;
        _title = @"GOTO point";
        _viewIdentifer = @"GOTO";
        _color = WAYPOINT_NAV_COLOR;
        _animationRepeatCount = HUGE_VAL;
    }
    return self;
}

@end
