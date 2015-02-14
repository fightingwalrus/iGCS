//
//  SettingsLabelCell.m
//  iGCS
//
//  Created by David Leskowicz on 2/13/15.
//
//

#import "SettingsLabelCell.h"
#import "PureLayout.h"

@implementation SettingsLabelCell

@synthesize customLabel;


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Custom initialization
        customLabel = [[UILabel alloc] initWithFrame:CGRectMake(30,5,165,30)];
        customLabel.font = [UIFont systemFontOfSize:14.0];
        customLabel.textColor = [UIColor blueColor];
        customLabel.backgroundColor = [UIColor clearColor];
        customLabel.highlightedTextColor = [UIColor whiteColor];
        [self.contentView addSubview:customLabel];
        
    }
    return self;
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
