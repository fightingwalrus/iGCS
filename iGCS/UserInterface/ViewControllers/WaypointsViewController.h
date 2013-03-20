//
//  WaypointsViewController.h
//  iGCS
//
//  Created by Claudio Natoli on 18/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MKMapView.h>

#import "MavLinkPacketHandler.h"
#import "WaypointsHolder.h"

#define TABLE_MAP_SLIDE_AMOUNT 200

@interface WaypointsViewController : UIViewController <MavLinkPacketHandler, UITableViewDelegate, UITableViewDataSource> {
    WaypointsHolder *waypoints;
}

- (void) updateWaypoints:(WaypointsHolder*)_waypoints;

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) IBOutlet UITableView *tableView;

@property (nonatomic, retain) IBOutlet UIBarButtonItem *editDoneButton;
- (IBAction)editDoneClicked:(id)sender;

@end
