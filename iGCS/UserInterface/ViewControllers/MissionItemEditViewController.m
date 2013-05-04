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
    
    [missionItemTypes addObject:[NSNumber numberWithInt: 16] /* @"MAV_CMD_NAV_WAYPOINT" */];
    //[missionItemTypes addObject:[NSNumber numberWithInt: 17] /* @"MAV_CMD_NAV_LOITER_UNLIM" */];
    //[missionItemTypes addObject:[NSNumber numberWithInt: 18] /* @"MAV_CMD_NAV_LOITER_TURNS" */];
    //[missionItemTypes addObject:[NSNumber numberWithInt: 19] /* @"MAV_CMD_NAV_LOITER_TIME" */];
    //[missionItemTypes addObject:[NSNumber numberWithInt: 20] /* @"MAV_CMD_NAV_RETURN_TO_LAUNCH" */];
    [missionItemTypes addObject:[NSNumber numberWithInt: 21] /* @"MAV_CMD_NAV_LAND" */];
    //[missionItemTypes addObject:[NSNumber numberWithInt: 22] /* @"MAV_CMD_NAV_TAKEOFF" */];
    
    //[missionItemTypes addObject:[NSNumber numberWithInt: 112]  /* @"MAV_CMD_CONDITION_DELAY" */];
    [missionItemTypes addObject:[NSNumber numberWithInt: 113]  /* @"MAV_CMD_CONDITION_CHANGE_ALT" */];
    //[missionItemTypes addObject:[NSNumber numberWithInt: 114]  /* @"MAV_CMD_CONDITION_DISTANCE" */];
    
    [missionItemTypes addObject:[NSNumber numberWithInt: 177]  /* @"MAV_CMD_DO_JUMP" */];
    //[missionItemTypes addObject:[NSNumber numberWithInt: 178]  /* @"MAV_CMD_DO_CHANGE_SPEED" */];
    //[missionItemTypes addObject:[NSNumber numberWithInt: 179]  /* @"MAV_CMD_DO_SET_HOME" */];
    //[missionItemTypes addObject:[NSNumber numberWithInt: 180]  /* @"MAV_CMD_DO_SET_PARAMETER" */];
    //[missionItemTypes addObject:[NSNumber numberWithInt: 181]  /* @"MAV_CMD_DO_SET_RELAY" */];
    //[missionItemTypes addObject:[NSNumber numberWithInt: 182]  /* @"MAV_CMD_DO_REPEAT_RELAY" */];
    //[missionItemTypes addObject:[NSNumber numberWithInt: 183]  /* @"MAV_CMD_DO_SET_SERVO" */];
    //[missionItemTypes addObject:[NSNumber numberWithInt: 184]  /* @"MAV_CMD_DO_REPEAT_SERVO" */];
    
    ////////////////////////////////////////
    //
    
    // FIXME: this could prove confusing. Likely want to hide seq numbers and use table row numbers
    // instead (or keep row numbers and seq numbers aligned during shuffling/deletion etc, which we
    // might need anyway)
    [self setTitle:[NSString stringWithFormat:@"Mission Item #%d", missionItem.seq]];
    [self refreshWithMissionItem];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString * segueName = segue.identifier;
    if ([segueName isEqualToString: @"detailItemVC_embed"]) {
        tabVCDetailItemVC = (UITabBarController*) [segue destinationViewController];
        
        // Hack - we're really just using the UITabBarController as a container for our subviews.
        // Hide the tab bar, and use up the missing space. FIXME: is there a nicer pattern for this?
        [tabVCDetailItemVC.tabBar setHidden:YES];
        for (unsigned int i = 0; i < [tabVCDetailItemVC.view.subviews count]; i++) {
            [[tabVCDetailItemVC.view.subviews objectAtIndex:i] setFrame:tabVCDetailItemVC.view.frame];
        }
        NSLog(@"detailItemVC_embed found");
    }
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
    return [WaypointHelper commandIDToString: ((NSNumber*)[missionItemTypes objectAtIndex:row]).intValue];
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSLog(@"Selected Mission Item: %@ at index %i", [missionItemTypes objectAtIndex:row], row);
    [self showTabBarViewForRow: row];
}

- (void) refreshWithMissionItem {
    // Check that we have a supported mission item 
    int row = -1;
    for (unsigned int i = 0; i < [missionItemTypes count]; i++) {
        uint16_t commandID = ((NSNumber*)[missionItemTypes objectAtIndex:i]).intValue;
        if (commandID == missionItem.command) {
            row = i;
            break;
        }
    }
    
    if (row == -1) {
        // FIXME: think about how to handle unsupported row?
        return;
    }
    
    // Set the corresponding picker view row, and drop in the correct window 
    [pickerView selectRow:row inComponent:0 animated:NO];
    [self showTabBarViewForRow: row];
}

- (void) showTabBarViewForRow:(int)row {
    int tabBarIndex = row; // FIXME: choose correct controller - perhaps tag controllers based on command ID?
    
#if 0
    [tabVCDetailItemVC setSelectedIndex: tabBarIndex];
#else
    // Alternative. c.f. http://stackoverflow.com/questions/5161730/iphone-how-to-switch-tabs-with-an-animation
    UIView *fromView = tabVCDetailItemVC.selectedViewController.view;
    UIView *toView = [[tabVCDetailItemVC.viewControllers objectAtIndex:tabBarIndex] view];
    
    // Transition using a page curl.
    [UIView transitionFromView:fromView
                        toView:toView
                      duration:0.3
                       options:UIViewAnimationCurveLinear|(tabBarIndex > tabVCDetailItemVC.selectedIndex ? UIViewAnimationOptionTransitionFlipFromLeft :UIViewAnimationOptionTransitionFlipFromRight)
                    completion:^(BOOL finished) {
                        if (finished) {
                            tabVCDetailItemVC.selectedIndex = tabBarIndex;
                        }
                    }];
#endif
}
@end
