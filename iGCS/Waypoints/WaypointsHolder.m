//
//  WayPointsHolder.m
//  iGCS
//
//  Created by Claudio Natoli on 17/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WaypointsHolder.h"

#import "WaypointHelper.h"

@interface WaypointsHolder ()
@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic, assign) NSUInteger expectedCount;
@end

@implementation WaypointsHolder

- (instancetype)initWithExpectedCount:(NSUInteger)expectedCount {
    self = [super init];
    if (self) {
        // Initialization code
        _expectedCount = expectedCount;
        _array = [NSMutableArray arrayWithCapacity:_expectedCount];
    }
    return self;
}

- (id) mutableCopyWithZone:(NSZone *)zone {
    WaypointsHolder *copy = [[WaypointsHolder allocWithZone: zone] init];
    copy.array = [self.array mutableCopyWithZone: zone];
    copy.expectedCount = self.expectedCount;
    return copy;
}

+ (NSValue*) makeBoxedWaypoint:(mavlink_mission_item_t)waypoint {
    return [NSValue valueWithBytes:&waypoint objCType:@encode(mavlink_mission_item_t)];
}

+ (mavlink_mission_item_t) unBoxWaypoint:(id)obj {
    mavlink_mission_item_t waypoint;

    NSValue *boxedWP = obj;
    [boxedWP getValue:&waypoint];

    return waypoint;
}

- (BOOL)hasReceivedAllWaypoints {
    return ([self.array count] == self.expectedCount);
}

- (NSUInteger)numWaypoints {
    return [self.array count];
}

- (void) addWaypoint:(mavlink_mission_item_t)waypoint {
    // FIXME: We require unique seq numbers, thanks to the dubious usages of getIndexOfWaypointWithSeq.
    //  This seems fragile, and prone to error. Probably best to bite the bullet, wrap each waypoint
    // in an actual object, and use a guid for association.
    NSInteger seqNum = -1;
    for (NSUInteger i = 0; i < [self numWaypoints]; i++) {
        mavlink_mission_item_t wi = [self getWaypoint:i];
        seqNum = MAX(wi.seq, seqNum);
    }
    waypoint.seq = seqNum+1;
    [self.array addObject:[WaypointsHolder makeBoxedWaypoint:waypoint]];
}

- (void) removeWaypoint:(NSUInteger) index {
    assert(index >= 0 && index < [self numWaypoints]);
    [self.array removeObjectAtIndex: index];
}

- (void) replaceWaypoint:(NSUInteger) index with:(mavlink_mission_item_t)waypoint {
    assert(index >= 0 && index < [self numWaypoints]);
    self.array[index] = [WaypointsHolder makeBoxedWaypoint:waypoint];
}

- (void) moveWaypoint:(NSUInteger)from to:(NSUInteger)to {
    mavlink_mission_item_t wp = [self getWaypoint: from];
    [self.array removeObjectAtIndex:from];
    [self.array insertObject:[WaypointsHolder makeBoxedWaypoint:wp] atIndex:to];
}

- (mavlink_mission_item_t) getWaypoint:(NSUInteger) index {
    assert(index >= 0 && index < [self numWaypoints]);
    return [WaypointsHolder unBoxWaypoint: self.array[index]];
}

- (mavlink_mission_item_t) lastWaypoint {
    return [self getWaypoint: ([self numWaypoints]-1)];
}

- (NSInteger)getIndexOfWaypointWithSeq:(WaypointSeq)sequence {
    for (NSUInteger i = 0; i < [self numWaypoints]; i++) {
        mavlink_mission_item_t waypoint = [self getWaypoint:i];
        if (waypoint.seq == sequence) {
            return i;
        }
    }
    return -1;
}

- (WaypointsHolder*) navWaypoints {
    WaypointsHolder *navWayPoints = [[WaypointsHolder alloc] initWithExpectedCount:[self numWaypoints]];
    for (NSUInteger i = 0; i < [self numWaypoints]; i++) {
        mavlink_mission_item_t waypoint = [self getWaypoint:i];
        if ([WaypointHelper isNavCommand: waypoint]) {
            [navWayPoints.array addObject:[WaypointsHolder makeBoxedWaypoint:waypoint]];
        }
    }
    return navWayPoints;
}

- (NSString*) toOutputFormat {
    NSMutableString *res = [NSMutableString stringWithString:@"QGC WPL 110\n"];
    for (NSUInteger i = 0; i < [self numWaypoints]; i++) {
        mavlink_mission_item_t item = [self getWaypoint:i];
        [res appendFormat:@"%lu\t%d\t\%d\t%d\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%d\n",
         (unsigned long)i, i==0, item.frame, item.command,
         item.param1, item.param2, item.param3, item.param4,
         item.x, item.y, item.z, item.autocontinue];
    }
    return res;
}

