//
//  MissionItemEditViewController.h
//  iGCS
//
//  Created by Claudio Natoli on 4/05/13.
//
//

#import <UIKit/UIKit.h>
#import "WaypointsHolder.h"
#import "MissionItemField.h"

@interface MissionItemEditViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDataSource, UITableViewDataSource> {
    IBOutlet UIPickerView *pickerView;
    
    NSArray *missionItemCommandIDs;
    NSMutableDictionary *missionItemMetaData;
    
    mavlink_mission_item_t missionItem;
    
    UITabBarController* tabVCDetailItemVC;
}

- (void) initInstance:(mavlink_mission_item_t)_missionItem;

@property (nonatomic, retain) IBOutlet UITableView *tableView;

@end