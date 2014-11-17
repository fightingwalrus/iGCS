//
//  MissionItemCell.m
//  iGCS
//
//  Created by Claudio Natoli on 5/11/2014.
//
//

#import "MissionItemCell.h"
#import "MissionItemField.h"
#import "MissionItemTableViewController.h"
#import "MiscUtilities.h"

#define TABLE_CELL_FONT_SIZE        12
#define TABLE_CELL_CMD_FONT_SIZE    16

@interface MissionItemCell ()
@property (nonatomic, strong) UILabel* rowNum;
#if DEBUG_SHOW_SEQ
@property (nonatomic, strong) UILabel* seq;
#endif
@property (nonatomic, strong) UILabel* command;
@property (nonatomic, strong) UILabel* x;
@property (nonatomic, strong) UILabel* y;
@property (nonatomic, strong) UILabel* z;
@property (nonatomic, strong) UILabel* param1;
@property (nonatomic, strong) UILabel* param2;
@property (nonatomic, strong) UILabel* param3;
@property (nonatomic, strong) UILabel* param4;
@property (nonatomic, strong) UILabel* autocontinue;
@end


@implementation MissionItemCell

- (void) awakeFromNib {
}

- (void) setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (UILabel*) addLabelSubView:(NSInteger)x width:(NSInteger)width alignment:(NSTextAlignment)alignment {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x, 0, width, 44)];
    label.font = [UIFont systemFontOfSize:TABLE_CELL_FONT_SIZE];
    label.textAlignment = alignment;
    label.textColor = [UIColor blackColor];
    label.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
    [self.contentView addSubview:label];
    return label;
}

- (UILabel*) addLabelSubView:(NSInteger)x width:(NSInteger)width {
    return [self addLabelSubView:x width:width alignment:NSTextAlignmentRight];
}

- (void) initializeLabels:(NSArray*)widths {
    NSUInteger x = 0;
    NSUInteger width = 0;
    NSUInteger i = 0;
    
    x += width;
    width = [[widths objectAtIndex:i++] unsignedIntegerValue];
    self.rowNum = [self addLabelSubView:x width:width alignment:NSTextAlignmentLeft];
    
#if DEBUG_SHOW_SEQ
    x += width;
    width = [[widths objectAtIndex:i++] unsignedIntegerValue];
    self.seq = [self addLabelSubView:x width:width alignment:NSTextAlignmentLeft];
#endif
    x += width;
    width = [[widths objectAtIndex:i++] unsignedIntegerValue];
    self.command = [self addLabelSubView:x width:width alignment:NSTextAlignmentLeft];
    self.command.font = [UIFont systemFontOfSize:TABLE_CELL_CMD_FONT_SIZE];
    
    x += width;
    width = [[widths objectAtIndex:i++] unsignedIntegerValue];
    self.x = [self addLabelSubView:x width:width];
    
    x += width;
    width = [[widths objectAtIndex:i++] unsignedIntegerValue];
    self.y = [self addLabelSubView:x width:width];
    
    x += width;
    width = [[widths objectAtIndex:i++] unsignedIntegerValue];
    self.z = [self addLabelSubView:x width:width];
    
    x += width;
    width = [[widths objectAtIndex:i++] unsignedIntegerValue];
    self.param1 = [self addLabelSubView:x width:width];
    
    x += width;
    width = [[widths objectAtIndex:i++] unsignedIntegerValue];
    self.param2 = [self addLabelSubView:x width:width];
    
    x += width;
    width = [[widths objectAtIndex:i++] unsignedIntegerValue];
    self.param3 = [self addLabelSubView:x width:width];
    
    x += width;
    width = [[widths objectAtIndex:i++] unsignedIntegerValue];
    self.param4 = [self addLabelSubView:x width:width];
    
    x += width;
    width = [[widths objectAtIndex:i++] unsignedIntegerValue];
    self.autocontinue = [self addLabelSubView:x width:width alignment:NSTextAlignmentCenter];
}


+ (NSString*) formatParam:(float)param {
    return param == 0 ? @"0" : [NSString stringWithFormat:@"%0.2f", param];
}

- (void) configureFor:(NSInteger)rowNum withItem:(mavlink_mission_item_t)item {
    BOOL isNavCommand = [WaypointHelper isNavCommand:item];
    
    // Row number (which masquerades as the seq #)
    self.rowNum.text = [NSString stringWithFormat:@"%4ld:", (long)rowNum];
    
#if DEBUG_SHOW_SEQ
    // Seq number
    self.seq.text = [NSString stringWithFormat:@"%d:", item.seq];
#endif
    
    // Command
    self.command.text = [NSString stringWithFormat:@"%@", [WaypointHelper commandIDToString: item.command]];
    
    // Latitude
    self.x.text = isNavCommand ? [MiscUtilities prettyPrintCoordAxis:item.x as:GCSLatitude] : @"-";
    
    // Longitude
    self.y.text = isNavCommand ? [MiscUtilities prettyPrintCoordAxis:item.y as:GCSLongitude] : @"-";
    
    // Altitude
    self.z.text = isNavCommand ? [NSString stringWithFormat:@"%0.2f m", item.z] : @"-";
    
    // Used to determine whether we have a named header for the respective param
    NSDictionary *dict = [MissionItemTableViewController paramEnumToLabelDictWith: item.command];
    self.param1.text = (dict && dict[@(GCSItemParam1)]) ? [MissionItemCell formatParam:item.param1] : @"-";
    self.param2.text = (dict && dict[@(GCSItemParam2)]) ? [MissionItemCell formatParam:item.param2] : @"-";
    self.param3.text = (dict && dict[@(GCSItemParam3)]) ? [MissionItemCell formatParam:item.param3] : @"-";
    self.param4.text = (dict && dict[@(GCSItemParam4)]) ? [MissionItemCell formatParam:item.param4] : @"-";
    
    // autocontinue
    self.autocontinue.text = [NSString stringWithFormat:@"%@", item.autocontinue ? @"Yes" : @"No"];
}

@end
