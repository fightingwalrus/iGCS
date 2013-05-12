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
#import "MissionItemTableViewController.h"

@interface MissionItemEditViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDataSource, UITableViewDataSource, UITextFieldDelegate> {
    IBOutlet UIPickerView *pickerView;
    
    NSArray *missionItemCommandIDs;
    NSMutableDictionary *missionItemMetaData;
    
    mavlink_mission_item_t missionItem;
    BOOL saveEdits;

    MissionItemTableViewController *tableVC;
    
}

- (void) initInstance:(mavlink_mission_item_t)_missionItem withTableVC:(MissionItemTableViewController*)_tableVC;

- (IBAction)cancelButtonClicked:(id)sender;
- (IBAction)saveButtonClicked:(id)sender;

@property (nonatomic, retain) IBOutlet UITableView *tableView;

@end