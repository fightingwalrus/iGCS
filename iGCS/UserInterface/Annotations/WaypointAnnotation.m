//
//  WaypointAnnotation.m
//  iGCS
//
//  Created by Claudio Natoli on 1/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WaypointAnnotation.h"
#import "WaypointHelper.h"

@implementation UIColor (GCS)
+(UIColor*) gcsWaypointLineStrokeColor { return [UIColor blackColor]; }
+(UIColor*) gcsWaypointLineFillColor   { return UIColorFromRGB(0x08ff08); } // fluoro green

+(UIColor*) gcsTrackLineColor { return [UIColor purpleColor]; }

+(UIColor*) gcsWaypointNavColor         { return UIColorFromRGB(0x08ff08); } // fluoro green
+(UIColor*) gcsWaypointNavNextColor     { return [UIColor redColor]; }
+(UIColor*) gcsWaypointLoiterColor      { return UIColorFromRGB(0x87cefa); } // light sky blue
+(UIColor*) gcsWaypointTakeoffLandColor { return UIColorFromRGB(0xff8c00); } // dark orange
+(UIColor*) gcsWaypointHomeColor        { return [UIColor whiteColor]; }
+(UIColor*) gcsWaypointOtherColor       { return UIColorFromRGB(0xd02090); } // violet red
@end


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
    switch (_waypoint.command) {            
        case MAV_CMD_NAV_WAYPOINT:
            return [UIColor gcsWaypointNavColor];

        case MAV_CMD_NAV_LOITER_UNLIM:
        case MAV_CMD_NAV_LOITER_TURNS:
        case MAV_CMD_NAV_LOITER_TIME:
            return [UIColor gcsWaypointLoiterColor];

        case MAV_CMD_NAV_LAND:
        case MAV_CMD_NAV_TAKEOFF:
            return [UIColor gcsWaypointTakeoffLandColor];
        
        case 0: // Home
            return [UIColor gcsWaypointHomeColor];
    }

    return  [UIColor gcsWaypointOtherColor];
}

- (bool) isCurrentWaypointP:(int)currentWaypointSeq {
    return (currentWaypointSeq == _waypoint.seq);
}

@end