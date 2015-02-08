//
//  WaypointsTests.m
//  iGCS
//
//  Created by Claudio Natoli on 4/02/2015.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "WaypointsHolder.h"

@interface WaypointsTests : XCTestCase

@end

@implementation WaypointsTests


- (void)testWaypointsHolderConversionEmpty {
    NSString* demoQGC = @"QGC WPL 110";
    
    // Create mission from string
    WaypointsHolder* demo = [WaypointsHolder createFromQGCString:demoQGC];
    XCTAssertNotNil(demo, @"Failed to create empty mission");
    XCTAssertTrue([demo numWaypoints] == 0, @"Converted mission should not contain any items");
}

- (void)testWaypointsHolderConversionFailure {
    // Like the implementation, this is not intended to be comprehensive or exhaustive
    XCTAssertNil([WaypointsHolder createFromQGCString:@"ZGC WPL 110"], @"Incorrectly created mission with invalid header");
    
    XCTAssertNil([WaypointsHolder createFromQGCString:@"QGC WPL 110\n0  1	0	16	0.149999999999999994	0	0	0	8.54800000000000004	47.3759999999999977	550"], @"Incorrectly created mission without autocontinue column");
}

- (void)testWaypointsHolderConversionSingleWaypoint {
    // First lines of example given in from http://qgroundcontrol.org/mavlink/waypoint_protocol
    NSString* demoQGC = @"QGC WPL 110\n0	1	0	16	0.149999999999999994	0	0	0	8.54800000000000004	47.3759999999999977	550	1";
    
    // Create mission from string
    WaypointsHolder* demo = [WaypointsHolder createFromQGCString:demoQGC];
    XCTAssertNotNil(demo, @"Failed to create single waypoint mission");
    XCTAssertTrue([demo numWaypoints] == 1, @"Converted mission should contain a single items");
    
    mavlink_mission_item_t item = [demo getWaypoint:0];
    XCTAssertTrue(item.seq     == 0,                    @"Mission item should be the first in the sequence");
    XCTAssertTrue(item.current == 1,                    @"Mission item should be current");
    XCTAssertTrue(item.command == MAV_CMD_NAV_WAYPOINT, @"Mission item should be a waypoint");
    XCTAssertTrue(item.frame   == MAV_FRAME_GLOBAL,     @"Mission item frame should be global");
    XCTAssertTrue(item.z       == 550,                  @"Mission item height incorrectly read");
    XCTAssertTrue(item.autocontinue == 1,               @"Mission item autocontinue incorrectly read");
}

- (void)testWaypointsHolderDemoMissionConversion
{
    // Get example demo mission
    WaypointsHolder* demo = [WaypointsHolder createDemoMission];
    
    // Convert to string
    NSString* demoQGC = [demo toOutputFormat];
    XCTAssertNotNil(demoQGC, @"Failed to convert QGC string");
    
    // Convert back to mission
    WaypointsHolder* demo2 = [WaypointsHolder createFromQGCString:demoQGC];
    XCTAssertNotNil(demo2, @"Failed to convert QGC string");
    
    // Check that string from converted mission matches original string
    XCTAssertEqualObjects(demoQGC, [demo2 toOutputFormat], @"Failed to match original QGC after conversion");
}

@end
