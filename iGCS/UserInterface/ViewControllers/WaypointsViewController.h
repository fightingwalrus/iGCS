//
//  WaypointsViewController.h
//  iGCS
//
//  Created by Claudio Natoli on 18/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WaypointMapBaseController.h"
#import "WaypointsHolder.h"

#define TABLE_MAP_SLIDE_AMOUNT 100
#define WAYPOINT_DEFAULT_ALTITUDE 10

@protocol MissionItemEditingDelegate
- (WaypointsHolder*) cloneMission;
- (mavlink_mission_item_t) getMissionItemAtIndex:(unsigned int)idx;
- (void) resetMission:(WaypointsHolder*) mission;
- (void) replaceMissionItem:(mavlink_mission_item_t)item atIndex:(unsigned int)idx;
@end

@interface WaypointsViewController : WaypointMapBaseController <MavLinkPacketHandler, MissionItemEditingDelegate> {    
    UINavigationController* _navVCEditItemVC;
}

@property (nonatomic, readonly, strong) WaypointsHolder *waypoints;  // for MissionItemEditViewController
- (void) resetWaypoints;

@property (nonatomic, retain) IBOutlet UIBarButtonItem *carrierPadding;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *batteryPadding;

@property (nonatomic, retain) IBOutlet UIBarButtonItem *rxMissionButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *txMissionButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *loadDemoButton;

@property (nonatomic, retain) IBOutlet UIBarButtonItem *addButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *editDoneButton;
@property (nonatomic, retain) IBOutlet UIView *containerForTableView;

- (IBAction)mavRxMissionClicked: (id)sender;
- (IBAction)mavTxMissionClicked: (id)sender;

- (IBAction)loadDemoMision: (id)sender;

- (IBAction)addClicked:(id)sender;
- (IBAction)editDoneClicked:(id)sender;

@end
