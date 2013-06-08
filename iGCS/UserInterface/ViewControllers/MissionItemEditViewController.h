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
    
    MissionItemTableViewController *missionTableVC; // FIXME: cut out the middle man, and replace with delegate interface direct to WaypointsViewController
    
    WaypointsHolder *originalMission;

    unsigned int missionItemRow;
    BOOL saveEdits;
}

- (void) initInstance:(unsigned int)_missionItemRow withTableVC:(MissionItemTableViewController*)_parentTableVC;

- (IBAction)cancelButtonClicked:(id)sender;
- (IBAction)saveButtonClicked:(id)sender;

@property (nonatomic, retain) IBOutlet UITableView *tableView;

@end