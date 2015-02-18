//
//  SettingsCustomTableViewCell.m
//  iGCS
//
//  Created by David Leskowicz on 2/12/15.
//
//

#import "SettingsWaypointCell.h"
#import "PureLayout.h"
#import "GCSSettings.h"


@implementation SettingsWaypointCell

@synthesize customTextField, customLabel;


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Custom initialization

        self.customLabel = [UILabel newAutoLayoutView];
        [self.contentView addSubview:self.customLabel];
        self.customLabel.textAlignment = NSTextAlignmentCenter;
        [self.customLabel autoSetDimension:ALDimensionWidth toSize:75.0f];
        [self.customLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10.0];
        [self.customLabel autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.contentView];
        
        self.customTextField = [UITextField newAutoLayoutView];
        [self.contentView addSubview:self.customTextField];
        self.customTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        self.customTextField.textAlignment = NSTextAlignmentCenter;
        self.customTextField.borderStyle = UITextBorderStyleRoundedRect;
        [self.customTextField autoSetDimension:ALDimensionWidth toSize:75.0f];
        [self.self.customTextField autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:self.customLabel withOffset:0];
        [self.customTextField autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.contentView];
      }
    
    return self;
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
