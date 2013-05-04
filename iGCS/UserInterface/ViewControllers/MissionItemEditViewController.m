//
//  MissionItemEditViewController.m
//  iGCS
//
//  Created by Claudio Natoli on 4/05/13.
//
//

#import "MissionItemEditViewController.h"

@interface MissionItemEditViewController ()

@end

@implementation MissionItemEditViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) initInstance:(mavlink_mission_item_t)_missionItem {
    missionItem = _missionItem;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	// Do any additional setup after loading the view.
    missionItemTypes = [[NSMutableArray alloc] init];
    
    [missionItemTypes addObject:@"MAV_CMD_NAV_WAYPOINT"];
    [missionItemTypes addObject:@"MAV_CMD_NAV_LOITER_UNLIM"];
    [missionItemTypes addObject:@"MAV_CMD_NAV_LOITER_TURNS"];
    [missionItemTypes addObject:@"MAV_CMD_NAV_LOITER_TIME"];
    [missionItemTypes addObject:@"MAV_CMD_NAV_RETURN_TO_LAUNCH"];
    [missionItemTypes addObject:@"MAV_CMD_NAV_LAND"];
    [missionItemTypes addObject:@"MAV_CMD_NAV_TAKEOFF"];
    [missionItemTypes addObject:@"MAV_CMD_NAV_TARGET"];
    
    [missionItemTypes addObject:@"MAV_CMD_CONDITION_DELAY"];
    [missionItemTypes addObject:@"MAV_CMD_CONDITION_CHANGE_ALT"];
    [missionItemTypes addObject:@"MAV_CMD_CONDITION_DISTANCE"];
    
    [missionItemTypes addObject:@"MAV_CMD_DO_JUMP"];
    [missionItemTypes addObject:@"MAV_CMD_DO_CHANGE_SPEED"];
    [missionItemTypes addObject:@"MAV_CMD_DO_SET_HOME"];
    [missionItemTypes addObject:@"MAV_CMD_DO_SET_PARAMETER"];
    [missionItemTypes addObject:@"MAV_CMD_DO_SET_RELAY"];
    [missionItemTypes addObject:@"MAV_CMD_DO_REPEAT_RELAY"];
    [missionItemTypes addObject:@"MAV_CMD_DO_SET_SERVO"];
    [missionItemTypes addObject:@"MAV_CMD_DO_REPEAT_SERVO"];
    
    // FIXME: finish me!
    static int foo = 0;
    foo++;
    [self selectWaypointType: foo];
    
    // FIXME: this could prove confusing. Likely want to hide seq numbers and use table row numbers
    // instead (or keep row numbers and seq numbers aligned during shuffling/deletion etc, which we
    // might need anyway)
    [self setTitle:[NSString stringWithFormat:@"Mission Item #%d", missionItem.seq]];
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
    return [missionItemTypes count];
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [missionItemTypes objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSLog(@"Selected Mission Item: %@ at index %i", [missionItemTypes objectAtIndex:row], row);
}

- (void) selectWaypointType:(uint16_t)itemType {
    [pickerView selectRow:itemType inComponent:0 animated:NO];
}

@end
