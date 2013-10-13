//
//  iGCSMavLinkInterface.h
//  iGCS
//
//  Created by Andrew Aarestad on 2/22/13.
//
//

#import <Foundation/Foundation.h>
#import "MavLinkInterface.h"
#import "MainViewController.h"
#import "MavLinkLogger.h"
#import "WaypointsHolder.h"

#define iGCS_MAVLINK_MISSION_RXTX_RETRANSMISSION_TIMEOUT 0.5 // seconds
#define iGCS_MAVLINK_SET_WP_RETRANSMISSION_TIMEOUT       2.0 // seconds
#define iGCS_MAVLINK_MAX_RETRIES 5

@interface iGCSMavLinkInterface : MavLinkInterface

@property (strong) MainViewController *mainVC;
@property unsigned int heartbeatOnlyCount;
@property BOOL mavLinkInitialized;
@property (strong) WaypointsHolder *rxWaypoints;
@property (strong) WaypointsHolder *txWaypoints;

@property (nonatomic, readonly) NSUInteger mavlinkMissionRxTxAttempts;
@property (nonatomic, readonly) NSUInteger mavlinkSetWPRequestAttempts;

@property (nonatomic, retain) UIAlertView* mavlinkRequestStatusDialog;
@property (nonatomic, retain) MavLinkLogger *mavlinkLogger;

+(iGCSMavLinkInterface*)createWithViewController:(MainViewController*)mainVC;

- (void) issueStartReadMissionRequest;
- (void) issueStartWriteMissionRequest:(WaypointsHolder*)waypoints;

- (void) issueSetWPCommand:(uint16_t)sequence;
- (void) issueGOTOCommand:(CLLocationCoordinate2D)coordinates withAltitude:(float)altitude;
- (void) issueSetAUTOModeCommand;


- (void) loadDemoMission;

@end
