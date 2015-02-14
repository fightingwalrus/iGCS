//
//  GCSMapViewController.m
//  iGCS
//
//  Created by Claudio Natoli on 5/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "GCSMapViewController.h"
#import "SWRevealViewController.h"
#import "MainViewController.h"
#import "GaugeViewCommon.h"

#import "MavLinkUtility.h"
#import "MiscUtilities.h"

#import "CommController.h"

#import "CXAlertView.h"

#import "GCSDataManager.h"
#import "GCSCraftModelGenerator.h"


@interface GCSMapViewController ()
@property (nonatomic, strong) MKPointAnnotation *uavPos;
@property (nonatomic, strong) MKAnnotationView  *uavView;

@property (nonatomic, strong) GuidedPointAnnotation *currentGuidedAnnotation;
@property (nonatomic, strong) RequestedPointAnnotation *requestedGuidedAnnotation;

@property (nonatomic, assign) CLLocationCoordinate2D gotoCoordinates;
@property (nonatomic, assign) float gotoAltitude;

@property (nonatomic, assign) BOOL showProposedFollowPos;
@property (nonatomic, strong) NSDate *lastFollowMeUpdate;
@property (nonatomic, assign) uint32_t lastCustomMode;

@property (nonatomic, strong) GCSTelemetryLossOverlayView *telemetryLossView;
@end

enum {
    CONTROL_MODE_RC       = 0,
    CONTROL_MODE_AUTO     = 1,
    CONTROL_MODE_GUIDED   = 2
};

static const double HEARTBEAT_LOSS_WAIT_TIME = 3.0;

static const double FOLLOW_ME_MIN_UPDATE_TIME   = 2.0;
static const double FOLLOW_ME_REQUIRED_ACCURACY = 10.0;

static const NSUInteger VEHICLE_ICON_SIZE = 64;

@implementation GCSMapViewController

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)awakeFromNib {
    self.uavPos = [[MKPointAnnotation alloc] init];
    [self.uavPos setCoordinate:CLLocationCoordinate2DMake(0, 0)];

    self.uavView = [[MKAnnotationView  alloc] initWithAnnotation:self.uavPos reuseIdentifier:@"uavView"];
    self.uavView.image = [GCSMapViewController uavIconForCraft:[GCSDataManager sharedInstance].craft
                                                       withYaw:0];
    self.uavView.userInteractionEnabled = YES;
    self.uavView.centerOffset = CGPointZero;
    
    self.currentGuidedAnnotation   = nil;
    self.requestedGuidedAnnotation = nil;
    
    self.gotoAltitude = 25;
    
    self.showProposedFollowPos = NO;
    self.lastFollowMeUpdate = [NSDate date];
}

+ (UIImage*) uavIconForCraft:(id<GCSCraftModel>)craft withYaw:(double)rotation {
    return [MiscUtilities imageWithImage:craft.icon
                            scaledToSize:CGSizeMake(VEHICLE_ICON_SIZE,VEHICLE_ICON_SIZE)
                                rotation:rotation];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    // Adjust view for iOS6 differences
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
        // This constraint is used to fix the size of the mode segmented control, principally
        // to allow sufficient header space for other labels on supported iPhone (7.0+). Because
        // the constrained width is too narrow for iPad 6.X, we'll just remove it.
        [self.controlModeSegment removeConstraint:self.controlModeSegmentSizeConstraint];
    }
    
	// Do any additional setup after loading the view, typically from a nib.
    [self.mapView addAnnotation:self.uavPos];
    
    // Initialize subviews
    [self.ahIndicatorView setRoll: 0 pitch: 0];
    [self.compassView setHeading: 0];
    
    [self.airspeedView setTitle:@"m/s"];
    [self.airspeedView setScale:20];
    [self.airspeedView setValue:0];
    
    [self.altitudeView setTitle:@"m"];
    [self.altitudeView setScale:200];
    [self.altitudeView setValue:0];
    [self.altitudeView setCeilingThreshold:400 * 0.3048]; // IGCS-44: future user setting
    [self.altitudeView setCeilingThresholdBackground:[[GCSThemeManager sharedInstance] altimeterCeilingBreachColor]];
    [self.altitudeView setCeilingThresholdEnabled:YES];
    
    self.windIconView = [[UIImageView alloc] initWithImage:[MiscUtilities image:[UIImage imageNamed:@"193-location-arrow.png"]
                                                                      withColor:[UIColor redColor]]];
    self.windIconView.frame = CGRectMake(42, 50, self.windIconView.frame.size.width, self.windIconView.frame.size.height);
    [self.mapView addSubview:self.windIconView];
    self.windIconView.transform = CGAffineTransformMakeRotation((WIND_ICON_OFFSET_ANG) * M_PI/180.0f);
    
    self.telemetryLossView = [[GCSTelemetryLossOverlayView alloc] initWithParentView:self.view];
}

