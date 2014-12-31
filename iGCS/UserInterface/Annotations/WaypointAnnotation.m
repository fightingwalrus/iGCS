//
//  WaypointAnnotation.m
//  iGCS
//
//  Created by Claudio Natoli on 1/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WaypointAnnotation.h"
#import "WaypointHelper.h"
#import "GCSThemeManager.h"

@interface WaypointAnnotation ()
@property (nonatomic, assign) NSUInteger index;
@end

@implementation WaypointAnnotation

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate andWayPoint:(mavlink_mission_item_t)waypoint atIndex:(NSInteger)index {
    NSAssert((index == 0) == (waypoint.seq == 0), @"Expect waypoint seq and index to both be zero");
    if ((self = [super init])) {
        _coordinate = coordinate;
        _waypoint   = waypoint;
        _index      = index;
    }
    return self;
}

- (NSString*) title {
    return (_index == 0) ? @"Home" : [NSString stringWithFormat:@"%ld: %@", (long)_index, [WaypointHelper commandIDToString: _waypoint.command]]; // Specially handle the HOME/0 waypoint
}

- (NSString*) subtitle {
    return [WaypointHelper navWaypointToDetailString: _waypoint];
}

- (UIColor*) color {
    GCSThemeManager *theme = [GCSThemeManager sharedInstance];
    if (_index == 0) return [theme waypointHomeColor]; // Specially handle the HOME/0 waypoint
    
    switch (_waypoint.command) {            
        case MAV_CMD_NAV_WAYPOINT:
            return [theme waypointNavColor];

        case MAV_CMD_NAV_LOITER_UNLIM:
        case MAV_CMD_NAV_LOITER_TURNS:
        case MAV_CMD_NAV_LOITER_TIME:
            return [theme waypointLoiterColor];
            
        case MAV_CMD_NAV_LAND:
        case MAV_CMD_NAV_TAKEOFF:
            return [theme waypointTakeoffLandColor];
            
        case 0: // Home
            return [theme waypointHomeColor];
    }

    return [theme waypointOtherColor];
}

- (BOOL) hasMatchingSeq:(WaypointSeq)seq {
    return (seq == _waypoint.seq);
}

@end