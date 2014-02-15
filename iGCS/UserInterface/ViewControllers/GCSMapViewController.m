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
#import "AppDelegate.h"

#import "DebugLogger.h"

@implementation GCSMapViewController

@synthesize windIconView;
@synthesize ahIndicatorView;
@synthesize compassView;
@synthesize airspeedView;
@synthesize altitudeView;

@synthesize voltageLabel;
@synthesize currentLabel;

// 3 modes
//  * auto (initiates/returns to mission)
//  * misc (manual, stabilize, etc; not selectable)
//  * guided (goto/follow me)
@synthesize controlModeSegment;

enum {
    CONTROL_MODE_RC       = 0,
    CONTROL_MODE_AUTO     = 1,
    CONTROL_MODE_GUIDED   = 2
};

#ifdef VIDEOSTREAMING
@synthesize kxMovieVC = _kxMovieVC;
@synthesize availableStreams = _availableStreams;
#endif

static const double FOLLOW_ME_MIN_UPDATE_TIME   = 2.0;
static const double FOLLOW_ME_REQUIRED_ACCURACY = 10.0;

static const int AIRPLANE_ICON_SIZE = 48;

#define kMaxPacketSize 1024
#define kGCSBryansTestStream @"kGCSBryansTestStream"
#define kGCSZ3Stream @"kGCSZ3Stream"
#define kGCSVideoScaleFactor 0.4

// GameKit Session ID for app
#define kTankSessionID @"groundStation"


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
    
    // Release any cached data, images, etc that aren't in use.
#if DO_NSLOG
    if ([self isViewLoaded]) {
        NSLog(@"\t\tGCSMapViewController::didReceiveMemoryWarning: view is still loaded");
    } else {
        NSLog(@"\t\tGCSMapViewController::didReceiveMemoryWarning: view is NOT loaded");
    }
#endif
}

- (void)awakeFromNib {
    
    uavPos  = [[MKPointAnnotation alloc] init];
    [uavPos setCoordinate:CLLocationCoordinate2DMake(0, 0)];

    uavView = [[MKAnnotationView  alloc] initWithAnnotation:uavPos reuseIdentifier:@"uavView"];
    uavView.image = [MiscUtilities imageWithImage: [UIImage imageNamed:@"airplane.png"]
                                     scaledToSize:CGSizeMake(AIRPLANE_ICON_SIZE,AIRPLANE_ICON_SIZE)
                                         rotation: 0];
    uavView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(airplanTapped:)];
    [uavView addGestureRecognizer:tap];
    uavView.centerOffset = CGPointMake(0, 0);
    
    currentGuidedAnnotation   = nil;
    requestedGuidedAnnotation = nil;
    
    gotoAltitude = 50;
    
    showProposedFollowPos = NO;
    lastFollowMeUpdate = [NSDate date];

#ifdef VIDEOSTREAMING
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectToVideoStream) name:@"com.kxmovie.done" object:nil];
#endif
    
//    // Initialize the video overlay view
//    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
//    videoOverlayView = [[GLKView alloc] initWithFrame:CGRectMake(0,0,48,32) context:_context]; // 32 is max permitted height
//    videoOverlayView.context = _context;
//    videoOverlayView.delegate = self;
//    videoOverlayView.enableSetNeedsDisplay = NO;
//
//    uavPos.title = @"On-board Video"; // Some value is required to ensure callout is displayed
//    uavView.canShowCallout = YES;
//    uavView.leftCalloutAccessoryView  = videoOverlayView;
//
//    [EAGLContext setCurrentContext:_context];
//    glEnable(GL_DEPTH_TEST);
//    glMatrixMode(GL_PROJECTION);
//    glLoadIdentity();
//    glOrthof(0, 1, 0, 1, -1, 1);
//    glViewport(0, 0, videoOverlayView.bounds.size.width, videoOverlayView.bounds.size.height);
//    
//    CADisplayLink* displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(renderVideoOverlayView:)];
//    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

