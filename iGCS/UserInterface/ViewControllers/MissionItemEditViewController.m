//
//  MissionItemEditViewController.m
//  iGCS
//
//  Created by Claudio Natoli on 4/05/13.
//
//

#import "MissionItemEditViewController.h"

#import "WaypointHelper.h"

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

	// Define the list of mission item meta-data
    missionItemMetaData = [[NSMutableDictionary alloc] init];
    
    // NAV mission items
    [missionItemMetaData setObject:[[NSArray alloc] initWithObjects:
                                    [[MissionItemField alloc] initWithLabel:@"Altitude" andType:kPARAM_Z], nil]
                            forKey:[NSNumber numberWithInt: 16]]; // MAV_CMD_NAV_WAYPOINT
    [missionItemMetaData setObject:[[NSArray alloc] initWithObjects:
                                    [[MissionItemField alloc] initWithLabel:@"Altitude" andType:kPARAM_Z], nil]
                            forKey:[NSNumber numberWithInt: 17]]; // MAV_CMD_NAV_LOITER_UNLIM
    [missionItemMetaData setObject:[[NSArray alloc] initWithObjects:
                                    [[MissionItemField alloc] initWithLabel:@"Altitude" andType:kPARAM_Z],
                                    [[MissionItemField alloc] initWithLabel:@"# Turns" andType:kPARAM_1], nil]
                            forKey:[NSNumber numberWithInt: 18]]; // MAV_CMD_NAV_LOITER_TURNS
    [missionItemMetaData setObject:[[NSArray alloc] initWithObjects:
                                    [[MissionItemField alloc] initWithLabel:@"Altitude"          andType:kPARAM_Z],
                                    [[MissionItemField alloc] initWithLabel:@"Time (seconds*10)" andType:kPARAM_1], nil]
                            forKey:[NSNumber numberWithInt: 19]]; // MAV_CMD_NAV_LOITER_TIME
    [missionItemMetaData setObject:[[NSArray alloc] initWithObjects:
                                    [[MissionItemField alloc] initWithLabel:@"Altitude" andType:kPARAM_Z], nil]
                            forKey:[NSNumber numberWithInt: 20]]; // MAV_CMD_NAV_RETURN_TO_LAUNCH
    [missionItemMetaData setObject:[[NSArray alloc] initWithObjects:
                                    [[MissionItemField alloc] initWithLabel:@"Altitude" andType:kPARAM_Z], nil]
                            forKey:[NSNumber numberWithInt: 21]]; // MAV_CMD_NAV_LAND
    [missionItemMetaData setObject:[[NSArray alloc] initWithObjects:
                                    [[MissionItemField alloc] initWithLabel:@"Altitude"      andType:kPARAM_Z],
                                    [[MissionItemField alloc] initWithLabel:@"Takeoff Pitch" andType:kPARAM_1], nil]
                            forKey:[NSNumber numberWithInt: 22]]; // MAV_CMD_NAV_TAKEOFF
    
    // Conditional CMD mission items
    [missionItemMetaData setObject:[[NSArray alloc] initWithObjects:
                                    [[MissionItemField alloc] initWithLabel:@"Time (s)" andType:kPARAM_3], nil]
                            forKey:[NSNumber numberWithInt: 112]]; // MAV_CMD_CONDITION_DELAY
    [missionItemMetaData setObject:[[NSArray alloc] initWithObjects:
                                    [[MissionItemField alloc] initWithLabel:@"Rate (cm/s)"       andType:kPARAM_1],
                                    [[MissionItemField alloc] initWithLabel:@"Altitude (finish)" andType:kPARAM_2], nil]
                            forKey:[NSNumber numberWithInt: 113]]; // MAV_CMD_CONDITION_CHANGE_ALT
    [missionItemMetaData setObject:[[NSArray alloc] initWithObjects:
                                    [[MissionItemField alloc] initWithLabel:@"Distance (m)" andType:kPARAM_3], nil]
                            forKey:[NSNumber numberWithInt: 114]]; // MAV_CMD_CONDITION_DISTANCE
    
    // DO CMD mission items
    [missionItemMetaData setObject:[[NSArray alloc] initWithObjects:
                                    [[MissionItemField alloc] initWithLabel:@"Index"        andType:kPARAM_1],
                                    [[MissionItemField alloc] initWithLabel:@"Repeat Count" andType:kPARAM_3], nil]
                            forKey:[NSNumber numberWithInt: 177]]; // MAV_CMD_DO_JUMP
    [missionItemMetaData setObject:[[NSArray alloc] initWithObjects:
                                    [[MissionItemField alloc] initWithLabel:@"Speed type"   andType:kPARAM_1],
                                    [[MissionItemField alloc] initWithLabel:@"Speed (m/s)"  andType:kPARAM_2],
                                    [[MissionItemField alloc] initWithLabel:@"Throttle (%)" andType:kPARAM_3], nil]
                            forKey:[NSNumber numberWithInt: 178]]; // MAV_CMD_DO_CHANGE_SPEED
    [missionItemMetaData setObject:[[NSArray alloc] initWithObjects:
                                    [[MissionItemField alloc] initWithLabel:@"Use current" andType:kPARAM_1],
                                    [[MissionItemField alloc] initWithLabel:@"Altitude"    andType:kPARAM_2],
                                    [[MissionItemField alloc] initWithLabel:@"Latitude"    andType:kPARAM_3],
                                    [[MissionItemField alloc] initWithLabel:@"Longitude"   andType:kPARAM_4], nil]
                            forKey:[NSNumber numberWithInt: 179]]; // MAV_CMD_DO_SET_HOME
    /*
     [missionItemMetaData setObject:[[NSArray alloc] initWithObjects:
                                    [[MissionItemField alloc] initWithLabel:@"Param #"     andType:kPARAM_1],
                                    [[MissionItemField alloc] initWithLabel:@"Param Value" andType:kPARAM_2], nil]
                            forKey:[NSNumber numberWithInt: 180]]; // MAV_CMD_DO_SET_PARAMETER
     */
    [missionItemMetaData setObject:[[NSArray alloc] initWithObjects:
                                    [[MissionItemField alloc] initWithLabel:@"Relay #" andType:kPARAM_1],
                                    [[MissionItemField alloc] initWithLabel:@"On/Off"  andType:kPARAM_2], nil]
                            forKey:[NSNumber numberWithInt: 181]]; // MAV_CMD_DO_SET_RELAY
    [missionItemMetaData setObject:[[NSArray alloc] initWithObjects:
                                    [[MissionItemField alloc] initWithLabel:@"Relay #"        andType:kPARAM_1],
                                    [[MissionItemField alloc] initWithLabel:@"Cycle count"    andType:kPARAM_2],
                                    [[MissionItemField alloc] initWithLabel:@"Cycle time (s)" andType:kPARAM_3], nil]
                            forKey:[NSNumber numberWithInt: 182]]; // MAV_CMD_DO_REPEAT_RELAY
    [missionItemMetaData setObject:[[NSArray alloc] initWithObjects:
                                    [[MissionItemField alloc] initWithLabel:@"Servo # (5-8)" andType:kPARAM_1],
                                    [[MissionItemField alloc] initWithLabel:@"On/Off"        andType:kPARAM_2], nil]
                            forKey:[NSNumber numberWithInt: 183]]; // MAV_CMD_DO_SET_SERVO
    [missionItemMetaData setObject:[[NSArray alloc] initWithObjects:
                                    [[MissionItemField alloc] initWithLabel:@"Servo # (5-8)"  andType:kPARAM_1],
                                    [[MissionItemField alloc] initWithLabel:@"Cycle count"    andType:kPARAM_2],
                                    [[MissionItemField alloc] initWithLabel:@"Cycle time (s)" andType:kPARAM_3], nil]
                            forKey:[NSNumber numberWithInt: 184]]; // MAV_CMD_DO_REPEAT_SERVO
    
    
    // Get the sorted list of all commands IDs for use in indexing the picker view
    missionItemCommandIDs = [[missionItemMetaData allKeys] sortedArrayUsingSelector: @selector(compare:)];
    
    
    // FIXME: this could prove confusing. Likely want to hide seq numbers and use table row numbers
    // instead (or keep row numbers and seq numbers aligned during shuffling/deletion etc, which we
    // might need anyway)
    [self setTitle:[NSString stringWithFormat:@"Mission Item #%d", [self getCurrentMissionItem].seq]];
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
        // FIXME: think about how to handle unsupported row?
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

