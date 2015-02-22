//
//  SettingsLabelCell.m
//  iGCS
//
//  Created by David Leskowicz on 2/13/15.
//
//

#import "SettingsSegementedControlCell.h"
#import "PureLayout.h"
#import "GCSSettings.h"
#import "GCSDataManager.h"

@implementation SettingsSegementedControlCell

@synthesize customSegementedControl;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        NSArray *itemArray =  @[@"Standard", @"Metric"];
        self.customSegementedControl = [[UISegmentedControl newAutoLayoutView] initWithItems:itemArray];
        self.customSegementedControl.selectedSegmentIndex = [GCSDataManager sharedInstance].gcsSettings.unitType;
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
        [GCSDataManager sharedInstance].gcsSettings.unitType = standard;
        [GCSDataManager sharedInstance].gcsSettings.altitude = [self metricToStandardlength:[GCSDataManager sharedInstance].gcsSettings.altitude];
        [GCSDataManager sharedInstance].gcsSettings.radius = [self metricToStandardlength:[GCSDataManager sharedInstance].gcsSettings.radius];
    } else {
        [GCSDataManager sharedInstance].gcsSettings.unitType = metric;
        [GCSDataManager sharedInstance].gcsSettings.altitude = [self standardToMetriclength:[GCSDataManager sharedInstance].gcsSettings.altitude];
        [GCSDataManager sharedInstance].gcsSettings.radius = [self standardToMetriclength:[GCSDataManager sharedInstance].gcsSettings.radius];
    }
    
    NSRange range = NSMakeRange(1, 1);
    NSIndexSet *sectionToReload = [NSIndexSet indexSetWithIndexesInRange:range];
    [self.tableView reloadSections:sectionToReload withRowAnimation:UITableViewRowAnimationAutomatic];
    [GCSDataManager save];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (double) metricToStandardlength:(double)value {
    return value * 3.2808;
}

- (double) standardToMetriclength:(double)value {
    return value / 3.2808;
}


@end