-(NSDictionary *)availableStreams {
    if (!_availableStreams) {
        _availableStreams = [NSMutableDictionary dictionary];
        _availableStreams[kGCSBryansTestStream] = @{@"url": @"rtsp://70.36.196.50/axis-media/media.amp", @"size": [NSValue valueWithCGSize:CGSizeMake(640, 480)], @"minBufferedDuration": @(2.0f), @"maxBufferedDuration": @(6.0f)};
        
        NSString *bryansTestStreamURL = [NSString stringWithFormat:@"file:/%@",[[NSBundle mainBundle] pathForResource:@"multicast_h264_aac_48000" ofType:@"sdp"]];
        _availableStreams[kGCSZ3Stream] = @{@"url": bryansTestStreamURL, @"size": [NSValue valueWithCGSize:CGSizeMake(1024, 768)], @"minBufferedDuration": @(0.2f), @"maxBufferedDuration": @(0.6f)};
    }
    return (NSDictionary *)_availableStreams;
}

#ifdef VIDEOSTREAMING
-(void)configureVideoStreamWithName:(NSString *) streamName
                     andScaleFactor:(float) scaleFactor {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[KxMovieParameterDisableDeinterlacing] = @(YES);
    params[KxMovieParameterMinBufferedDuration] = self.availableStreams[streamName][@"minBufferedDuration"];
    params[KxMovieParameterMaxBufferedDuration] = self.availableStreams[streamName][@"maxBufferedDuration"];
    self.kxMovieVC = [KxMovieViewController movieViewControllerWithContentPath:self.availableStreams[streamName][@"url"] parameters:params];
    
    NSValue *videoResolution = self.availableStreams[streamName][@"size"];
    CGSize videoDisplaySize = [self CGSizeFromSize:[videoResolution CGSizeValue] withScaleFactor:scaleFactor];
    CGRect f = [self videoFrameWithSize:videoDisplaySize andUAVPoint:uavView.frame.origin];
    NSLog(@"videoFrame: x:%f y:%f w:%f h:%f", f.origin.x, f.origin.y, f.size.width, f.size.height);
    self.kxMovieVC.view.frame  =  f;
}
#endif

-(CGSize)CGSizeFromSize:(CGSize) size
        withScaleFactor:(float) scaleFactor {
    CGSize newSize = CGSizeZero;
    newSize.width = size.width * scaleFactor;
    newSize.height = size.height * scaleFactor;
    return newSize;
}

#ifdef VIDEOSTREAMING
-(void)connectToVideoStream {
    if ([self.kxMovieVC.view isDescendantOfView:self.parentViewController.view]) {
        [self.kxMovieVC.view removeFromSuperview];
    } else {
        [self.parentViewController.view addSubview:self.kxMovieVC.view];
        [self.view bringSubviewToFront:self.kxMovieVC.view];
        [self.kxMovieVC play];
    }
}
#endif

-(CGRect)videoFrameWithSize:(CGSize)size andUAVPoint:(CGPoint) uavPoint{
    CGRect rect = CGRectZero;
    rect.size.height = size.height;
    rect.size.width = size.width;
    rect.origin.x = (self.parentViewController.view.bounds.size.width - (size.width)); //+ size.height + 8;
    rect.origin.y = 20; //uavPoint.y;
    
    return rect;
}

-(void)airplanTapped:(UITapGestureRecognizer *)gesture {
    NSLog(@"airplane tapped");
#ifdef VIDEOSTREAMING
    [self connectToVideoStream];
#endif
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // initialize debug console buffer
    [DebugLogger start:self.debugConsoleLabel];

	// Do any additional setup after loading the view, typically from a nib.
    [map addAnnotation:uavPos];
    
    // Initialize subviews
    [ahIndicatorView setRoll: 0 pitch: 0];
    [compassView setHeading: 0];
    
    [airspeedView setScale:20];
    [airspeedView setValue:0];
    
    [altitudeView setScale:200];
    [altitudeView setValue:0];
    
    windIconView = [[UIImageView alloc] initWithImage:[MiscUtilities image:[UIImage imageNamed:@"193-location-arrow.png"]
                                                                 withColor:[UIColor redColor]]];
    windIconView.frame = CGRectMake(42, 50, windIconView.frame.size.width, windIconView.frame.size.height);
    [map addSubview: windIconView];
    windIconView.transform = CGAffineTransformMakeRotation((WIND_ICON_OFFSET_ANG) * M_PI/180.0f);
}

