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
#import "WaypointsViewController.h"

@interface MissionItemEditViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDataSource, UITableViewDataSource, UITextFieldDelegate> {
    IBOutlet UIPickerView *pickerView;
    
    NSArray *missionItemCommandIDs;
    NSMutableDictionary *missionItemMetaData;
        
    WaypointsHolder *originalMission;

    unsigned int itemIndex;
    BOOL saveEdits;
}

- (void) initInstance:(unsigned int)_missionItemRow with:(id <MissionItemEditingDelegate>)_delegate;

- (IBAction)cancelButtonClicked:(id)sender;
- (IBAction)saveButtonClicked:(id)sender;

@property (nonatomic, retain) IBOutlet UITableView *itemDetails;
@property (weak, readonly) id <MissionItemEditingDelegate> delegate;

@end