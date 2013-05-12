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
    
    MissionItemTableViewController *missionTableVC;
    
    mavlink_mission_item_t originalMissionItem;
    unsigned int missionItemRow;
    BOOL saveEdits;
}

- (void) initInstance:(unsigned int)_missionItemRow withTableVC:(MissionItemTableViewController*)_parentTableVC;

- (IBAction)cancelButtonClicked:(id)sender;
- (IBAction)saveButtonClicked:(id)sender;

@property (nonatomic, retain) IBOutlet UITableView *tableView;

@end