- (void)toggleSidebar:(id)sender {
    self.revealViewController.rearViewRevealWidth = 210;
    [self.revealViewController revealToggle:sender];
}

- (void)viewDidUnload
{
    [self setDebugConsoleLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

#ifdef VIDEOSTREAMING
    NSString *videoSource = [[NSUserDefaults standardUserDefaults] objectForKey:@"videoSource"];
    NSString *videoDisplayLocation =  [[NSUserDefaults standardUserDefaults] objectForKey:@"videoDisplayLocation"];
    
    float scaleFactor;
    
    if ([videoSource isEqualToString:@"Z3"]) {
        
        if ([videoDisplayLocation isEqualToString:@"corner"]) {
            scaleFactor = 0.4;
        } else {
            scaleFactor = 1.0;
        }
        
        [self configureVideoStreamWithName:kGCSZ3Stream andScaleFactor:scaleFactor];
    }else {
        
        if ([videoDisplayLocation isEqualToString:@"corner"]) {
            scaleFactor = 0.4;
        } else {
            scaleFactor = 1.0;
        }
        [self configureVideoStreamWithName:kGCSBryansTestStream andScaleFactor:scaleFactor];
    }
#endif

}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}


#pragma mark -
#pragma mark Button Click callbacks

- (IBAction) changeControlModeSegment {
    NSInteger idx = controlModeSegment.selectedSegmentIndex;
    NSLog(@"changeControlModeSegment: %d", idx);
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
    if (currentGuidedAnnotation != nil) {
        [map removeAnnotation:currentGuidedAnnotation];
    }
    currentGuidedAnnotation = nil;
    
    if (requestedGuidedAnnotation != nil) {
        [map removeAnnotation:requestedGuidedAnnotation];
    }
    requestedGuidedAnnotation = nil;
}

- (void) issueGuidedCommand:(CLLocationCoordinate2D)coordinates withAltitude:(float)altitude withFollowing:(BOOL)following {
    NSLog(@" - issueGuidedCommand");
    if (!following) {
        [self deactivateFollowMe];
    }
    
    [self clearGuidedPositions];

    // Drop an icon for the proposed GUIDED point
    currentGuidedAnnotation = [[GuidedPointAnnotation alloc] initWithCoordinate:coordinates];
    [map addAnnotation:currentGuidedAnnotation];
    [map setNeedsDisplay];

    [[[CommController sharedInstance] mavLinkInterface] issueGOTOCommand:coordinates withAltitude:altitude];
}


- (void) followMeControlChange:(FollowMeCtrlValues*)vals {
    showProposedFollowPos = YES;
    [self updateFollowMePosition:vals];
}

- (void) deactivateFollowMe {
    [_followMeControlDelegate followMeDeactivate];
    showProposedFollowPos = NO;
}

+ (BOOL) isAcceptableFollowMePosition:(CLLocation*)pos {
    return (pos.horizontalAccuracy >= 0 && pos.horizontalAccuracy <= FOLLOW_ME_REQUIRED_ACCURACY);
}

