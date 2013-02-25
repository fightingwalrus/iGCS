//
//  WaypointAnnotation.m
//  iGCS
//
//  Created by Claudio Natoli on 1/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WaypointAnnotation.h"
#import "WaypointHelper.h"

@implementation WaypointAnnotation

@synthesize coordinate  = _coordinate;
@synthesize waypoint    = _waypoint;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate andWayPoint:(mavlink_mission_item_t)waypoint {
    if ((self = [super init])) {
        _coordinate = coordinate;
        _waypoint   = waypoint;
    }
    return self;
}

- (NSString*) title {
    return [NSString stringWithFormat:@"%d: %@", _waypoint.seq, [WaypointHelper commandIDToString: _waypoint.command]];
}

- (NSString*) subtitle {
    return [WaypointHelper navWaypointToDetailString: _waypoint];
}

- (UIColor*) getColor {
    switch (_waypoint.command) {            
        case MAV_CMD_NAV_WAYPOINT:
            return WAYPOINT_NAV_COLOR;

        case MAV_CMD_NAV_LOITER_UNLIM:
        case MAV_CMD_NAV_LOITER_TURNS:
        case MAV_CMD_NAV_LOITER_TIME:
            return WAYPOINT_LOITER_COLOR;

        case MAV_CMD_NAV_LAND:
        case MAV_CMD_NAV_TAKEOFF:
            return WAYPOINT_TAKEOFF_LAND_COLOR;
        
        case 0: // Home
            return WAYPOINT_HOME_COLOR;
    }

    return WAYPOINT_OTHER_COLOR;
}

- (bool) isCurrentWaypointP:(int)currentWaypointSeq {
    return (currentWaypointSeq == _waypoint.seq);
}

@end