- (void)toggleSidebar:(id)sender {
    self.revealViewController.rearViewRevealWidth = 210;
    [self.revealViewController revealToggle:sender];
}

- (void)viewDidUnload {
    [self setDebugConsoleLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}


#pragma mark -
#pragma mark Button Click callbacks

- (IBAction) changeControlModeSegment {
    NSInteger idx = self.controlModeSegment.selectedSegmentIndex;
    DDLogDebug(@"changeControlModeSegment: %ld", (long)idx);
    [self deactivateFollowMe];
    switch (idx) {
        case CONTROL_MODE_RC:
            break;
            
        case CONTROL_MODE_AUTO:
            [[[CommController sharedInstance] mavLinkInterface] issueSetAUTOModeCommand];
            break;
            
        case CONTROL_MODE_GUIDED:
            break;
    }
}

- (void) clearGuidedPositions {
    if (self.currentGuidedAnnotation) {
        [self.mapView removeAnnotation:self.currentGuidedAnnotation];
    }
    self.currentGuidedAnnotation = nil;
    
    if (self.requestedGuidedAnnotation) {
        [self.mapView removeAnnotation:self.requestedGuidedAnnotation];
    }
    self.requestedGuidedAnnotation = nil;
}

- (void) issueGuidedCommand:(CLLocationCoordinate2D)coordinates withAltitude:(float)altitude withFollowing:(BOOL)following {
    DDLogDebug(@" - issueGuidedCommand");
    if (!following) {
        [self deactivateFollowMe];
    }
    
    [self clearGuidedPositions];

    // Drop an icon for the proposed GUIDED point
    self.currentGuidedAnnotation = [[GuidedPointAnnotation alloc] initWithCoordinate:coordinates];
    [self.mapView addAnnotation:self.currentGuidedAnnotation];
    [self.mapView setNeedsDisplay];

    // As of APM:Copter 3.2 we *must* set mode to guided however we don't want to
    // do this for APM:Plane
    if ([GCSDataManager sharedInstance].craft.setModeBeforeGuidedItems) {
        [[[CommController sharedInstance] mavLinkInterface] issueSetGuidedModeCommand];
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
         [[[CommController sharedInstance] mavLinkInterface] issueGOTOCommand:coordinates withAltitude:altitude];
    });
}

- (void) followMeControlChange:(FollowMeCtrlValues*)vals {
    self.showProposedFollowPos = YES;
}

- (void) deactivateFollowMe {
    self.showProposedFollowPos = NO;
}

+ (BOOL) isAcceptableFollowMePosition:(CLLocation*)pos {
    return (pos.horizontalAccuracy >= 0 && pos.horizontalAccuracy <= FOLLOW_ME_REQUIRED_ACCURACY);
}

