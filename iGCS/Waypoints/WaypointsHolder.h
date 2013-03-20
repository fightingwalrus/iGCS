//
//  WayPointsHolder.h
//  iGCS
//
//  Created by Claudio Natoli on 17/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MavLinkPacketHandler.h"

@interface WaypointsHolder : NSObject  {
    NSMutableArray *array;
    unsigned int expectedCount;
}

- (id)initWithExpectedCount:(unsigned int)_expectedCount;

- (bool) allWaypointsReceivedP;
- (unsigned int)numWaypoints;

- (void) addWaypoint:(mavlink_mission_item_t)waypoint;
- (void) removeWaypoint:(unsigned int) index;
- (void) replaceWaypoint:(unsigned int) index with:(mavlink_mission_item_t)waypoint;
- (void) swapWaypoints:(unsigned int) index1 :(unsigned int)index2;

- (int) getIndexOfWaypointWithSeq:(int)sequence;
- (mavlink_mission_item_t) getWaypoint:(unsigned int) index;

- (WaypointsHolder*) getNavWaypoints;

@end
