//
//  SettingsCustomTableViewCell.m
//  iGCS
//
//  Created by David Leskowicz on 2/12/15.
//
//

#import "SettingsCustomTableViewCell.h"


@implementation SettingsCustomTableViewCell

@synthesize customLabel, customTextField;

//- (void)awakeFromNib {
    // Initialization code
//}

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
        
        customTextField = [[UITextField alloc] initWithFrame:CGRectMake(300,5,100,30)];
        [self.contentView addSubview:customTextField];
        
      }
    return self;
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