- (void) updateFollowMePosition:(FollowMeCtrlValues*)ctrlValues {
    // Determine user coord
    // CLLocationCoordinate2D userCoord = CLLocationCoordinate2DMake(47.258842, 11.331070); // Waypoint 0 in demo mission - useful for HIL testing
    CLLocationCoordinate2D userCoord = self.userPosition.coordinate;
    
    // Determine new position
    double bearing  = M_PI + (2 * M_PI * ctrlValues.bearing);
    double distance = (5 + 195 * ctrlValues.distance); // 5 - 200 m away
    float fmHeightOffset = (30 * ctrlValues.altitudeOffset);  // 0 -  30 m relative to home
    
    static const double R = 6371009.0; // (approx) mean Earth radius in m
    
    double userLat  = userCoord.latitude *DEG2RAD;
    double userLong = userCoord.longitude*DEG2RAD;
    
    // Compute follow me coordinates
    double angD = distance/R;
    double followMeLat  = asin(sin(userLat)*cos(angD) + cos(userLat)*sin(angD)*cos(bearing));
    double followMeLong = userLong + atan2(sin(bearing)*sin(angD)*cos(userLat), cos(angD) - sin(userLat)*sin(followMeLat));
    followMeLong = fmod((followMeLong + 3*M_PI), (2*M_PI)) - M_PI;

    CLLocationCoordinate2D fmCoords = CLLocationCoordinate2DMake(followMeLat*RAD2DEG, followMeLong*RAD2DEG);
    
    // Update map
    if (self.requestedGuidedAnnotation) {
        [self.mapView removeAnnotation:self.requestedGuidedAnnotation];
    }
    
    if (self.showProposedFollowPos) {
        self.requestedGuidedAnnotation = [[RequestedPointAnnotation alloc] initWithCoordinate:fmCoords];
        [self.mapView addAnnotation:self.requestedGuidedAnnotation];
        [self.mapView setNeedsDisplay];
    }

    DDLogDebug(@"FollowMe lat/long: %f,%f [accuracy: %f]", followMeLat*RAD2DEG, followMeLong*RAD2DEG, self.userPosition.horizontalAccuracy);
    if (ctrlValues.isActive &&
        (-[self.lastFollowMeUpdate timeIntervalSinceNow]) > FOLLOW_ME_MIN_UPDATE_TIME &&
        [GCSMapViewController isAcceptableFollowMePosition:self.userPosition]) {
        self.lastFollowMeUpdate = [NSDate date];
        
        [self issueGuidedCommand:fmCoords withAltitude:fmHeightOffset withFollowing:YES];
    }
}

+ (NSString*) formatGotoAlertMessage:(CLLocationCoordinate2D)coord withAlt:(float)alt {
    return [NSString stringWithFormat:@"%@, %@\nAlt: %0.1fm\n(pan up/down to change)",
            [MiscUtilities prettyPrintCoordAxis:coord.latitude  as:GCSLatitude],
            [MiscUtilities prettyPrintCoordAxis:coord.longitude as:GCSLongitude],
            alt];
}

// Recognizer for long press gestures => GOTO point
-(void)handleLongPressGesture:(UIGestureRecognizer*)sender {
    if (sender.state != UIGestureRecognizerStateBegan)
        return;

    // Set the coordinates of the map point being held down
    self.gotoCoordinates = [self.mapView convertPoint:[sender locationInView:self.mapView] toCoordinateFromView:self.mapView];
    
    // Confirm acceptance of GOTO point
    CXAlertView *alertView = [[CXAlertView alloc] initWithTitle:@"Fly-to position?"
                                                        message:[GCSMapViewController formatGotoAlertMessage:self.gotoCoordinates
                                                                                                     withAlt:self.gotoAltitude]
                                              cancelButtonTitle:nil];
    [alertView addButtonWithTitle:@"Confirm" // Order buttons as per Apple's HIG ("destructive" action on left)
                             type:CXAlertViewButtonTypeCustom
                          handler:^(CXAlertView *alertView, CXAlertButtonItem *button) {
                              [self issueGuidedCommand:self.gotoCoordinates withAltitude:self.gotoAltitude withFollowing:NO];
                              [alertView dismiss];
                          }];
    [alertView addButtonWithTitle:@"Cancel"
                             type:CXAlertViewButtonTypeCustom
                          handler:^(CXAlertView *alertView, CXAlertButtonItem *button) {
                              [alertView dismiss];
                          }];
    alertView.showBlurBackground = YES;

    // Add pan gesture to allow modification of target altitude
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handlePanGesture:)];
    panGesture.minimumNumberOfTouches = 1;
    panGesture.maximumNumberOfTouches = 1;
    [alertView addGestureRecognizer:panGesture];

    [alertView show];
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)sender {
    CGPoint translate = [sender translationInView:self.view];

    static CGPoint lastTranslate;
    if (sender.state == UIGestureRecognizerStateBegan) {
        lastTranslate = translate;
        return;
    }
    
    self.gotoAltitude += (lastTranslate.y-translate.y)/10;
    lastTranslate = translate;
    
    CXAlertView *alertView = (CXAlertView*)(sender.view);
    [(UILabel*)[alertView contentView] setText:[GCSMapViewController formatGotoAlertMessage:self.gotoCoordinates
                                                                                    withAlt:self.gotoAltitude]];
}

- (void) rescheduleHeartbeatLossCheck {
    [NSObject cancelPreviousPerformRequestsWithTarget:self.telemetryLossView selector:@selector(show) object:nil];
    [self.telemetryLossView hide];
    [self.telemetryLossView performSelector:@selector(show) withObject:nil afterDelay:HEARTBEAT_LOSS_WAIT_TIME];
}

