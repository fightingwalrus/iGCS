//
//  MissionItemTableViewController.h
//  iGCS
//
//  Created by Claudio Natoli on 4/05/13.
//
//

#import <UIKit/UIKit.h>
#import "WaypointsViewController.h"

#define DEBUG_SHOW_SEQ 0

@interface HeaderSpec : NSObject
@property (nonatomic, assign) NSInteger width;
@property (nonatomic, assign) NSTextAlignment align;
@property (nonatomic, retain) NSString *text;
@property (nonatomic, assign) NSInteger tag;
@end


@interface MissionItemTableViewController : UITableViewController

@property (nonatomic, readonly) BOOL toggleEditing;

- (void) markSelectedRow:(NSInteger)idx;
- (void) refreshTableView;

+ (NSDictionary*) paramEnumToLabelDictWith:(uint16_t)command;

@end
