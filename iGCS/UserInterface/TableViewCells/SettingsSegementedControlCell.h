//
//  SettingsLabelCell.h
//  iGCS
//
//  Created by David Leskowicz on 2/13/15.
//
//

#import <UIKit/UIKit.h>

@interface SettingsSegementedControlCell : UITableViewCell

@property (nonatomic, retain) UISegmentedControl *customSegementedControl;
@property (nonatomic, weak) UITableView *tableView;

@end