- (NSArray*)getMetaDataOfCurrentMissionItem {
    return [missionItemMetaData objectForKey: [NSNumber numberWithInt: [self getCurrentMissionItem].command]];
}

- (NSString*) getValueOfFieldInCurentMissionItem:(MissionItemField*)field
{
    mavlink_mission_item_t missionItem = [self getCurrentMissionItem];
    switch ([field fieldType]) {
        case kPARAM_Z:
            return [NSString stringWithFormat:@"%f", missionItem.z];
            
        case kPARAM_1:
            return [NSString stringWithFormat:@"%f", missionItem.param1];
            
        case kPARAM_2:
            return [NSString stringWithFormat:@"%f", missionItem.param2];
            
        case kPARAM_3:
            return [NSString stringWithFormat:@"%f", missionItem.param3];
            
        case kPARAM_4:
            return [NSString stringWithFormat:@"%f", missionItem.param4];
            
        default:
            assert(false);
            break;
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self getMetaDataOfCurrentMissionItem] count];
}

- (UITableViewCell *)tableView: (UITableView *)_tableView cellForRowAtIndexPath: (NSIndexPath *)indexPath
{
    MissionItemField *field = (MissionItemField*)[[self getMetaDataOfCurrentMissionItem] objectAtIndex: indexPath.row];
    UITableViewCell *cell = [itemDetails dequeueReusableCellWithIdentifier:@"missionItemCell"];
    
    UILabel *label = (UILabel *)[cell viewWithTag:100]; // see prototype cell for magic #
    [label setText:[field label]];
    
    UITextField *text = (UITextField *)[cell viewWithTag:200]; // see prototype cell for magic #
    [text setText: [self getValueOfFieldInCurentMissionItem:field]];
    return cell;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    // FIXME: is there a nicer way to do this? (without for instance, using a tag on textfield, which we're already)
    // using for another purpose
    NSIndexPath *indexPath = [itemDetails indexPathForCell:(UITableViewCell*)[[textField superview] superview]];
    //NSLog(@"textFieldDidEndEditing - tag: %d, indexPath.row = %d", textField.tag, indexPath.row);

    MissionItemField *field = (MissionItemField*)[[self getMetaDataOfCurrentMissionItem] objectAtIndex: indexPath.row];

    mavlink_mission_item_t missionItem = [self getCurrentMissionItem];
    
    // Modify the respective field
    float val = [textField.text floatValue];
    switch ([field fieldType]) {
        case kPARAM_Z:
            missionItem.z = val;
            break;

        case kPARAM_1:
            missionItem.param1 = val;
            break;

        case kPARAM_2:
            missionItem.param2 = val;
            break;

        case kPARAM_3:
            missionItem.param3 = val;
            break;

        case kPARAM_4:
            missionItem.param4 = val;
            break;
            
        default:
            assert(false);
            break;
    }
    [delegate replaceMissionItem:missionItem atIndex:itemIndex];
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
