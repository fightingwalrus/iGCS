//
//  WaypointsViewController.m
//  iGCS
//
//  Created by Claudio Natoli on 18/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WaypointsViewController.h"

#import "MissionItemEditViewController.h"

#import "CommController.h"

@interface WaypointsViewController ()

@end

@implementation WaypointsViewController

@synthesize uploadButton;
@synthesize loadDemoButton;

@synthesize addButton;
@synthesize editDoneButton;

@synthesize containerForTableView;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
    
    // Release any cached data, images, etc that aren't in use.
#if DO_NSLOG
    if ([self isViewLoaded]) {
        NSLog(@"\t\tWaypointsViewController::didReceiveMemoryWarning: view is still loaded");
    } else {
        NSLog(@"\t\tWaypointsViewController::didReceiveMemoryWarning: view is NOT loaded");
    }
#endif
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Custom initialization
    waypoints = [[WaypointsHolder alloc] initWithExpectedCount:0];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register for keyboard show/hide notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardShowing:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardHiding:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString * segueName = segue.identifier;
    if ([segueName isEqualToString: @"editItemVC_embed"]) {
        navVCEditItemVC = (UINavigationController*) [segue destinationViewController];
        NSLog(@"editItemVC_embed found");
    }
}

- (void)handleKeyboardDisplay:(NSNotification *)notification showing:(bool)showing {
    
    // Determine amount to slide the map and table views
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGSize tabBarSize = self.tabBarController.tabBar.frame.size;
    CGFloat y = (keyboardSize.width - tabBarSize.height);
    if (!showing) y = -y;
    
    // Compute new frames
    CGRect tableRect = containerForTableView.frame;
    CGRect mapRect   = map.frame;
    tableRect.origin.y -= y;
    mapRect.origin.y   -= y;
    
    // Attempt to match the keyboard animation speed/curve
    NSDictionary* userInfo = [notification userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    containerForTableView.frame = tableRect;
    map.frame = mapRect;
    [UIView commitAnimations];
}

- (void)keyboardShowing:(NSNotification *)notification
{
    [self handleKeyboardDisplay: notification showing:YES];
}

- (void)keyboardHiding:(NSNotification *)notification
{
    [self handleKeyboardDisplay: notification showing:NO];
}

- (UITableView*) getTableView
{
    assert(navVCEditItemVC);
    return ((UITableViewController*)[navVCEditItemVC.viewControllers objectAtIndex:0]).tableView;
}

- (WaypointsHolder*)getWaypointsHolder
{
    return waypoints;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) resetWaypoints {
    [self resetWaypoints: waypoints];
}

- (void) resetWaypoints:(WaypointsHolder*)_waypoints {
    // set waypoints ahead of waypointNumberForAnnotationView calls from [super resetWaypoints:...]
    waypoints = _waypoints;
    
    [super resetWaypoints:_waypoints];
    
    [[self getTableView] reloadData];
}

- (void) handlePacket:(mavlink_message_t*)msg {
}

- (void) waypointWithSeq:(int)waypointSeq wasMovedToLat:(double)latitude andLong:(double)longitude {
    int index = [waypoints getIndexOfWaypointWithSeq:waypointSeq];
    if (index != -1) {
        mavlink_mission_item_t waypoint = [waypoints getWaypoint:index];
        waypoint.x = latitude;
        waypoint.y = longitude;
        [waypoints replaceWaypoint:index with:waypoint];
        
        // Reset the map and table views
        [self resetWaypoints];  // FIXME: this is a little heavy handed. Want more fine-grained
                                // control here (like not resetting the map bounds in this case)
    }
}

- (NSString*) waypointNumberForAnnotationView:(mavlink_mission_item_t)item {
    // This subclass uses the row number
    return [NSString stringWithFormat:@"%d", [waypoints getIndexOfWaypointWithSeq:item.seq]];
}

- (IBAction)addClicked:(id)sender {
    // FIXME: smarter default location (configurable default alt, locate near GPS home etc)
    mavlink_mission_item_t waypoint;
    
    waypoint.autocontinue = 0;
    waypoint.command = MAV_CMD_NAV_WAYPOINT;
    waypoint.current = 0;
    waypoint.frame   = MAV_FRAME_GLOBAL_RELATIVE_ALT;
    waypoint.param1 = waypoint.param2 = waypoint.param3 = waypoint.param4 = 0;
    waypoint.x = waypoint.y = 0;
    waypoint.z = 100;
    waypoint.seq = 0;
    
    // Get default position
    WaypointsHolder *currentNavPoints = [waypoints getNavWaypoints];
    if ([currentNavPoints numWaypoints] > 0) {
        // Add a new point slightly to the east of the last one
        mavlink_mission_item_t lastNavItem = [currentNavPoints getLastWaypoint];
        waypoint.x = lastNavItem.x;
        waypoint.y = lastNavItem.y + 0.005;
        if (waypoint.y > 180) {
            waypoint.y -= 360;
        }
    }
    
    [waypoints addWaypoint:waypoint];
    [self resetWaypoints];
}

// FIXME: also need to check and close the detail view if open
- (IBAction)editDoneClicked:(id)sender {
    UITableView* tableView = [self getTableView];
    bool isEditing = !tableView.editing;
    
    // Update the table and edit/add/upload buttons
    [tableView setEditing:isEditing animated:true];
    editDoneButton.title = isEditing ? @"Done" : @"Edit";
    editDoneButton.style = isEditing ? UIBarButtonItemStyleDone : UIBarButtonItemStyleBordered;
    
    addButton.enabled    = isEditing;
    uploadButton.enabled   = !isEditing;
    loadDemoButton.enabled = !isEditing;

    int delta = isEditing ? TABLE_MAP_SLIDE_AMOUNT : -TABLE_MAP_SLIDE_AMOUNT;

    // Slide/grow/shrink the map and table views
    CGRect tableRect = containerForTableView.frame;
    CGRect mapRect   = map.frame;

    tableRect.origin.y += delta;
    tableRect.size.height -= delta;
    mapRect.size.height += delta;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.75];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    containerForTableView.frame = tableRect;
    map.frame = mapRect;
    [UIView commitAnimations];
    
    // Update the map view with non/editable waypoints
    [self makeWaypointsDraggable:isEditing];
}

- (IBAction)uploadClicked:(id)sender {
    [[CommController appMLI] issueStartWriteMissionRequest: waypoints];
}


// @protocol MissionItemEditingDelegate
- (WaypointsHolder*) cloneMission {
    return [waypoints mutableCopy];
}

- (mavlink_mission_item_t) getMissionItemAtIndex:(unsigned int)idx {
    return [waypoints getWaypoint:idx];
}

- (void) resetMission:(WaypointsHolder*) mission {
    [self resetWaypoints: mission];
}

- (void) replaceMissionItem:(mavlink_mission_item_t)item atIndex:(unsigned int)idx {
    [waypoints replaceWaypoint:idx with:item]; // Swap in the modified mission item
    [self resetWaypoints]; // Reset the map and table views
}
// end @protocol MissionItemEditingDelegate


- (IBAction)loadDemoMision: (id)sender {
    [[CommController appMLI] loadDemoMission];
}

@end
