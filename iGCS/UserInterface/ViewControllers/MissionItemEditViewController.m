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
        [self.delegate resetMission:self.originalMission];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Get the sorted list of all commands IDs for use in indexing the picker view
    self.missionItemCommandIDs = [MavLinkUtility supportedMissionItemTypes];

    [self setTitle:[NSString stringWithFormat:@"Mission Item #%d", self.itemIndex]];
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
    DDLogDebug(@"Selected Mission Item: %@ at index %i", self.missionItemCommandIDs[row], row);
    
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
    UITableViewCell *cell = [self.itemDetails dequeueReusableCellWithIdentifier:@"missionItemCell"];
    
    // Note: see prototype cell for magic #'s
    UILabel *label    = (UILabel *)    [cell viewWithTag:100];
    UITextField *text = (UITextField *)[cell viewWithTag:200];
    UILabel *units    = (UILabel *)    [cell viewWithTag:300];
    
    [label setText:[field label]];
    [text  setText:[field valueToString:item]];
    [text setClearButtonMode:UITextFieldViewModeWhileEditing];
    [units setText:[field unitsToString]];
    return cell;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    // Traverse up the view hierarchy until the parent UITableViewCell is reached
    //
    // FIXME: is there a nicer way to do this? (without for instance, using a tag on textfield, which we're already
    // using for another purpose; namely, using viewWithTag to find/configure the cell from the storyboard prototype)
    UIView *cell = textField;
    while (cell && ![cell isKindOfClass:[UITableViewCell class]]) {
        cell = [cell superview];
    }
    NSIndexPath *indexPath = [self.itemDetails indexPathForCell:(UITableViewCell*)cell];
    assert(indexPath != NULL);
    DDLogDebug(@"textFieldDidEndEditing - tag: %d, indexPath.row = %d", textField.tag, indexPath.row);

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
    if (numberOfMatches == 0)
        return NO;
    return YES;
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
