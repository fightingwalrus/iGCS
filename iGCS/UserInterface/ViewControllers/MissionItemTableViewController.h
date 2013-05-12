//
//  MissionItemTableViewController.h
//  iGCS
//
//  Created by Claudio Natoli on 4/05/13.
//
//

#import <UIKit/UIKit.h>
#import "WaypointsViewController.h"

@interface MissionItemTableViewController : UITableViewController {
}

- (WaypointsViewController*) getWaypointsVC;
- (WaypointsHolder*) getWaypointsHolder;

- (void) detailViewModifiedMissionItem:(mavlink_mission_item_t)missionItem;

@end