+ (BOOL) readLine:(NSString*)line intoMissionItem:(mavlink_mission_item_t*)item {
    NSScanner *scanner = [NSScanner scannerWithString:line];
    int x;
    
    BOOL ret = [scanner scanInt:&x]; item->seq     = x;
    ret &= [scanner scanInt:&x];     item->current = x;
    ret &= [scanner scanInt:&x];     item->frame   = x;
    ret &= [scanner scanInt:&x];     item->command = x;
    ret &= [scanner scanFloat:&item->param1];
    ret &= [scanner scanFloat:&item->param2];
    ret &= [scanner scanFloat:&item->param3];
    ret &= [scanner scanFloat:&item->param4];
    ret &= [scanner scanFloat:&item->x];
    ret &= [scanner scanFloat:&item->y];
    ret &= [scanner scanFloat:&item->z];
    ret &= [scanner scanInt:&x];     item->autocontinue = x;
    
    return ret;
}

+ (WaypointsHolder*) createFromQGCString:(NSString*)qgcString {
    NSArray* lines = [qgcString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSUInteger numLines = [lines count];
    
    // Check header
    if (numLines == 0 || ![((NSString*)lines[0]) isEqualToString:@"QGC WPL 110"]) {
        return nil;
    }
    
    // Read waypoints
    WaypointsHolder *mission = [[WaypointsHolder alloc] initWithExpectedCount:numLines];
    for (NSUInteger i = 1; i < numLines; i++) {
        NSString *line = lines[i];
        if ([line length] == 0 && (i == numLines - 1)) {
            break; // allow an empty line at the end
        }
        
        mavlink_mission_item_t item;
        if ([WaypointsHolder readLine:line intoMissionItem:&item]) {
            [mission addWaypoint:item];
        } else {
            return nil; // something got borked
        }
    }
    return mission;
}

+ (WaypointsHolder*) createDemoMission {
    // Debug demo mission
    WaypointsHolder *demo = [[WaypointsHolder alloc] initWithExpectedCount:10];
    
    mavlink_mission_item_t waypoint;
    waypoint.seq = 0; waypoint.command = 16; waypoint.x = 47.258470; waypoint.y = 11.331370; waypoint.z = 10; [demo addWaypoint:waypoint];
    waypoint.seq = 1; waypoint.command = 22; waypoint.x = 47.258842; waypoint.y = 11.331070; waypoint.z = 10; [demo addWaypoint:waypoint];
    waypoint.seq = 2; waypoint.command = 16; waypoint.x = 47.260709; waypoint.y = 11.348920; waypoint.z = 100; waypoint.param1 = 1; waypoint.param2 = 2; waypoint.param3 = 3; waypoint.param4 = 4; [demo addWaypoint:waypoint];
    waypoint.seq = 3; waypoint.command = 18; waypoint.x = 47.264815; waypoint.y = 11.347847; waypoint.z = 100; waypoint.param1 = 5; [demo addWaypoint:waypoint];
    
    // MAV_CMD_CONDITION_CHANGE_ALT
    waypoint.seq = 4; waypoint.command = 113; waypoint.x = 0; waypoint.y = 0; waypoint.z = 0; waypoint.param1 = 100; waypoint.param2 = 2000; [demo addWaypoint:waypoint];

    waypoint.seq = 5; waypoint.command = 16; waypoint.x = 47.262573; waypoint.y = 11.324630; waypoint.z = 100; [demo addWaypoint:waypoint];
    waypoint.seq = 6; waypoint.command = 16; waypoint.x = 47.258262; waypoint.y = 11.325445; waypoint.z = 100; [demo addWaypoint:waypoint];
    
    // MAV_CMD_DO_JUMP
    waypoint.seq = 7; waypoint.command = 177; waypoint.x = 0; waypoint.y = 0; waypoint.z = 0; waypoint.param1 = 1; waypoint.param3 = 6; [demo addWaypoint:waypoint];
    
    waypoint.seq = 8; waypoint.command = 16; waypoint.x = 47.258757; waypoint.y = 11.330380; waypoint.z =  50; [demo addWaypoint:waypoint];
    waypoint.seq = 9; waypoint.command = 16; waypoint.x = 47.259427; waypoint.y = 11.336904; waypoint.z =  20; [demo addWaypoint:waypoint];
    waypoint.seq = 10; waypoint.command = 21; waypoint.x = 47.259864; waypoint.y = 11.340809; waypoint.z = 100; [demo addWaypoint:waypoint];
    
    return demo;
}

@end