- (void) handlePacket:(mavlink_message_t*)msg {
    
    switch (msg->msgid) {
        /*
        // Temporarily disabled in favour of MAVLINK_MSG_ID_GPS_RAW_INT
        case MAVLINK_MSG_ID_GLOBAL_POSITION_INT: {
            mavlink_global_position_int_t gpsPosIntPkt;
            mavlink_msg_global_position_int_decode(msg, &gpsPosIntPkt);
            
            CLLocationCoordinate2D pos = CLLocationCoordinate2DMake(gpsPosIntPkt.lat/10000000.0, gpsPosIntPkt.lon/10000000.0);
            [uavPos setCoordinate:pos];
            [self addToTrack:pos];
        }
        break;
        */
        case MAVLINK_MSG_ID_GPS_RAW_INT: {
            mavlink_gps_raw_int_t gpsRawIntPkt;
            mavlink_msg_gps_raw_int_decode(msg, &gpsRawIntPkt);
            
            CLLocationCoordinate2D pos = CLLocationCoordinate2DMake(gpsRawIntPkt.lat/10000000.0, gpsRawIntPkt.lon/10000000.0);
            [self.uavPos setCoordinate:pos];
            [self addToTrack:pos];
        }
        break;
            
        case MAVLINK_MSG_ID_ATTITUDE: {
            mavlink_attitude_t attitudePkt;
            mavlink_msg_attitude_decode(msg, &attitudePkt);
            
            [self.ahIndicatorView setRoll:-attitudePkt.roll pitch:attitudePkt.pitch];
            [self.ahIndicatorView requestRedraw];
        }
        break;

        case MAVLINK_MSG_ID_VFR_HUD: {
            mavlink_vfr_hud_t  vfrHudPkt;
            mavlink_msg_vfr_hud_decode(msg, &vfrHudPkt);
            
            self.uavView.image = [GCSMapViewController uavIconForCraft:[GCSDataManager sharedInstance].craft
                                                               withYaw:vfrHudPkt.heading * DEG2RAD];
            
            [self.compassView setHeading:vfrHudPkt.heading];
            [self.airspeedView setValue:vfrHudPkt.airspeed]; // m/s
            [self.altitudeView setValue:vfrHudPkt.alt];      // m

            [self.compassView  requestRedraw];
            [self.airspeedView requestRedraw];
            [self.altitudeView requestRedraw];
        }
        break;
            
        case MAVLINK_MSG_ID_NAV_CONTROLLER_OUTPUT: {
            mavlink_nav_controller_output_t navCtrlOutPkt;
            mavlink_msg_nav_controller_output_decode(msg, &navCtrlOutPkt);
            
            [self.compassView setNavBearing:navCtrlOutPkt.nav_bearing];
            [self.airspeedView setTargetDelta:navCtrlOutPkt.aspd_error]; // m/s
            [self.altitudeView setTargetDelta:navCtrlOutPkt.alt_error];  // m
        }
        break;
            
        case MAVLINK_MSG_ID_MISSION_CURRENT: {
            mavlink_mission_current_t currentWaypoint;
            mavlink_msg_mission_current_decode(msg, &currentWaypoint);
            [self maybeUpdateCurrentWaypoint:currentWaypoint.seq];
        }
        break;
            
        case MAVLINK_MSG_ID_SYS_STATUS: {
            mavlink_sys_status_t sysStatus;
            mavlink_msg_sys_status_decode(msg, &sysStatus);
            [self.voltageLabel setText:[NSString stringWithFormat:@"%0.1fV", sysStatus.voltage_battery/1000.0f]];
            [self.currentLabel setText:[NSString stringWithFormat:@"%0.1fA", sysStatus.current_battery/100.0f]];
        }
        break;

        case MAVLINK_MSG_ID_WIND: {
            mavlink_wind_t wind;
            mavlink_msg_wind_decode(msg, &wind);
            _windIconView.transform = CGAffineTransformMakeRotation(((360 + (NSInteger)wind.direction + WIND_ICON_OFFSET_ANG) % 360) * M_PI/180.0f);
        }
        break;
            
        case MAVLINK_MSG_ID_HEARTBEAT: {
            mavlink_heartbeat_t heartbeat;
            mavlink_msg_heartbeat_decode(msg, &heartbeat);
            
            // We got a heartbeat, so...
            [self rescheduleHeartbeatLossCheck];

            // Mutate existing craft, or replace if required (e.g. type has changed)
            [GCSDataManager sharedInstance].craft = [GCSCraftModelGenerator updateOrReplaceModel:[GCSDataManager sharedInstance].craft
                                                                                     withCurrent:heartbeat];
            
            // Update custom mode and armed status labels
            BOOL isArmed = (heartbeat.base_mode & MAV_MODE_FLAG_SAFETY_ARMED);
            [self.armedLabel setText:isArmed ? @"Armed" : @"Disarmed"];
            [self.armedLabel setTextColor:isArmed ? [UIColor redColor] : [UIColor greenColor]];
            [self.customModeLabel setText:[MavLinkUtility mavCustomModeToString:heartbeat]];

            NSInteger idx = CONTROL_MODE_RC;
            if ([GCSDataManager sharedInstance].craft.isInAutoMode) {
                idx = CONTROL_MODE_AUTO;
            } else if ([GCSDataManager sharedInstance].craft.isInGuidedMode) {
                idx = CONTROL_MODE_GUIDED;
            }
            
            // Change the segmented control to reflect the heartbeat
            if (idx != self.controlModeSegment.selectedSegmentIndex) {
                self.controlModeSegment.selectedSegmentIndex = idx;
            }
            
            // If the current mode is not a GUIDED mode, and has just changed
            //   - unconditionally switch out of Follow Me mode
            //   - clear the guided position annotation markers
            if (![GCSDataManager sharedInstance].craft.isInGuidedMode && heartbeat.custom_mode != _lastCustomMode) {
                [self deactivateFollowMe];
                [self clearGuidedPositions];
            }
            _lastCustomMode = heartbeat.custom_mode;
        }
        break;
    }
}

