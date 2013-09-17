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

@property (nonatomic, retain) UIView *sectionHeader;
@property (nonatomic, retain) NSIndexPath *lastIndexPath;

@end