//
//  MissionItemEditCell.h
//  iGCS
//
//  Created by Claudio Natoli on 5/11/2014.
//
//

#import <UIKit/UIKit.h>
#import "MissionItemField.h"

@interface MissionItemEditCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *label;
@property (nonatomic, weak) IBOutlet UITextField *text;
@property (nonatomic, weak) IBOutlet UILabel *units;

- (void) configureFor:(MissionItemField*)field withItem:(mavlink_mission_item_t)item;

@end
