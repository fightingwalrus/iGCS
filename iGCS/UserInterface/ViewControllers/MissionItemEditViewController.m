//
//  MissionItemEditViewController.m
//  iGCS
//
//  Created by Claudio Natoli on 4/05/13.
//
//

#import "MissionItemEditViewController.h"

#import "WaypointHelper.h"
#import "MavLinkUtility.h"

#import "MissionItemEditCell.h"


@interface MissionItemEditViewController ()
@property (weak, readonly) id <MissionItemEditingDelegate> delegate;
@property (nonatomic, readonly) NSUInteger itemIndex;
@property (nonatomic, assign) BOOL saveEdits;
@property (nonatomic, strong) WaypointsHolder *originalMission;

@property (nonatomic, strong) NSArray *missionItemCommandIDs;
@end


@implementation MissionItemEditViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) initInstance:(NSUInteger)itemIndex with:(id <MissionItemEditingDelegate>)delegate {
    _delegate = delegate;
    _itemIndex = itemIndex;
    _saveEdits = NO;

    // Clone the original mission
    _originalMission = [delegate cloneMission];
}

- (void)viewWillAppear:(BOOL)animated {
    // Hide the nav bar in the (contained) table view, but show it in the detail view
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    // Hide the nav bar in the (contained) table view, but show it in the detail view
    [self.navigationController setNavigationBarHidden:YES animated:YES];

    // Force any in-progress textfield to kick off textFieldDidEndEditing and friends
    [self.view.window endEditing: YES];
    if (!self.saveEdits) {
        [self.delegate replaceMission:self.originalMission];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Get the sorted list of all commands IDs for use in indexing the picker view
    self.missionItemCommandIDs = [MavLinkUtility supportedMissionItemTypes];

    [self setTitle:[NSString stringWithFormat:@"Mission Item #%lu", (unsigned long)self.itemIndex]];
    [self refreshWithMissionItem];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.missionItemCommandIDs count];
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [WaypointHelper commandIDToString: ((NSNumber*)self.missionItemCommandIDs[row]).intValue];
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    DDLogDebug(@"Selected Mission Item: %@ at index %ld", self.missionItemCommandIDs[row], (long)row);
    
    // Force any in-progress textfield to kick off textFieldDidEndEditing and friends
    [self.view.window endEditing: YES];
    
    // Change the command of the currently edited mission item
    mavlink_mission_item_t missionItem = [self getCurrentMissionItem];
    missionItem.command = [((NSNumber*)self.missionItemCommandIDs[row]) unsignedIntValue];
    [self.delegate replaceMissionItem:missionItem atIndex:self.itemIndex];
    [self.itemDetails reloadData];
}

- (void) refreshWithMissionItem {
    // Check that we have a supported mission item 
    NSInteger row = -1;
    for (NSUInteger i = 0; i < [self.missionItemCommandIDs count]; i++) {
        uint16_t commandID = ((NSNumber*)self.missionItemCommandIDs[i]).intValue;
        if (commandID == [self getCurrentMissionItem].command) {
            row = i;
            break;
        }
    }
    
    if (row == -1) {
        // FIXME: IGCS-13 think about how to handle unsupported row?
        //  - raw input of all fields?
        //  - perhaps refuse to even permit editing such rows?
        return;
    }
    
    // Set the corresponding picker view row, and refresh the table view
    [self.pickerView selectRow:row inComponent:0 animated:NO];
    [self.itemDetails reloadData];
}

- (mavlink_mission_item_t)getCurrentMissionItem {
    return [self.delegate getMissionItemAtIndex:self.itemIndex];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[MavLinkUtility missionItemMetadataWith: [self getCurrentMissionItem].command] count];
}

- (UITableViewCell *)tableView: (UITableView *)tableView cellForRowAtIndexPath: (NSIndexPath *)indexPath {
    mavlink_mission_item_t item = [self getCurrentMissionItem];
    MissionItemField *field = (MissionItemField*)[MavLinkUtility missionItemMetadataWith: item.command][indexPath.row];
    MissionItemEditCell *cell = [self.itemDetails dequeueReusableCellWithIdentifier:@"MissionItemEditCell"];
    [cell configureFor:field withItem:item];
    return cell;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    // Traverse up the view hierarchy until the parent UITableViewCell is reached
    //
    // FIXME: is there a nicer way to do this? (without for instance, using a tag on textfield)
    UIView *cell = textField;
    while (cell && ![cell isKindOfClass:[UITableViewCell class]]) {
        cell = [cell superview];
    }
    NSIndexPath *indexPath = [self.itemDetails indexPathForCell:(UITableViewCell*)cell];
    assert(indexPath != NULL);
    DDLogDebug(@"textFieldDidEndEditing - tag: %ld, indexPath.row = %ld", (long)textField.tag, (long)indexPath.row);

    mavlink_mission_item_t item = [self getCurrentMissionItem];
    MissionItemField *field = (MissionItemField*)[MavLinkUtility missionItemMetadataWith: item.command][indexPath.row];

    // Modify the respective field in the item
    [field setValue:[textField.text floatValue] inMissionItem:&item];

    [self.delegate replaceMissionItem:item atIndex:self.itemIndex];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

// Limit textfields to numeric values only
// ref: http://stackoverflow.com/questions/9344159/validate-numeric-input-to-uitextfield-as-the-user-enters-input
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSString *expression = @"^(-)?([0-9]+)?(\\.([0-9]*)?)?$";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:nil];
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:newString
                                                        options:0
                                                          range:NSMakeRange(0, [newString length])];
    return (numberOfMatches != 0);
}

- (IBAction)cancelButtonClicked:(id)sender {
    self.saveEdits = NO;
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)saveButtonClicked:(id)sender {
    self.saveEdits = YES;
    [self.navigationController popViewControllerAnimated:YES];
}

@end
