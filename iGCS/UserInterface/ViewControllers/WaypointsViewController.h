//
//  WaypointsViewController.h
//  iGCS
//
//  Created by Claudio Natoli on 18/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WaypointMapBaseController.h"

#import "MavLinkPacketHandler.h"
#import "WaypointsHolder.h"

#define TABLE_MAP_SLIDE_AMOUNT 100

@interface WaypointsViewController : WaypointMapBaseController <MavLinkPacketHandler, UITableViewDelegate, UITableViewDataSource> {
    WaypointsHolder *waypoints;
    
    UIView *pushedDetailView;
}

- (void) resetWaypoints:(WaypointsHolder*)_waypoints;

@property (nonatomic, retain) IBOutlet UITableView *tableView;

@property (nonatomic, retain) IBOutlet UIBarButtonItem *detailBackButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *editDoneButton;

- (IBAction)detailBackClicked:(id)sender;
- (IBAction)editDoneClicked:(id)sender;

@end
