//
//  MissionItemCell.h
//  iGCS
//
//  Created by Claudio Natoli on 5/11/2014.
//
//

#import <UIKit/UIKit.h>
#import "WaypointHelper.h"

@interface MissionItemCell : UITableViewCell

- (void) initializeLabels:(NSArray*)widths;
- (void) configureFor:(NSInteger)rowNum withItem:(mavlink_mission_item_t)item;

@end
