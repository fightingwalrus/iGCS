//
//  iGCSMavLinkInterface.h
//  iGCS
//
//  Created by Andrew Aarestad on 2/22/13.
//
//

#import <Foundation/Foundation.h>
#import "CommInterface.h"
#import "MainViewController.h"
#import "MavLinkLogger.h"
#import "WaypointsHolder.h"

@interface iGCSMavLinkInterface : CommInterface


@property (strong) MainViewController *mainVC;
@property unsigned int heartbeatOnlyCount;
@property BOOL mavLinkInitialized;

@property (nonatomic, retain) MavLinkLogger *mavlinkLogger;
@property (nonatomic, retain) NSTimer* heartbeatTimer;

+(iGCSMavLinkInterface*)createWithViewController:(MainViewController*)mainVC;

- (void) startReadMissionRequest;
- (void) completedReadMissionRequest:(WaypointsHolder*)mission;
- (void) issueRawMissionRequestList;
- (void) issueRawMissionRequest:(uint16_t)sequence;
- (void) stopRecevingMessages;

- (void) startWriteMissionRequest:(WaypointsHolder*)mission;
- (void) completedWriteMissionRequestSuccessfully:(BOOL)success withMission:(WaypointsHolder*)mission;
- (void) issueRawMissionCount:(uint16_t)numItems;
- (void) issueRawMissionItem:(mavlink_mission_item_t)item;
- (void) issueRawMissionClearAll;

- (void) startSetWaypointRequest:(uint16_t)sequence;
- (void) issueRawSetWaypointCommand:(uint16_t)sequence;

- (void) issueGOTOCommand:(CLLocationCoordinate2D)coordinates withAltitude:(float)altitude;
- (void) issueSetAUTOModeCommand;

- (void) loadDemoMission;
-(void) sendHeatbeatToAutopilot;

- (void) sendMavlinkTakeOffCommand;
- (void) sendArdroneLand;
- (void) sendArdroneRtl;
- (void) sendArdronePairSpektrumDSMX;

#pragma mark - ArDrone AT commands;
- (void) sendAtCommandToTakeOff;
- (void) sendAtCommandToLand;
- (void) sendAtCommandCalibrateHorizontalPlane;
- (void) sendAtCommandCalibrateMagnetometer;
- (void) sendAtCommandToggleEmergency;
- (void) sendAtCommandResetWatchDogTimer;
- (void) sendAtCommandPhiM30;
- (void) sendAtCommandPhi30;
- (void) sendAtCommandThetaM30;
- (void) sendAtCommandTheta30;
- (void) sendAtCommandTheta20degYaw200;
- (void) sendAtCommandTheta20degYawM200;
- (void) sendAtCommandTurnAround;
- (void) sendAtCommandTurnAroundGoDown;
- (void) sendAtCommandYawShake;
- (void) sendAtCommandYawDance;
- (void) sendAtCommandPhiDance;
- (void) sendAtCommandThetaDance;
- (void) sendAtCommandVzDance;
- (void) sendAtCommandWave;
- (void) sendAtCommandPhiThetaMixed;
- (void) sendAtCommandFlipAhead;
- (void) sendAtCommandFlipBehind;
- (void) sendAtCommandFlipLeft;
- (void) sendAtCommandFlipRight;

@end
