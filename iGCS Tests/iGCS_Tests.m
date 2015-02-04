//
//  iGCS_Tests.m
//  iGCS_Tests
//
//  Created by Claudio Natoli on 5/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "MavLinkUtility.h"
#import "WaypointsHolder.h"

#import "SiKFirmware.h"

#import "GCSCraftModes.h"

@interface iGCS_Tests : XCTestCase

@end

@implementation iGCS_Tests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

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

- (void)testMavCustomModeToString
{
    mavlink_heartbeat_t heartbeat;
    
    heartbeat.autopilot = MAV_AUTOPILOT_ARDUPILOTMEGA;
    heartbeat.type      = MAV_TYPE_FIXED_WING;
    heartbeat.custom_mode = APMPlaneFlyByWireC;
    XCTAssertEqualObjects([MavLinkUtility mavCustomModeToString:heartbeat], @"FBW_C", @"Incorrect fixed wing mode");
    
    heartbeat.autopilot = MAV_AUTOPILOT_ARDUPILOTMEGA;
    heartbeat.type      = MAV_TYPE_QUADROTOR;
    heartbeat.custom_mode = APMCopterCircle;
    XCTAssertEqualObjects([MavLinkUtility mavCustomModeToString:heartbeat], @"Circle", @"Incorrect quadcopter mode");
    
    heartbeat.autopilot = MAV_AUTOPILOT_ARDUPILOTMEGA;
    heartbeat.type      = MAV_TYPE_GENERIC;
    heartbeat.custom_mode = APMPlaneFlyByWireC;
    XCTAssertEqualObjects([MavLinkUtility mavCustomModeToString:heartbeat], @"CUSTOM_MODE (7)", @"Incorrect generic type mode");
    
    heartbeat.autopilot = MAV_AUTOPILOT_GENERIC;
    heartbeat.type      = MAV_TYPE_FIXED_WING;
    heartbeat.custom_mode = APMPlaneFlyByWireC;
    XCTAssertEqualObjects([MavLinkUtility mavCustomModeToString:heartbeat], @"CUSTOM_MODE (7)", @"Incorrect generic autopilot mode");
}

- (void)testAddressDataPairExtend {
    NSUInteger address1 = 101;
    NSUInteger address2 = 102;
    
    unsigned char b1 = 1;
    unsigned char b2 = 2;
    
    AddressDataPair *adp1 = [[AddressDataPair alloc] initWithAddress:address1 andData:[NSData dataWithBytes:&b1 length:1]];
    AddressDataPair *adp2 = [[AddressDataPair alloc] initWithAddress:address2 andData:[NSData dataWithBytes:&b2 length:1]];
    
    AddressDataPair *oneExtendTwo = [adp1 extend:adp2];
    XCTAssertEqual(oneExtendTwo.address, address1,  @"Address1 should be retained");
    XCTAssertEqual(oneExtendTwo.data.length, 2U,  @"oneExtendTwo data.length should be 2");
    XCTAssertEqual(((unsigned char*)oneExtendTwo.data.bytes)[0], b1,  @"oneExtendTwo data[0] should be b1");
    XCTAssertEqual(((unsigned char*)oneExtendTwo.data.bytes)[1], b2,  @"oneExtendTwo data[1] should be b2");
    
    AddressDataPair *twoExtendOne = [adp2 extend:adp1];
    XCTAssertEqual(twoExtendOne.address, address2,  @"Address2 should be retained");
    XCTAssertEqual(twoExtendOne.data.length, 2U,  @"oneExtendTwo data.length should be 2");
    XCTAssertEqual(((unsigned char*)twoExtendOne.data.bytes)[0], b2,  @"oneExtendTwo data[0] should be b2");
    XCTAssertEqual(((unsigned char*)twoExtendOne.data.bytes)[1], b1,  @"oneExtendTwo data[1] should be b1");
}