- (void) updateFollowMePosition:(FollowMeCtrlValues*)ctrlValues {
    // Determine user coord
    // CLLocationCoordinate2D userCoord = CLLocationCoordinate2DMake(47.258842, 11.331070); // Waypoint 0 in demo mission - useful for HIL testing
    CLLocationCoordinate2D userCoord = userPosition.coordinate;
    
    // Determine new position
    float bearing  = M_PI + (2 * M_PI * ctrlValues.bearing);
    float distance = (5 + 195 * ctrlValues.distance); // 5 - 200 m away
    float fmHeightOffset = (30 * ctrlValues.altitudeOffset);  // 0 -  30 m relative to home
    
    static const float R = 6371000;
    
    float userLat  = userCoord.latitude*DEG2RAD;
    float userLong = userCoord.longitude*DEG2RAD;
    
    // FIXME: fix loss of precision that leads to minor offset errors
    float angD = distance/R;
    float followMeLat  = asin(sin(userLat)*cos(angD) + cos(userLat)*sin(angD)*cos(bearing));
    float followMeLong = userLong + atan2(sin(bearing)*sin(angD)*cos(userLat), cos(angD) - sin(userLat)*sin(followMeLat));
    followMeLong = fmod((followMeLong + 3*M_PI), (2*M_PI)) - M_PI;

    CLLocationCoordinate2D fmCoords = CLLocationCoordinate2DMake(followMeLat*RAD2DEG, followMeLong*RAD2DEG);
    
    // Update map
    if (requestedGuidedAnnotation != nil)
        [map removeAnnotation:requestedGuidedAnnotation];
    
    if (showProposedFollowPos) {
        requestedGuidedAnnotation = [[RequestedPointAnnotation alloc] initWithCoordinate:fmCoords];
        [map addAnnotation:requestedGuidedAnnotation];
        [map setNeedsDisplay];
    }

#if DO_NSLOG
    NSLog(@"FollowMe lat/long: %f,%f [accuracy: %f]", followMeLat*RAD2DEG, followMeLong*RAD2DEG, userPosition.horizontalAccuracy);
#endif
    if (ctrlValues.isActive &&
        (-[lastFollowMeUpdate timeIntervalSinceNow]) > FOLLOW_ME_MIN_UPDATE_TIME &&
        [GCSMapViewController isAcceptableFollowMePosition:userPosition]) {
        lastFollowMeUpdate = [NSDate date];
        
        [self issueGuidedCommand:fmCoords withAltitude:fmHeightOffset withFollowing:YES];
    }
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Confirm"]) {
        // Let's go!
        [self issueGuidedCommand:gotoCoordinates withAltitude:gotoAltitude withFollowing:NO];
    }
}

+ (NSString*) formatGotoAlertMessage:(CLLocationCoordinate2D)coord withAlt:(float)alt {
    return [NSString stringWithFormat:@"%@, %@\nAlt: %0.1fm\n(pan up/down to change)",
            [MiscUtilities coordinateToNiceLatLong: coord.longitude isLat:NO],
            [MiscUtilities coordinateToNiceLatLong: coord.latitude  isLat:YES],
            alt];
}

// Recognizer for long press gestures => GOTO point
-(void)handleLongPressGesture:(UIGestureRecognizer*)sender {
    if (sender.state != UIGestureRecognizerStateBegan)
        return;

    // Set the coordinates of the map point being held down
    gotoCoordinates = [map convertPoint:[sender locationInView:map] toCoordinateFromView:map];
    
    // Confirm acceptance of GOTO point
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Fly-to position?"
                                                      message:[GCSMapViewController formatGotoAlertMessage: gotoCoordinates withAlt:gotoAltitude]
                                                     delegate:self
                                            cancelButtonTitle:nil
                                            otherButtonTitles:@"Confirm", @"Cancel", nil];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handlePanGesture:)];
    panGesture.minimumNumberOfTouches = 1;
    panGesture.maximumNumberOfTouches = 1;
    //[message setMultipleTouchEnabled:YES];
    //[message setUserInteractionEnabled:YES];
    [message addGestureRecognizer:panGesture];

    [message show];
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)sender {
    CGPoint translate = [sender translationInView:self.view];

    static CGPoint lastTranslate;
    if (sender.state == UIGestureRecognizerStateBegan) {
        lastTranslate = translate;
        return;
    }
    
    gotoAltitude += (lastTranslate.y-translate.y)/10;
    lastTranslate = translate;
    
    UIAlertView *view = (UIAlertView*)(sender.view);
    [view setMessage:[GCSMapViewController formatGotoAlertMessage: gotoCoordinates withAlt:gotoAltitude]];
}

