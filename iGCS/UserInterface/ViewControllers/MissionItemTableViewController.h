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
    WaypointsHolder* preEditMissionItems;
}

- (WaypointsViewController*) getWaypointsVC;
- (WaypointsHolder*) getWaypointsHolder;

- (void) replaceMissionItem:(mavlink_mission_item_t)missionItem atRow:(unsigned int)row;
- (void) resetMission:(WaypointsHolder*)originalMission;

@end