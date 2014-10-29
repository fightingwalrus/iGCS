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
    NSArray *_missionItemCommandIDs;
    
    WaypointsHolder *_originalMission;

    BOOL _saveEdits;
}

- (void) initInstance:(NSUInteger)missionItemRow with:(id <MissionItemEditingDelegate>)delegate;

- (IBAction)cancelButtonClicked:(id)sender;
- (IBAction)saveButtonClicked:(id)sender;

@property (nonatomic, retain) IBOutlet UITableView *itemDetails;
@property (nonatomic, retain) IBOutlet UIPickerView *pickerView;

@property (nonatomic, readonly) NSUInteger itemIndex;
@property (weak, readonly) id <MissionItemEditingDelegate> delegate;

@end