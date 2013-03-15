//
//  WaypointsViewController.h
//  iGCS
//
//  Created by Claudio Natoli on 18/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MavLinkPacketHandler.h"
#import "WaypointsHolder.h"

@interface WaypointsViewController : UIViewController <MavLinkPacketHandler, UITableViewDelegate, UITableViewDataSource> {
    WaypointsHolder *waypoints;
}

- (void) updateWaypoints:(WaypointsHolder*)_waypoints;

@property (nonatomic, retain) IBOutlet UITableView *tableView;

@end