- (void)testAddressDataPairCompare {
    NSUInteger address1 = 101;
    NSUInteger address2 = 102;
    
    unsigned char b1 = 1;
    unsigned char b2 = 2;
    
    AddressDataPair *adp1 = [[AddressDataPair alloc] initWithAddress:address1 andData:[NSData dataWithBytes:&b1 length:1]];
    AddressDataPair *adp1b = [[AddressDataPair alloc] initWithAddress:address1 andData:[NSData dataWithBytes:&b1 length:1]];
    
    AddressDataPair *adp2 = [[AddressDataPair alloc] initWithAddress:address2 andData:[NSData dataWithBytes:&b2 length:1]];
    
    XCTAssertTrue([adp1 compare:adp2] == NSOrderedAscending,  @"adp1 should be less than adp2");
    XCTAssertTrue([adp2 compare:adp1] == NSOrderedDescending,  @"adp2 should be greater than adp1");
    XCTAssertTrue([adp1 compare:adp1b] == NSOrderedSame,  @"adp1 should be equal to adp1b");
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
    XCTAssertEqual(((AddressDataPair*)sik1.sortedAddressDataPairs[0]).address, address1, @"sik1: First pair should have address 1");
    XCTAssertEqual(((AddressDataPair*)sik1.sortedAddressDataPairs[1]).address, address2, @"sik1: Second pair should have address 2");
    
    SiKFirmware *sik2 = [[SiKFirmware alloc] initWithDict:[NSDictionary dictionaryWithObjectsAndKeys:
                                                           adp2, [NSNumber numberWithUnsignedInteger:adp2.address],
                                                           adp1, [NSNumber numberWithUnsignedInteger:adp1.address],
                                                           nil]];
    XCTAssertEqual(((AddressDataPair*)sik2.sortedAddressDataPairs[0]).address, address1, @"sik2: First pair should have address 1");
    XCTAssertEqual(((AddressDataPair*)sik2.sortedAddressDataPairs[1]).address, address2, @"sik2: Second pair should have address 2");
}

-(void)checkSiKFirmware:(NSString*)filePrefix
         expectedLength:(NSUInteger)expectedLength
          referenceDict:(NSDictionary*)referenceDict
{
    NSString *path = [[NSBundle bundleForClass:[iGCS_Tests class]] pathForResource:filePrefix ofType:@"hex"];
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    // Check file length
    NSUInteger n = [content length];
    XCTAssertEqual(n, expectedLength, @"Incorrect file size (%u)", n);
    
    // Check we got the expected number of AddressDataPairs
    SiKFirmware* fw = [SiKFirmware firmwareFromString:content];
    NSArray *adPairs = fw.sortedAddressDataPairs;
    XCTAssertEqual(adPairs.count, referenceDict.count, @"Incorrect number of AddressDataPairs (%d)", adPairs.count);
    
    // Check the existence, length, and first byte of each pair compared to the reference
    for (AddressDataPair *adp in adPairs) {
        NSArray *tuple = [referenceDict objectForKey:[@(adp.address) stringValue]];
        XCTAssertNotNil(tuple, @"Did not find address %u in reference", adp.address);
        XCTAssertEqualObjects(@(adp.data.length), [tuple objectAtIndex:0], @"Non-matching lengths at address %u", adp.address);
        XCTAssertEqualObjects(@(((unsigned char*)adp.data.bytes)[0]), [tuple objectAtIndex:1], @"Non-matching first byte at address %u", adp.address);
    }
}

- (void)testSikFirmwareFromString {
    // Dictionary of address -> data [length, first byte] tuples, as extracted by reference implementation
    // (see testparser.py in iGCSTests/test-resources)
    NSDictionary *test1Reference = @{
                                     @"1024" : @[@6, @2],
                                     @"1035" : @[@1, @50],
                                     @"1043" : @[@1, @50],
                                     @"1051" : @[@1, @50],
                                     @"1059" : @[@3, @2],
                                     @"1067" : @[@3, @2],
                                     @"1075" : @[@1, @50],
                                     @"1083" : @[@1, @50],
                                     @"1091" : @[@1, @50],
                                     @"1099" : @[@1, @50],
                                     @"1107" : @[@1, @50],
                                     @"1115" : @[@1, @50],
                                     @"1123" : @[@1, @50],
                                     @"1131" : @[@1, @50],
                                     @"1139" : @[@42206, @2],
                                     @"63486" : @[@2, @61]
                                     };
    [self checkSiKFirmware:@"test1"
            expectedLength:116502
             referenceDict:test1Reference];
    
    [self checkSiKFirmware:@"test3"
            expectedLength:168512
             referenceDict:@{
                             @"1024" : @[@6, @2],
                             @"1035" : @[@1, @50],
                             @"1043" : @[@1, @50],
                             @"1051" : @[@1, @50],
                             @"1059" : @[@3, @2],
                             @"1067" : @[@3, @2],
                             @"1075" : @[@1, @50],
                             @"1083" : @[@1, @50],
                             @"1091" : @[@1, @50],
                             @"1099" : @[@1, @50],
                             @"1107" : @[@1, @50],
                             @"1115" : @[@1, @50],
                             @"1123" : @[@1, @50],
                             @"1131" : @[@1, @50],
                             @"1139" : @[@54891, @2],
                             @"63486" : @[@2, @61]
                             }];
}


@end

