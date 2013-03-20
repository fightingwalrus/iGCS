//
//  WayPointsHolder.m
//  iGCS
//
//  Created by Claudio Natoli on 17/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WaypointsHolder.h"

@implementation WaypointsHolder

- (id)initWithExpectedCount:(unsigned int)_expectedCount
{
    self = [super init];
    if (self) {
        // Initialization code
        expectedCount = _expectedCount;
        array = [NSMutableArray arrayWithCapacity:expectedCount];
    }
    return self;
}

- (NSValue*) createBoxedWaypoint:(mavlink_mission_item_t)waypoint {
    return [NSValue valueWithBytes:&waypoint objCType:@encode(mavlink_mission_item_t)];
}

- (bool)allWaypointsReceivedP {
    return ([array count] == expectedCount);
}

- (unsigned int)numWaypoints {
    return [array count];
}

- (void) addWaypoint:(mavlink_mission_item_t)waypoint {
    [array addObject:[self createBoxedWaypoint:waypoint]];
}

- (void) removeWaypoint:(unsigned int) index {
    assert(index >= 0 && index < [self numWaypoints]);
    [array removeObjectAtIndex: index];
}

- (void) replaceWaypoint:(unsigned int) index with:(mavlink_mission_item_t)waypoint {
    assert(index >= 0 && index < [self numWaypoints]);
    [array replaceObjectAtIndex:index withObject:[self createBoxedWaypoint:waypoint]];
}

- (void) swapWaypoints:(unsigned int) index1 :(unsigned int)index2 {
    mavlink_mission_item_t wp1 = [self getWaypoint: index1];
    mavlink_mission_item_t wp2 = [self getWaypoint: index2];
    
    [array replaceObjectAtIndex:index1 withObject:[self createBoxedWaypoint:wp2]];
    [array replaceObjectAtIndex:index2 withObject:[self createBoxedWaypoint:wp1]];
}

- (mavlink_mission_item_t) getWaypoint:(unsigned int) index {
    assert(index >= 0 && index < [self numWaypoints]);
    mavlink_mission_item_t waypoint;

    NSValue *boxedWP = [array objectAtIndex:index];
    //if (strcmp([boxedWP objCType], @encode(mavlink_waypoint_t)) == 0)
    [boxedWP getValue:&waypoint];
    
    return waypoint;
}

- (int)getIndexOfWaypointWithSeq:(int)sequence {
    for (unsigned int i = 0; i < [self numWaypoints]; i++) {
        mavlink_mission_item_t waypoint = [self getWaypoint:i];
        if (waypoint.seq == sequence) {
            return i;
        }
    }
    return -1;
}

- (WaypointsHolder*) getNavWaypoints {
    WaypointsHolder *navWayPoints = [[WaypointsHolder alloc] initWithExpectedCount:[self numWaypoints]];
    for (unsigned int i = 0; i < [self numWaypoints]; i++) {
        mavlink_mission_item_t waypoint = [self getWaypoint:i];
        if (waypoint.command >= MAV_CMD_NAV_LAST) {
            // We didn't get a nav command
            continue;
        }
        [navWayPoints addWaypoint:waypoint];
    }
    return navWayPoints;
}

@end