// Handle taps on "Set Waypoint" inside WaypointAnnotation view callouts
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    if ([[view annotation] isKindOfClass:[WaypointAnnotation class]]) {
        WaypointAnnotation *annotation = (WaypointAnnotation*)[view annotation];
        mavlink_mission_item_t item = annotation.waypoint;
        [[[CommController sharedInstance] mavLinkInterface] startSetWaypointRequest:item.seq];
    }
}

- (void) customizeWaypointAnnotationView:(MKAnnotationView*)view {
    // Add a Set Waypoint button
    UIButton *setWPButton = [UIButton buttonWithType:UIButtonTypeCustom];
    setWPButton.frame = CGRectMake(0, 0, 90, 32);
    [setWPButton setTitle:@"Set Waypoint" forState:UIControlStateNormal];
    [setWPButton setTitleColor: [UIColor whiteColor] forState:UIControlStateNormal];
    setWPButton.titleLabel.font = [UIFont fontWithName: @"Helvetica" size: 14];
    [setWPButton setBackgroundImage:[MiscUtilities imageWithColor:[UIColor darkGrayColor]] forState:UIControlStateNormal];
    setWPButton.layer.cornerRadius = 6.0;
    setWPButton.layer.borderWidth  = 1.0;
    setWPButton.layer.borderColor = [UIColor darkTextColor].CGColor;
    setWPButton.clipsToBounds = YES;
    view.rightCalloutAccessoryView = setWPButton;
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation {
    MKAnnotationView* v = [super mapView:theMapView viewForAnnotation:annotation];
    if (v) return v;
    
    // Handle our custom point annotations
    if ([annotation isKindOfClass:[CustomPointAnnotation class]]) {
        CustomPointAnnotation *customPoint = (CustomPointAnnotation*)annotation;
        
        MKAnnotationView *view = [self.mapView dequeueReusableAnnotationViewWithIdentifier:[customPoint viewIdentifier]];
        if (view) {
            view.annotation = customPoint;
        } else {
            view = [[MKAnnotationView alloc] initWithAnnotation:customPoint reuseIdentifier:[customPoint viewIdentifier]];
            [view.layer removeAllAnimations];
        }
        
        view.enabled = YES;
        view.canShowCallout = YES;
        view.centerOffset = CGPointZero;
        view.image = [MiscUtilities image:[UIImage imageNamed:@"13-target.png"]
                                withColor:[customPoint color]];
        
        if ([customPoint doAnimation]) {
            [WaypointMapBaseController animateMKAnnotationView:view from:1.2 to:0.8 duration:2.0];
        }
        return view;
    }
    
    if ([annotation isKindOfClass:[MKPointAnnotation class]]) {
        return self.uavView;
    }
    
    return nil;
}

@end
