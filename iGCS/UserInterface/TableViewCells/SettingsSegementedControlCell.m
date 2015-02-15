//
//  SettingsLabelCell.m
//  iGCS
//
//  Created by David Leskowicz on 2/13/15.
//
//

#import "SettingsSegementedControlCell.h"
#import "PureLayout.h"
#import "SettingsData.h"

@implementation SettingsSegementedControlCell

@synthesize customSegementedControl;


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        NSArray *itemArray =  @[@"Standard", @"Metric"];
        self.customSegementedControl = [[UISegmentedControl newAutoLayoutView] initWithItems:itemArray];
        self.customSegementedControl.selectedSegmentIndex = [SettingsData sharedSettingsData].unitType;
        [self.contentView addSubview:self.customSegementedControl];
        [self.customSegementedControl autoSetDimension:ALDimensionWidth toSize:150.0f];
        [self.customSegementedControl autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10.0];
        [self.customSegementedControl autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.contentView];
        [self.customSegementedControl addTarget:self action:@selector(segementedControlChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return self;
}


- (void) segementedControlChanged:(UISegmentedControl *)segment {
    if (segment.selectedSegmentIndex == standard) {
        [SettingsData sharedSettingsData].unitType = standard;
    }
    else {
        [SettingsData sharedSettingsData].unitType = metric;
    }
    
    [[SettingsData sharedSettingsData] save];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
