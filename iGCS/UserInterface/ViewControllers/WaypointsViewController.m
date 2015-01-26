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
@property (nonatomic, strong) UINavigationController *navVCEditItemVC;
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
        self.carrierPadding.width = 0;
        self.batteryPadding.width = 0;
    }
    
    // Custom initialization
    _waypoints = [[WaypointsHolder alloc] initWithExpectedCount:0];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

#ifndef DEBUG
    // Hide the Load Demo UIBarButtonItem in non-DEBUG builds
    self.loadDemoButton.title = nil;   // UIBarButtonItem does not have a hidden property; this has the effect of hiding textual button items
    self.loadDemoButton.enabled = NO;
#endif
    
    // Effectively, disable autolayout for these views
    //  - corrects the expanding/contract effect on Edit for iOS8
    [self.containerForTableView setTranslatesAutoresizingMaskIntoConstraints:YES];
    [self.mapView setTranslatesAutoresizingMaskIntoConstraints:YES];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardShowing:)
                                                 name:UIKeyboardWillShowNotification
                                               object:self.view.window];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardHiding:)
                                                 name:UIKeyboardWillHideNotification
                                               object:self.view.window];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString * segueName = segue.identifier;
    if ([segueName isEqualToString: @"editItemVC_embed"]) {
        self.navVCEditItemVC = (UINavigationController*) [segue destinationViewController];
    }
}

- (void)handleKeyboardDisplay:(NSNotification *)notification showing:(BOOL)showing {
    
    // Determine amount to slide the map and table views
    CGSize keyboardSize = [[notification userInfo][UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGSize tabBarSize = self.tabBarController.tabBar.frame.size;

    // account for new orientation dependent bounds in iOS 8
    CGFloat y;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        y = (keyboardSize.height - tabBarSize.height);
    } else {
        y = (keyboardSize.width - tabBarSize.height);
    }

    if (!showing) y = -y;
    
    // Compute new frames
    CGRect tableRect = self.containerForTableView.frame;
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
    self.containerForTableView.frame = tableRect;
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
    assert(self.navVCEditItemVC);
    return (self.navVCEditItemVC.viewControllers)[0];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) resetWaypoints {
    [self replaceMission:self.waypoints];
}

- (void) replaceMission:(WaypointsHolder*)mission {
    // set waypoints ahead of waypointNumberForAnnotationView calls from [super replaceMission:...]
    _waypoints = mission;
    [super replaceMission:self.waypoints];
    [self.missionTableViewController refreshTableView];
}

- (void) handlePacket:(mavlink_message_t*)msg {
}

- (void) waypointWithSeq:(WaypointSeq)waypointSeq wasMovedToLat:(double)latitude andLong:(double)longitude {
    NSInteger index = [self.waypoints getIndexOfWaypointWithSeq:waypointSeq];
    if (index != -1) {
        mavlink_mission_item_t waypoint = [self.waypoints getWaypoint:index];
        waypoint.x = latitude;
        waypoint.y = longitude;
        [self.waypoints replaceWaypoint:index with:waypoint];
        
        // Reset the map and table views
        [self resetWaypoints];  // FIXME: this is a little heavy handed. Want more fine-grained
                                // control here (like not resetting the map bounds in this case)
    }
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if ([view.annotation isKindOfClass:[WaypointAnnotation class]]) {
        WaypointAnnotation *annotation = (WaypointAnnotation*)view.annotation;
        [self.missionTableViewController markSelectedRow: [self.waypoints getIndexOfWaypointWithSeq: annotation.waypoint.seq]];
    }
}

- (NSString*) waypointLabelForAnnotationView:(mavlink_mission_item_t)item {
    // This subclass uses the row number
    return [NSString stringWithFormat:@"%ld", (long)[self.waypoints getIndexOfWaypointWithSeq:item.seq]];
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
    WaypointsHolder *currentNavPoints = [self.waypoints navWaypoints];
    if ([currentNavPoints numWaypoints] > 0) {
        // Add a new point slightly to the east of the last one
        mavlink_mission_item_t lastNavItem = [currentNavPoints lastWaypoint];
        pos.latitude  = lastNavItem.x;
        pos.longitude = lastNavItem.y + 0.002; // ~200m equatorially
        if (pos.longitude > 180) {
            pos.longitude -= 360;
        }
    } else if (self.userPosition) {
        // Place the first point near the current user
        pos = self.userPosition.coordinate;
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to determine default waypoint"
                                                        message:@"Place the first waypoint manually, or enable GPS"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    [self.waypoints addWaypoint:[self createDefaultWaypointFromCoords:pos]];
    [self resetWaypoints];
}

// Recognizer for long press gestures => add waypoint
-(void) handleLongPressGesture:(UIGestureRecognizer*)sender {
    if (!(sender.state == UIGestureRecognizerStateBegan))
        return;
    
    // Set the coordinates of the map point being held down
    CLLocationCoordinate2D pos = [self.mapView convertPoint:[sender locationInView:self.mapView] toCoordinateFromView:self.mapView];
    [self.waypoints addWaypoint:[self createDefaultWaypointFromCoords:pos]];
    [self resetWaypoints];
}


- (IBAction)mavTxMissionClicked:(id)sender {
    [[[CommController sharedInstance] mavLinkInterface] startWriteMissionRequest:self.waypoints];
}

- (IBAction)mavRxMissionClicked:(id)sender {
    [[[CommController sharedInstance] mavLinkInterface] startReadMissionRequest];
}

// @protocol MissionItemEditingDelegate
- (WaypointsHolder*) cloneMission {
    return [self.waypoints mutableCopy];
}

- (mavlink_mission_item_t) getMissionItemAtIndex:(NSUInteger)idx {
    return [self.waypoints getWaypoint:idx];
}

- (void) replaceMissionItem:(mavlink_mission_item_t)item atIndex:(NSUInteger)idx {
    [self.waypoints replaceWaypoint:idx with:item]; // Swap in the modified mission item
    [self resetWaypoints]; // Reset the map and table views
}
// end @protocol MissionItemEditingDelegate


- (IBAction)loadDemoMision: (id)sender {
    [[[CommController sharedInstance] mavLinkInterface] loadDemoMission];
}

@end
