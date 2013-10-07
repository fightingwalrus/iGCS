//
//  iGCSTests.m
//  iGCSTests
//
//  Created by Claudio Natoli on 5/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "iGCSTests.h"

#import "WaypointsHolder.h"

@implementation iGCSTests

- (void)setUp
{
    [super setUp];
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    [super tearDown];
}

- (void)testExample
{
    //STFail(@"Unit tests are not implemented yet in iGCSTests");
}

- (void)testWaypointsHolderConversionEmpty {
    NSString* demoQGC = @"QGC WPL 110";
    
    // Create mission from string
    WaypointsHolder* demo = [WaypointsHolder createFromQGCString:demoQGC];
    STAssertNotNil(demo, @"Failed to create empty mission");
    STAssertTrue([demo numWaypoints] == 0, @"Converted mission should not contain any items");
}

- (void)testWaypointsHolderConversionFailure {
    // Like the implementation, this is not intended to be comprehensive or exhaustive
    STAssertNil([WaypointsHolder createFromQGCString:@"ZGC WPL 110"], @"Incorrectly created mission with invalid header");
    
    STAssertNil([WaypointsHolder createFromQGCString:@"QGC WPL 110\n0  1	0	16	0.149999999999999994	0	0	0	8.54800000000000004	47.3759999999999977	550"], @"Incorrectly created mission without autocontinue column");
}

- (void)testWaypointsHolderConversionSingleWaypoint {
    // First lines of example given in from http://qgroundcontrol.org/mavlink/waypoint_protocol
    NSString* demoQGC = @"QGC WPL 110\n0	1	0	16	0.149999999999999994	0	0	0	8.54800000000000004	47.3759999999999977	550	1";
    
    // Create mission from string
    WaypointsHolder* demo = [WaypointsHolder createFromQGCString:demoQGC];
    STAssertNotNil(demo, @"Failed to create single waypoint mission");
    STAssertTrue([demo numWaypoints] == 1, @"Converted mission should contain a single items");
    
    mavlink_mission_item_t item = [demo getWaypoint:0];
    STAssertTrue(item.seq     == 0,                    @"Mission item should be the first in the sequence");
    STAssertTrue(item.current == 1,                    @"Mission item should be current");
    STAssertTrue(item.command == MAV_CMD_NAV_WAYPOINT, @"Mission item should be a waypoint");
    STAssertTrue(item.frame   == MAV_FRAME_GLOBAL,     @"Mission item frame should be global");
    STAssertTrue(item.z       == 550,                  @"Mission item height incorrectly read");
    STAssertTrue(item.autocontinue == 1,               @"Mission item autocontinue incorrectly read");
}

- (void)testWaypointsHolderDemoMissionConversion
{
    // Get example demo mission
    WaypointsHolder* demo = [WaypointsHolder createDemoMission];
    
    // Convert to string
    NSString* demoQGC = [demo toOutputFormat];
    STAssertNotNil(demoQGC, @"Failed to convert QGC string");

    // Convert back to mission
    WaypointsHolder* demo2 = [WaypointsHolder createFromQGCString:demoQGC];
    STAssertNotNil(demo2, @"Failed to convert QGC string");
    
    // Check that string from converted mission matches original string
    STAssertEqualObjects(demoQGC, [demo2 toOutputFormat], @"Failed to match original QGC after conversion");
}

@end
