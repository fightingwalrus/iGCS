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

@protocol MissionItemEditingDelegate
- (WaypointsHolder*) cloneMission;
- (mavlink_mission_item_t) getMissionItemAtIndex:(unsigned int)idx;
- (void) resetMission:(WaypointsHolder*) mission;
- (void) replaceMissionItem:(mavlink_mission_item_t)item atIndex:(unsigned int)idx;
@end

@interface WaypointsViewController : WaypointMapBaseController <MavLinkPacketHandler, MissionItemEditingDelegate> {
    WaypointsHolder *waypoints;
    
    UINavigationController* navVCEditItemVC;
}

- (WaypointsHolder*) getWaypointsHolder;  // for MissionItemEditViewController
- (void) resetWaypoints;

@property (nonatomic, retain) IBOutlet UIBarButtonItem *uploadButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *loadDemoButton;

@property (nonatomic, retain) IBOutlet UIBarButtonItem *addButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *editDoneButton;
@property (nonatomic, retain) IBOutlet UIView *containerForTableView;

- (IBAction)uploadClicked:  (id)sender;
- (IBAction)loadDemoMision: (id)sender;

- (IBAction)addClicked:(id)sender;
- (IBAction)editDoneClicked:(id)sender;

@end
