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
@property NSUInteger heartbeatOnlyCount;
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
- (void) sendLand;
- (void) sendReturnToLaunch;
- (void) sendPairSpektrumDSMX;
- (void) sendMoveCommand:(int16_t)pitch :(int16_t)roll :(int16_t)thrust :(int16_t)yaw :(uint16_t)sequenceNumber;

#pragma mark - ArDrone AT commands;
- (void) arDroneTakeOff;
- (void) arDroneLand;
- (void) arDroneCalibrateHorizontalPlane;
- (void) arDroneCalibrateMagnetometer;
- (void) arDroneToggleEmergency;
- (void) arDroneResetWatchDogTimer;
- (void) arDronePhiM30;
- (void) arDronePhi30;
- (void) arDroneThetaM30;
- (void) arDroneTheta30;
- (void) arDroneTheta20degYaw200;
- (void) arDroneTheta20degYawM200;
- (void) arDroneTurnAround;
- (void) arDroneTurnAroundGoDown;
- (void) arDroneYawShake;
- (void) arDroneYawDance;
- (void) arDronePhiDance;
- (void) arDroneThetaDance;
- (void) arDroneVzDance;
- (void) arDroneWave;
- (void) arDronePhiThetaMixed;
- (void) arDroneFlipAhead;
- (void) arDroneFlipBehind;
- (void) arDroneFlipLeft;
- (void) arDroneFlipRight;


@end
