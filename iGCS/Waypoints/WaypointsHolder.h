//
//  WayPointsHolder.h
//  iGCS
//
//  Created by Claudio Natoli on 17/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MavLinkPacketHandler.h"

@interface WaypointsHolder : NSObject <NSMutableCopying> {
    NSMutableArray *array;
    unsigned int expectedCount;
}

- (id)initWithExpectedCount:(unsigned int)_expectedCount;

- (bool) allWaypointsReceivedP;
- (unsigned int)numWaypoints;

+ (NSValue*) makeBoxedWaypoint:(mavlink_mission_item_t)waypoint;
+ (mavlink_mission_item_t) unBoxWaypoint:(id)obj;

- (void) addWaypoint:(mavlink_mission_item_t)waypoint;
- (void) removeWaypoint:(unsigned int) index;
- (void) replaceWaypoint:(unsigned int) index with:(mavlink_mission_item_t)waypoint;
- (void) moveWaypoint:(unsigned int) index1 to:(unsigned int)index2;

- (int) getIndexOfWaypointWithSeq:(int)sequence;
- (mavlink_mission_item_t) getWaypoint:(unsigned int) index;
- (mavlink_mission_item_t) getLastWaypoint;

- (WaypointsHolder*) getNavWaypoints;

- (NSString*) toOutputFormat;
+ (WaypointsHolder*) createFromQGCString:(NSString*)qgcString;

+ (WaypointsHolder*) createDemoMission;

@end