- (void) handlePacket:(mavlink_message_t*)msg {
    
    switch (msg->msgid) {
        /*
        // Temporarily disabled in favour of MAVLINK_MSG_ID_GPS_RAW_INT
        case MAVLINK_MSG_ID_GLOBAL_POSITION_INT:
        {
            mavlink_global_position_int_t gpsPosIntPkt;
            mavlink_msg_global_position_int_decode(msg, &gpsPosIntPkt);
            
            CLLocationCoordinate2D pos = CLLocationCoordinate2DMake(gpsPosIntPkt.lat/10000000.0, gpsPosIntPkt.lon/10000000.0);
            [uavPos setCoordinate:pos];
            [self addToTrack:pos];
        }
        break;
        */
        case MAVLINK_MSG_ID_GPS_RAW_INT:
        {
            mavlink_gps_raw_int_t gpsRawIntPkt;
            mavlink_msg_gps_raw_int_decode(msg, &gpsRawIntPkt);
            
            CLLocationCoordinate2D pos = CLLocationCoordinate2DMake(gpsRawIntPkt.lat/10000000.0, gpsRawIntPkt.lon/10000000.0);
            [uavPos setCoordinate:pos];
            [self addToTrack:pos];
        }
        break;
            
        case MAVLINK_MSG_ID_ATTITUDE:
        {
            mavlink_attitude_t attitudePkt;
            mavlink_msg_attitude_decode(msg, &attitudePkt);
            
            uavView.image = [MiscUtilities imageWithImage: [UIImage imageNamed:@"airplane.png"]
                                             scaledToSize: CGSizeMake(AIRPLANE_ICON_SIZE,AIRPLANE_ICON_SIZE)
                                                 rotation: attitudePkt.yaw];
            
            [ahIndicatorView setRoll:-attitudePkt.roll pitch:attitudePkt.pitch];
            [ahIndicatorView requestRedraw];
        }
        break;

        case MAVLINK_MSG_ID_VFR_HUD:
        {
            mavlink_vfr_hud_t  vfrHudPkt;
            mavlink_msg_vfr_hud_decode(msg, &vfrHudPkt);
            
            [compassView setHeading:vfrHudPkt.heading];
            [airspeedView setValue:vfrHudPkt.airspeed]; // m/s
            [altitudeView setValue:vfrHudPkt.alt];      // m

            [compassView  requestRedraw];
            [airspeedView requestRedraw];
            [altitudeView requestRedraw];
        }
        break;
            
        case MAVLINK_MSG_ID_NAV_CONTROLLER_OUTPUT:
        {
            mavlink_nav_controller_output_t navCtrlOutPkt;
            mavlink_msg_nav_controller_output_decode(msg, &navCtrlOutPkt);
            
            [compassView setNavBearing:navCtrlOutPkt.nav_bearing];
            [airspeedView setTargetDelta:navCtrlOutPkt.aspd_error]; // m/s
            [altitudeView setTargetDelta:navCtrlOutPkt.alt_error];  // m
        }
        break;
            
        case MAVLINK_MSG_ID_MISSION_CURRENT:
        {
            mavlink_mission_current_t currentWaypoint;
            mavlink_msg_mission_current_decode(msg, &currentWaypoint);
            [self maybeUpdateCurrentWaypoint:currentWaypoint.seq];
        }
        break;
            
        case MAVLINK_MSG_ID_SYS_STATUS:
        {
            mavlink_sys_status_t sysStatus;
            mavlink_msg_sys_status_decode(msg, &sysStatus);
            [voltageLabel setText:[NSString stringWithFormat:@"%0.1fV", sysStatus.voltage_battery/1000.0f]];
            [currentLabel setText:[NSString stringWithFormat:@"%0.1fA", sysStatus.current_battery/100.0f]];
        }
        break;

        case MAVLINK_MSG_ID_WIND:
        {
            mavlink_wind_t wind;
            mavlink_msg_wind_decode(msg, &wind);
            windIconView.transform = CGAffineTransformMakeRotation(((360 + (int)wind.direction + WIND_ICON_OFFSET_ANG) % 360) * M_PI/180.0f);
        }
        break;
            
        case MAVLINK_MSG_ID_HEARTBEAT:
        {
            mavlink_heartbeat_t heartbeat;
            mavlink_msg_heartbeat_decode(msg, &heartbeat);
            BOOL isArmed = (heartbeat.base_mode & MAV_MODE_FLAG_SAFETY_ARMED);
            [_armedLabel setText:isArmed ? @"Armed" : @"Disarmed"];
            [_armedLabel setTextColor:isArmed ? [UIColor redColor] : [UIColor greenColor]];
            [_customModeLabel setText:[MavLinkUtility mavCustomModeToString:  heartbeat]];

            NSInteger idx = CONTROL_MODE_RC;
            switch (heartbeat.custom_mode)
            {
                case AUTO:
                    idx = CONTROL_MODE_AUTO;
                    break;

                case GUIDED:
                    idx = CONTROL_MODE_GUIDED;
                    break;
            }
            
            // Change the segmented control to reflect the heartbeat
            if (idx != controlModeSegment.selectedSegmentIndex) {
                controlModeSegment.selectedSegmentIndex = idx;
            }
            
            // If the current mode is not GUIDED, and has just changed
            //   - unconditionally switch out of Follow Me mode
            //   - clear the guided position annotation markers
            if (heartbeat.custom_mode != GUIDED && heartbeat.custom_mode != lastCustomMode) {
                [self deactivateFollowMe];
                [self clearGuidedPositions];
            }
            lastCustomMode = heartbeat.custom_mode;
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

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    MKAnnotationView* v = [super mapView:theMapView viewForAnnotation:annotation];
    if (v != nil)
        return v;
    
    // Handle our custom point annotations
    if ([annotation isKindOfClass:[CustomPointAnnotation class]]) {
        CustomPointAnnotation *customPoint = (CustomPointAnnotation*)annotation;
        
        MKAnnotationView *view = (MKAnnotationView*) [map dequeueReusableAnnotationViewWithIdentifier:[customPoint viewIdentifier]];
        if (view == nil) {
            view = [[MKAnnotationView alloc] initWithAnnotation:customPoint reuseIdentifier:[customPoint viewIdentifier]];
            [view.layer removeAllAnimations];
        } else {
            view.annotation = customPoint;
        }
        
        view.enabled = YES;
        view.canShowCallout = YES;
        view.centerOffset = CGPointMake(0,0);      
        view.image = [MiscUtilities image:[UIImage imageNamed:@"13-target.png"]
                                withColor:[customPoint color]];
        
        if ([customPoint doAnimation]) {
            CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
            scaleAnimation.duration = 2.0;
            scaleAnimation.repeatCount = HUGE_VAL;
            scaleAnimation.autoreverses = YES;
            scaleAnimation.fromValue = [NSNumber numberWithFloat:1.2];
            scaleAnimation.toValue = [NSNumber numberWithFloat:0.8];
            [view.layer addAnimation:scaleAnimation forKey:@"scale"];
        }
        return view;
    }
    
    if ([annotation isKindOfClass:[MKPointAnnotation class]]) {
        return uavView;
    }
    
    return nil;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    // FIXME: should check if callout is actually displayed before performing
    // any serious work (alt: check in renderVideoOverlayView)
    static bool goingUp = false;
    static float redVal = 0;
    
    redVal += goingUp ? 0.02 : -0.02;
    if (redVal >= 1.0) {
        redVal = 1.0;
        goingUp = NO;
    }
    if (redVal <= 0.0) {
        redVal = 0.0;
        goingUp = YES;
    }
    
    //NSLog(@"glkView");
    glClearColor(redVal, 0.0, 1.0, 0.1);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
}

- (void)renderVideoOverlayView:(CADisplayLink*)displayLink {
    [videoOverlayView display];
}

// Override the base locationManager: didUpdateLocations
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *location = locationManager.location;
    NSTimeInterval age = -[location.timestamp timeIntervalSinceNow];
#if DO_NSLOG
    NSLog(@"locationManager didUpdateLocations: %@ (age = %0.1fs)", location.description, age);
#endif
    if (age > 5.0) return;
    
    [_followMeControlDelegate followMeLocationAccuracy:location.horizontalAccuracy isAcceptable:[GCSMapViewController isAcceptableFollowMePosition:location]];
    
    userPosition = location;
    [self updateFollowMePosition:[_followMeControlDelegate followMeControlValues]];
}

@end
