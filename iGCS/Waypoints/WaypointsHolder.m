//
//  WayPointsHolder.m
//  iGCS
//
//  Created by Claudio Natoli on 17/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WaypointsHolder.h"

#import "WaypointHelper.h"

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

- (id) mutableCopyWithZone:(NSZone *)zone
{
    WaypointsHolder *copy = [[WaypointsHolder allocWithZone: zone] init];
    copy->array = [array mutableCopyWithZone: zone];
    copy->expectedCount = expectedCount;
    return copy;
}

+ (NSValue*) makeBoxedWaypoint:(mavlink_mission_item_t)waypoint {
    return [NSValue valueWithBytes:&waypoint objCType:@encode(mavlink_mission_item_t)];
}

+ (mavlink_mission_item_t) unBoxWaypoint:(id)obj {
    mavlink_mission_item_t waypoint;

    NSValue *boxedWP = obj;
    //if (strcmp([boxedWP objCType], @encode(mavlink_waypoint_t)) == 0)
    [boxedWP getValue:&waypoint];
    
    return waypoint;
}

- (bool)allWaypointsReceivedP {
    return ([array count] == expectedCount);
}

- (unsigned int)numWaypoints {
    return [array count];
}

- (void) addWaypoint:(mavlink_mission_item_t)waypoint {
    // FIXME: We require unique seq numbers, thanks to the dubious usages of getIndexOfWaypointWithSeq.
    //  This seems fragile, and prone to error. Probably best to bite the bullet, wrap each waypoint
    // in an actual object, and use a guid for association.
    int seqNum = -1;
    for (unsigned int i = 0; i < [self numWaypoints]; i++) {
        mavlink_mission_item_t wi = [self getWaypoint:i];
        seqNum = MAX(wi.seq, seqNum);
    }
    waypoint.seq = seqNum+1;
    [array addObject:[WaypointsHolder makeBoxedWaypoint:waypoint]];
}

- (void) removeWaypoint:(unsigned int) index {
    assert(index >= 0 && index < [self numWaypoints]);
    [array removeObjectAtIndex: index];
}

- (void) replaceWaypoint:(unsigned int) index with:(mavlink_mission_item_t)waypoint {
    assert(index >= 0 && index < [self numWaypoints]);
    [array replaceObjectAtIndex:index withObject:[WaypointsHolder makeBoxedWaypoint:waypoint]];
}

- (void) moveWaypoint:(unsigned int)from to:(unsigned int)to {
    mavlink_mission_item_t wp = [self getWaypoint: from];
    [array removeObjectAtIndex:from];
    [array insertObject:[WaypointsHolder makeBoxedWaypoint:wp] atIndex:to];
}

- (mavlink_mission_item_t) getWaypoint:(unsigned int) index {
    assert(index >= 0 && index < [self numWaypoints]);
    return [WaypointsHolder unBoxWaypoint: [array objectAtIndex:index]];
}

- (mavlink_mission_item_t) getLastWaypoint {
    return [self getWaypoint: ([self numWaypoints]-1)];
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
        if ([WaypointHelper isNavCommand: waypoint]) {
            [navWayPoints->array addObject:[WaypointsHolder makeBoxedWaypoint:waypoint]];
        }
    }
    return navWayPoints;
}

- (NSString*) toOutputFormat {
    NSString *res = @"QGC WPL 110\n";
    for (unsigned int i = 0; i < [self numWaypoints]; i++) {
        mavlink_mission_item_t item = [self getWaypoint:i];
        res = [res stringByAppendingFormat:@"%d\t%d\t\%d\t%d\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%d\n",
               i, i==0, item.frame, item.command,
               item.param1, item.param2, item.param3, item.param4,
               item.x, item.y, item.z, item.autocontinue];
    }
    return res;
}

@end
