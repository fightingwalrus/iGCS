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

@implementation WaypointAnnotation

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate andWayPoint:(mavlink_mission_item_t)waypoint atIndex:(int)index {
    if ((self = [super init])) {
        _coordinate = coordinate;
        _waypoint   = waypoint;
        _index      = index;
    }
    return self;
}

- (NSString*) title {
    return [NSString stringWithFormat:@"%d: %@", _index, [WaypointHelper commandIDToString: _waypoint.command]];
}

- (NSString*) subtitle {
    return [WaypointHelper navWaypointToDetailString: _waypoint];
}

- (UIColor*) getColor {
    GCSThemeManager *theme = [GCSThemeManager sharedInstance];
    
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

- (bool) isCurrentWaypointP:(int)currentWaypointSeq {
    return (currentWaypointSeq == _waypoint.seq);
}

@end