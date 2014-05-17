//
//  iGCSTests.m
//  iGCSTests
//
//  Created by Claudio Natoli on 5/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "iGCSTests.h"

#import "MavLinkUtility.h"
#import "WaypointsHolder.h"

#import "SiKFirmware.h"

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

- (void)testMavCustomModeToString
{
    mavlink_heartbeat_t heartbeat;
    
    heartbeat.autopilot = MAV_AUTOPILOT_ARDUPILOTMEGA;
    heartbeat.type      = MAV_TYPE_FIXED_WING;
    heartbeat.custom_mode = FLY_BY_WIRE_C;
    STAssertEqualObjects([MavLinkUtility mavCustomModeToString:heartbeat], @"FBW_C", @"Incorrect fixed wing mode");
    
    heartbeat.autopilot = MAV_AUTOPILOT_ARDUPILOTMEGA;
    heartbeat.type      = MAV_TYPE_QUADROTOR;
    heartbeat.custom_mode = Circle;
    STAssertEqualObjects([MavLinkUtility mavCustomModeToString:heartbeat], @"Circle", @"Incorrect quadcopter mode");

    heartbeat.autopilot = MAV_AUTOPILOT_ARDUPILOTMEGA;
    heartbeat.type      = MAV_TYPE_GENERIC;
    heartbeat.custom_mode = FLY_BY_WIRE_C;
    STAssertEqualObjects([MavLinkUtility mavCustomModeToString:heartbeat], @"CUSTOM_MODE (7)", @"Incorrect generic type mode");

    heartbeat.autopilot = MAV_AUTOPILOT_GENERIC;
    heartbeat.type      = MAV_TYPE_FIXED_WING;
    heartbeat.custom_mode = FLY_BY_WIRE_C;
    STAssertEqualObjects([MavLinkUtility mavCustomModeToString:heartbeat], @"CUSTOM_MODE (7)", @"Incorrect generic autopilot mode");
}

- (void)testAddressDataPairExtend {
    NSUInteger address1 = 101;
    NSUInteger address2 = 102;
    
    unsigned char b1 = 1;
    unsigned char b2 = 2;
    
    AddressDataPair *adp1 = [[AddressDataPair alloc] initWithAddress:address1 andData:[NSData dataWithBytes:&b1 length:1]];
    AddressDataPair *adp2 = [[AddressDataPair alloc] initWithAddress:address2 andData:[NSData dataWithBytes:&b2 length:1]];
    
    AddressDataPair *oneExtendTwo = [adp1 extend:adp2];
    STAssertTrue(oneExtendTwo.address == address1,  @"Address1 should be retained");
    STAssertTrue(oneExtendTwo.data.length == 2,  @"oneExtendTwo data.length should be 2");
    STAssertTrue(((unsigned char*)oneExtendTwo.data.bytes)[0] == b1,  @"oneExtendTwo data[0] should be b1");
    STAssertTrue(((unsigned char*)oneExtendTwo.data.bytes)[1] == b2,  @"oneExtendTwo data[1] should be b2");

    AddressDataPair *twoExtendOne = [adp2 extend:adp1];
    STAssertTrue(twoExtendOne.address == address2,  @"Address2 should be retained");
    STAssertTrue(twoExtendOne.data.length == 2,  @"oneExtendTwo data.length should be 2");
    STAssertTrue(((unsigned char*)twoExtendOne.data.bytes)[0] == b2,  @"oneExtendTwo data[0] should be b2");
    STAssertTrue(((unsigned char*)twoExtendOne.data.bytes)[1] == b1,  @"oneExtendTwo data[1] should be b1");
}

- (void)testAddressDataPairCompare {
    NSUInteger address1 = 101;
    NSUInteger address2 = 102;
    
    unsigned char b1 = 1;
    unsigned char b2 = 2;
    
    AddressDataPair *adp1 = [[AddressDataPair alloc] initWithAddress:address1 andData:[NSData dataWithBytes:&b1 length:1]];
    AddressDataPair *adp1b = [[AddressDataPair alloc] initWithAddress:address1 andData:[NSData dataWithBytes:&b1 length:1]];

    AddressDataPair *adp2 = [[AddressDataPair alloc] initWithAddress:address2 andData:[NSData dataWithBytes:&b2 length:1]];
    
    STAssertTrue([adp1 compare:adp2] == NSOrderedAscending,  @"adp1 should be less than adp2");
    STAssertTrue([adp2 compare:adp1] == NSOrderedDescending,  @"adp2 should be greater than adp1");
    STAssertTrue([adp1 compare:adp1b] == NSOrderedSame,  @"adp1 should be equal to adp1b");
}

- (void)testSikFirmwareInit {
    NSUInteger address1 = 101;
    NSUInteger address2 = 102;
    
    unsigned char b1 = 1;
    unsigned char b2 = 2;
    
    AddressDataPair *adp1 = [[AddressDataPair alloc] initWithAddress:address1 andData:[NSData dataWithBytes:&b1 length:1]];
    AddressDataPair *adp2 = [[AddressDataPair alloc] initWithAddress:address2 andData:[NSData dataWithBytes:&b2 length:1]];
    
    SiKFirmware *sik1 = [[SiKFirmware alloc] initWithDict:[NSDictionary dictionaryWithObjectsAndKeys:
                                                           adp1, [NSNumber numberWithUnsignedInteger:adp1.address],
                                                           adp2, [NSNumber numberWithUnsignedInteger:adp2.address],
                                                           nil]];
    STAssertTrue(((AddressDataPair*)sik1.sortedAddressDataPairs[0]).address == address1, @"sik1: First pair should have address 1");
    STAssertTrue(((AddressDataPair*)sik1.sortedAddressDataPairs[1]).address == address2, @"sik1: Second pair should have address 2");

    SiKFirmware *sik2 = [[SiKFirmware alloc] initWithDict:[NSDictionary dictionaryWithObjectsAndKeys:
                                                           adp2, [NSNumber numberWithUnsignedInteger:adp2.address],
                                                           adp1, [NSNumber numberWithUnsignedInteger:adp1.address],
                                                           nil]];
    STAssertTrue(((AddressDataPair*)sik2.sortedAddressDataPairs[0]).address == address1, @"sik2: First pair should have address 1");
    STAssertTrue(((AddressDataPair*)sik2.sortedAddressDataPairs[1]).address == address2, @"sik2: Second pair should have address 2");
}

@end
