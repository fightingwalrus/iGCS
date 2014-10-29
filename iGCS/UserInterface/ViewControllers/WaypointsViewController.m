//
//  WaypointsViewController.m
//  iGCS
//
//  Created by Claudio Natoli on 18/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WaypointsViewController.h"

#import "MissionItemTableViewController.h"
#import "MissionItemEditViewController.h"

#import "CommController.h"

@interface WaypointsViewController ()

@end

@implementation WaypointsViewController

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Adjust view for iOS6 differences
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
        _carrierPadding.width = 0;
        _batteryPadding.width = 0;
    }
    
    // Custom initialization
    _waypoints = [[WaypointsHolder alloc] initWithExpectedCount:0];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

#ifndef DEBUG
    // Hide the Load Demo UIBarButtonItem in non-DEBUG builds
    _loadDemoButton.title = nil;   // UIBarButtonItem does not have a hidden property; this has the effect of hiding textual button items
    _loadDemoButton.enabled = NO;
#endif

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

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString * segueName = segue.identifier;
    if ([segueName isEqualToString: @"editItemVC_embed"]) {
        _navVCEditItemVC = (UINavigationController*) [segue destinationViewController];
    }
}

- (void)handleKeyboardDisplay:(NSNotification *)notification showing:(BOOL)showing {
    
    // Determine amount to slide the map and table views
    CGSize keyboardSize = [[notification userInfo][UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGSize tabBarSize = self.tabBarController.tabBar.frame.size;
    CGFloat y = (keyboardSize.width - tabBarSize.height);
    if (!showing) y = -y;
    
    // Compute new frames
    CGRect tableRect = _containerForTableView.frame;
    CGRect mapRect   = self.mapView.frame;
    tableRect.origin.y -= y;
    mapRect.origin.y   -= y;
    
    // Attempt to match the keyboard animation speed/curve
    NSDictionary* userInfo = [notification userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    [userInfo[UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [userInfo[UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    _containerForTableView.frame = tableRect;
    self.mapView.frame = mapRect;
    [UIView commitAnimations];
}

- (void)keyboardShowing:(NSNotification *)notification {
    [self handleKeyboardDisplay: notification showing:YES];
}

- (void)keyboardHiding:(NSNotification *)notification {
    [self handleKeyboardDisplay: notification showing:NO];
}

- (MissionItemTableViewController*) missionTableViewController {
    assert(_navVCEditItemVC);
    return (_navVCEditItemVC.viewControllers)[0];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) resetWaypoints {
    [self resetWaypoints:_waypoints];
}

- (void) resetWaypoints:(WaypointsHolder*)waypoints {
    // set waypoints ahead of waypointNumberForAnnotationView calls from [super resetWaypoints:...]
    _waypoints = waypoints;
    [super resetWaypoints:_waypoints];
    [self.missionTableViewController resetWaypoints];
}

- (void) handlePacket:(mavlink_message_t*)msg {
}

- (void) waypointWithSeq:(int)waypointSeq wasMovedToLat:(double)latitude andLong:(double)longitude {
    int index = [_waypoints getIndexOfWaypointWithSeq:waypointSeq];
    if (index != -1) {
        mavlink_mission_item_t waypoint = [_waypoints getWaypoint:index];
        waypoint.x = latitude;
        waypoint.y = longitude;
        [_waypoints replaceWaypoint:index with:waypoint];
        
        // Reset the map and table views
        [self resetWaypoints];  // FIXME: this is a little heavy handed. Want more fine-grained
                                // control here (like not resetting the map bounds in this case)
    }
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if ([view.annotation isKindOfClass:[WaypointAnnotation class]]) {
        WaypointAnnotation *annotation = (WaypointAnnotation*)view.annotation;
        [self.missionTableViewController markSelectedRow: [_waypoints getIndexOfWaypointWithSeq: annotation.waypoint.seq]];
    }
}

- (NSString*) waypointNumberForAnnotationView:(mavlink_mission_item_t)item {
    // This subclass uses the row number
    return [NSString stringWithFormat:@"%d", [_waypoints getIndexOfWaypointWithSeq:item.seq]];
}


- (mavlink_mission_item_t) createDefaultWaypointFromCoords:(CLLocationCoordinate2D)pos {
    mavlink_mission_item_t waypoint;
    
    waypoint.autocontinue = 1;
    waypoint.command = MAV_CMD_NAV_WAYPOINT;
    waypoint.current = 0;
    waypoint.frame   = MAV_FRAME_GLOBAL_RELATIVE_ALT;
    waypoint.param1 = waypoint.param2 = waypoint.param3 = waypoint.param4 = 0;
    waypoint.x = pos.latitude;
    waypoint.y = pos.longitude;
    waypoint.z = WAYPOINT_DEFAULT_ALTITUDE;
    waypoint.seq = 0;
    
    return waypoint;
}

- (IBAction) addClicked:(id)sender {
    CLLocationCoordinate2D pos;

    // Determine the next "default" waypoint position
    WaypointsHolder *currentNavPoints = [_waypoints navWaypoints];
    if ([currentNavPoints numWaypoints] > 0) {
        // Add a new point slightly to the east of the last one
        mavlink_mission_item_t lastNavItem = [currentNavPoints lastWaypoint];
        pos.latitude  = lastNavItem.x;
        pos.longitude = lastNavItem.y + 0.002; // ~200m equatorially
        if (pos.longitude > 180) {
            pos.longitude -= 360;
        }
    } else if (userPosition) {
        // Place the first point near the current user
        pos = userPosition.coordinate;
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to determine default waypoint"
                                                        message:@"Place the first waypoint manually, or enable GPS"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    [_waypoints addWaypoint:[self createDefaultWaypointFromCoords:pos]];
    [self resetWaypoints];
}

// Recognizer for long press gestures => add waypoint
-(void) handleLongPressGesture:(UIGestureRecognizer*)sender {
    if (!(self.missionTableViewController.isEditing && sender.state == UIGestureRecognizerStateBegan))
        return;
    
    // Set the coordinates of the map point being held down
    CLLocationCoordinate2D pos = [self.mapView convertPoint:[sender locationInView:self.mapView] toCoordinateFromView:self.mapView];
    [_waypoints addWaypoint:[self createDefaultWaypointFromCoords:pos]];
    [self resetWaypoints];
}

// FIXME: also need to check and close the detail view if open
- (IBAction)editDoneClicked:(id)sender {
    
    // Update the table and edit/add/upload buttons
    BOOL isEditing = [self.missionTableViewController toggleEditing];
    _editDoneButton.title = isEditing ? @"Done" : @"Edit";
    _editDoneButton.style = isEditing ? UIBarButtonItemStyleDone : UIBarButtonItemStyleBordered;
    
    _addButton.enabled       = isEditing;
    _rxMissionButton.enabled = !isEditing;
    _txMissionButton.enabled = !isEditing;
    _loadDemoButton.enabled  = !isEditing;

    int delta = isEditing ? TABLE_MAP_SLIDE_AMOUNT : -TABLE_MAP_SLIDE_AMOUNT;

    // Slide/grow/shrink the map and table views
    CGRect tableRect = _containerForTableView.frame;
    CGRect mapRect   = self.mapView.frame;

    tableRect.origin.y += delta;
    tableRect.size.height -= delta;
    mapRect.size.height += delta;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.75];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    _containerForTableView.frame = tableRect;
    self.mapView.frame = mapRect;
    [UIView commitAnimations];
    
    // Update the map view with non/editable waypoints
    [self makeWaypointsDraggable:isEditing];
}


- (IBAction)mavTxMissionClicked:(id)sender {
    [[[CommController sharedInstance] mavLinkInterface] startWriteMissionRequest:_waypoints];
}

- (IBAction)mavRxMissionClicked:(id)sender {
    [[[CommController sharedInstance] mavLinkInterface] startReadMissionRequest];
}

// @protocol MissionItemEditingDelegate
- (WaypointsHolder*) cloneMission {
    return [_waypoints mutableCopy];
}

- (mavlink_mission_item_t) getMissionItemAtIndex:(NSUInteger)idx {
    return [_waypoints getWaypoint:idx];
}

- (void) resetMission:(WaypointsHolder*) mission {
    [self resetWaypoints: mission];
}

- (void) replaceMissionItem:(mavlink_mission_item_t)item atIndex:(NSUInteger)idx {
    [_waypoints replaceWaypoint:idx with:item]; // Swap in the modified mission item
    [self resetWaypoints]; // Reset the map and table views
}
// end @protocol MissionItemEditingDelegate


- (IBAction)loadDemoMision: (id)sender {
    [[[CommController sharedInstance] mavLinkInterface] loadDemoMission];
}

@end
