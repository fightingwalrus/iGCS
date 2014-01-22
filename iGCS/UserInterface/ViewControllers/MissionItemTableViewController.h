//
//  MissionItemTableViewController.h
//  iGCS
//
//  Created by Claudio Natoli on 4/05/13.
//
//

#import <UIKit/UIKit.h>
#import "WaypointsViewController.h"

@interface MissionItemTableViewController : UITableViewController

@property (nonatomic, retain) UIView *sectionHeaderContainer;
@property (nonatomic, retain) NSIndexPath *lastIndexPath;

- (void) markSelectedRow:(NSInteger)idx;
- (bool) toggleEditing;
- (void) resetWaypoints;

@end
