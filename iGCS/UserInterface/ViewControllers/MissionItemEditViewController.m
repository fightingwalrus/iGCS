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

@end


@implementation MissionItemEditViewController

@synthesize itemDetails;
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) initInstance:(unsigned int)_idx with:(id <MissionItemEditingDelegate>)_delegate  {
    delegate = _delegate;
    itemIndex = _idx;
    saveEdits = NO;

    // Clone the original mission
    originalMission = [delegate cloneMission];
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
    if (!saveEdits) {
        [delegate resetMission: originalMission];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Get the sorted list of all commands IDs for use in indexing the picker view
    missionItemCommandIDs = [MavLinkUtility supportedMissionItemTypes];

    [self setTitle:[NSString stringWithFormat:@"Mission Item #%d", itemIndex]];
    [self refreshWithMissionItem];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    return [missionItemCommandIDs count];
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [WaypointHelper commandIDToString: ((NSNumber*)[missionItemCommandIDs objectAtIndex:row]).intValue];
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    //NSLog(@"Selected Mission Item: %@ at index %i", [missionItemCommandIDs objectAtIndex:row], row);
    
    // Force any in-progress textfield to kick off textFieldDidEndEditing and friends
    [self.view.window endEditing: YES];
    
    // Change the command of the currently edited mission item
    mavlink_mission_item_t missionItem = [self getCurrentMissionItem];
    missionItem.command = [((NSNumber*)[missionItemCommandIDs objectAtIndex:row]) unsignedIntValue];
    [delegate replaceMissionItem:missionItem atIndex:itemIndex];
    [self.itemDetails reloadData];
}

- (void) refreshWithMissionItem {
    // Check that we have a supported mission item 
    int row = -1;
    for (unsigned int i = 0; i < [missionItemCommandIDs count]; i++) {
        uint16_t commandID = ((NSNumber*)[missionItemCommandIDs objectAtIndex:i]).intValue;
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
    [pickerView selectRow:row inComponent:0 animated:NO];
    [self.itemDetails reloadData];
}

- (mavlink_mission_item_t)getCurrentMissionItem {
    return [delegate getMissionItemAtIndex:itemIndex];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section {
    return [[MavLinkUtility missionItemMetadataWith: [self getCurrentMissionItem].command] count];
}

- (UITableViewCell *)tableView: (UITableView *)_tableView cellForRowAtIndexPath: (NSIndexPath *)indexPath
{
    mavlink_mission_item_t item = [self getCurrentMissionItem];
    MissionItemField *field = (MissionItemField*)[[MavLinkUtility missionItemMetadataWith: item.command] objectAtIndex: indexPath.row];
    UITableViewCell *cell = [itemDetails dequeueReusableCellWithIdentifier:@"missionItemCell"];
    
    // Note: see prototype cell for magic #'s
    UILabel *label    = (UILabel *)    [cell viewWithTag:100];
    UITextField *text = (UITextField *)[cell viewWithTag:200];
    UILabel *units    = (UILabel *)    [cell viewWithTag:300];
    
    [label setText:[field label]];
    [text  setText:[field valueToString:item]];
    [units setText:[field unitsToString]];
    return cell;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    // FIXME: is there a nicer way to do this? (without for instance, using a tag on textfield, which we're already)
    // using for another purpose
    NSIndexPath *indexPath = [itemDetails indexPathForCell:(UITableViewCell*)[[textField superview] superview]];
    //NSLog(@"textFieldDidEndEditing - tag: %d, indexPath.row = %d", textField.tag, indexPath.row);

    mavlink_mission_item_t item = [self getCurrentMissionItem];
    MissionItemField *field = (MissionItemField*)[[MavLinkUtility missionItemMetadataWith: item.command] objectAtIndex: indexPath.row];

    // Modify the respective field in the item
    [field setValue:[textField.text floatValue] inMissionItem:&item];

    [delegate replaceMissionItem:item atIndex:itemIndex];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

// Limit textfields to numeric values only
// ref: http://stackoverflow.com/questions/9344159/validate-numeric-input-to-uitextfield-as-the-user-enters-input
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
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
    saveEdits = false;
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)saveButtonClicked:(id)sender {
    saveEdits = true;
    [self.navigationController popViewControllerAnimated:YES];
}

@end
