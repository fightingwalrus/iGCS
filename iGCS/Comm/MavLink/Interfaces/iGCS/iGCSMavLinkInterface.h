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

@interface iGCSMavLinkInterface : MavLinkInterface

@property (strong) MainViewController *mainVC;
@property unsigned int heartbeatOnlyCount;
@property BOOL mavLinkInitialized;

@property (nonatomic, retain) MavLinkLogger *mavlinkLogger;

+(iGCSMavLinkInterface*)createWithViewController:(MainViewController*)mainVC;

- (void) startReadMissionRequest;
- (void) issueRawMissionRequestList;
- (void) issueRawMissionRequest:(uint16_t)sequence;
- (void) issueRawMissionAck;
- (void) loadNewMission:(WaypointsHolder*)mission;

- (void) startWriteMissionRequest:(WaypointsHolder*)waypoints;
- (void) issueRawMissionCount:(uint16_t)numItems;
- (void) issueRawMissionItem:(mavlink_mission_item_t)item;

- (void) startSetWaypointRequest:(uint16_t)sequence;
- (void) issueRawSetWaypointCommand:(uint16_t)sequence;

- (void) issueGOTOCommand:(CLLocationCoordinate2D)coordinates withAltitude:(float)altitude;
- (void) issueSetAUTOModeCommand;

- (void) loadDemoMission;

@end
