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

#define iGCS_MAVLINK_RETRANSMISSION_TIMEOUT 0.5 // seconds
#define iGCS_MAVLINK_MAX_RETRIES 5

@interface iGCSMavLinkInterface : MavLinkInterface

@property (strong) MainViewController *mainVC;
@property unsigned int heartbeatOnlyCount;
@property BOOL mavLinkInitialized;
@property (strong) WaypointsHolder *rxWaypoints;
@property (strong) WaypointsHolder *txWaypoints;

@property (nonatomic, readonly) unsigned int mavlinkRequestAttempts;
@property (nonatomic, retain) UIAlertView* mavlinkTransactionProgressDialog;
@property (nonatomic, retain) MavLinkLogger *mavlinkLogger;

+(iGCSMavLinkInterface*)createWithViewController:(MainViewController*)mainVC;

- (void) issueStartReadMissionRequest;
- (void) issueStartWriteMissionRequest:(WaypointsHolder*)waypoints;

- (void) issueGOTOCommand:(CLLocationCoordinate2D)coordinates withAltitude:(float)altitude;
- (void) issueSetAUTOModeCommand;


- (void) loadDemoMission;

@end
