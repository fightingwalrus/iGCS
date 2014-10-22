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
    NSMutableArray *_array;
    unsigned int _expectedCount;
}

- (instancetype)initWithExpectedCount:(unsigned int)expectedCount NS_DESIGNATED_INITIALIZER;

@property (nonatomic, readonly) bool allWaypointsReceivedP;
@property (nonatomic, readonly) unsigned int numWaypoints;

@property (nonatomic, readonly) mavlink_mission_item_t lastWaypoint;
@property (nonatomic, readonly, strong) WaypointsHolder *navWaypoints;
@property (nonatomic, readonly, copy) NSString *toOutputFormat;

+ (NSValue*) makeBoxedWaypoint:(mavlink_mission_item_t)waypoint;
+ (mavlink_mission_item_t) unBoxWaypoint:(id)obj;

- (void) addWaypoint:(mavlink_mission_item_t)waypoint;
- (void) removeWaypoint:(unsigned int) index;
- (void) replaceWaypoint:(unsigned int) index with:(mavlink_mission_item_t)waypoint;
- (void) moveWaypoint:(unsigned int) index1 to:(unsigned int)index2;

- (int) getIndexOfWaypointWithSeq:(int)sequence;
- (mavlink_mission_item_t) getWaypoint:(unsigned int) index;
+ (WaypointsHolder*) createFromQGCString:(NSString*)qgcString;

+ (WaypointsHolder*) createDemoMission;

@end
