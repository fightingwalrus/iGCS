//
//  MavUtilityTests.m
//  MavUtilityTests
//
//  Created by Claudio Natoli on 5/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "MavLinkUtility.h"
#import "GCSCraftModes.h"

@interface MavUtilityTests : XCTestCase

@end

@implementation MavUtilityTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
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

@end

