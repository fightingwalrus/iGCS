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
    NSUInteger _expectedCount;
}

- (instancetype)initWithExpectedCount:(NSUInteger)expectedCount NS_DESIGNATED_INITIALIZER;

@property (nonatomic, readonly) BOOL allWaypointsReceivedP;
@property (nonatomic, readonly) NSUInteger numWaypoints;

@property (nonatomic, readonly) mavlink_mission_item_t lastWaypoint;
@property (nonatomic, readonly, strong) WaypointsHolder *navWaypoints;
@property (nonatomic, readonly, copy) NSString *toOutputFormat;

+ (NSValue*) makeBoxedWaypoint:(mavlink_mission_item_t)waypoint;
+ (mavlink_mission_item_t) unBoxWaypoint:(id)obj;

- (void) addWaypoint:(mavlink_mission_item_t)waypoint;
- (void) removeWaypoint:(NSUInteger) index;
- (void) replaceWaypoint:(NSUInteger) index with:(mavlink_mission_item_t)waypoint;
- (void) moveWaypoint:(NSUInteger) index1 to:(NSUInteger)index2;

- (int) getIndexOfWaypointWithSeq:(int)sequence;
- (mavlink_mission_item_t) getWaypoint:(NSUInteger) index;
+ (WaypointsHolder*) createFromQGCString:(NSString*)qgcString;

+ (WaypointsHolder*) createDemoMission;

@end
