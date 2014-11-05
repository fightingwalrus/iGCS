//
//  MissionItemEditCell.m
//  iGCS
//
//  Created by Claudio Natoli on 5/11/2014.
//
//

#import "MissionItemEditCell.h"

@implementation MissionItemEditCell

- (void) awakeFromNib {
}

- (void) setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void) configureFor:(MissionItemField*)field withItem:(mavlink_mission_item_t)item {
    [self.label setText:[field label]];
    [self.text setText:[field valueToString:item]];
    [self.text setClearButtonMode:UITextFieldViewModeWhileEditing];
    [self.units setText:[field unitsToString]];
}

@end
