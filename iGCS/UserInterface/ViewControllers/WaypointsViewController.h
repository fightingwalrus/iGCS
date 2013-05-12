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

@interface WaypointsViewController : WaypointMapBaseController <MavLinkPacketHandler> {
    WaypointsHolder *waypoints;
    
    UINavigationController* navVCEditItemVC;
}

- (WaypointsHolder*) getWaypointsHolder;  // for MissionItemEditViewController
- (void) resetWaypoints;
- (void) resetWaypoints:(WaypointsHolder*)_waypoints;

@property (nonatomic, retain) IBOutlet UIBarButtonItem *editDoneButton;
@property (nonatomic, retain) IBOutlet UIView *editVCContainerView;

- (IBAction)editDoneClicked:(id)sender;

@end
