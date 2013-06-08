//
//  WaypointAnnotation.h
//  iGCS
//
//  Created by Claudio Natoli on 1/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "MavLinkPacketHandler.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define WAYPOINT_LINE_COLOR             UIColorFromRGB(0x08ff08) // fluro green
#define WAYPOINT_NAV_COLOR              UIColorFromRGB(0x08ff08) 
#define WAYPOINT_NAV_NEXT_COLOR         [UIColor redColor]

#define WAYPOINT_LOITER_COLOR           [UIColor blueColor]
#define WAYPOINT_TAKEOFF_LAND_COLOR     [UIColor orangeColor]
#define WAYPOINT_HOME_COLOR             [UIColor whiteColor]
#define WAYPOINT_OTHER_COLOR            [UIColor redColor]

#define TRACK_LINE_COLOR                [UIColor purpleColor]


@interface WaypointAnnotation : NSObject <MKAnnotation> {
    CLLocationCoordinate2D _coordinate;
    mavlink_mission_item_t _waypoint;
    int _index;
}

@property (nonatomic, readonly) CLLocationCoordinate2D  coordinate;
@property (nonatomic, readonly) mavlink_mission_item_t      waypoint;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate andWayPoint:(mavlink_mission_item_t)waypoint atIndex:(int)index;
- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;

- (UIColor*) getColor;
- (bool) isCurrentWaypointP:(int)currentWaypointSeq;

@end
