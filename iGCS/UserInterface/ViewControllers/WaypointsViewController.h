//
//  WaypointsViewController.h
//  iGCS
//
//  Created by Claudio Natoli on 18/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WaypointMapBaseController.h"
#import "WaypointsHolder.h"

#define WAYPOINT_DEFAULT_ALTITUDE 25

@protocol MissionItemEditingDelegate
- (WaypointsHolder*) cloneMission;
- (mavlink_mission_item_t) getMissionItemAtIndex:(NSUInteger)idx;
- (void) replaceMission:(WaypointsHolder*) mission;
- (void) replaceMissionItem:(mavlink_mission_item_t)item atIndex:(NSUInteger)idx;
@end

@interface WaypointsViewController : WaypointMapBaseController <MavLinkPacketHandler, MissionItemEditingDelegate>

@property (nonatomic, readonly, strong) WaypointsHolder *waypoints;  // for MissionItemEditViewController

@property (nonatomic, retain) IBOutlet UIBarButtonItem *carrierPadding;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *batteryPadding;

@property (nonatomic, retain) IBOutlet UIBarButtonItem *rxMissionButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *txMissionButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *loadDemoButton;

@property (nonatomic, retain) IBOutlet UIBarButtonItem *addButton;
@property (nonatomic, retain) IBOutlet UIView *containerForTableView;

- (IBAction)mavRxMissionClicked: (id)sender;
- (IBAction)mavTxMissionClicked: (id)sender;

- (IBAction)loadDemoMision: (id)sender;

- (IBAction)addClicked:(id)sender;

- (void) resetWaypoints;

@end
