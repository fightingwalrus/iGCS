//
//  FirstViewController.m
//  iGCS
//
//  Created by Claudio Natoli on 5/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "GCSMapViewController.h"

#import "MainViewController.h"
#import "GaugeViewCommon.h"

#import "CommController.h"
#import "AppDelegate.h"

#import "DebugLogger.h"

@implementation GCSMapViewController

@synthesize windIconView;
@synthesize ahIndicatorView;
@synthesize compassView;
@synthesize airspeedView;
@synthesize altitudeView;

@synthesize customModeLabel;
@synthesize baseModeLabel;
@synthesize statusLabel;

@synthesize gpsFixTypeLabel;
@synthesize numSatellitesLabel;

@synthesize sysUptimeLabel;
@synthesize sysVoltageLabel;
@synthesize sysMemFreeLabel;

@synthesize throttleLabel;
@synthesize climbRateLabel;
@synthesize groundSpeedLabel;
@synthesize windDirLabel;
@synthesize windSpeedLabel;
@synthesize windSpeedZLabel;
@synthesize voltageLabel;
@synthesize currentLabel;

@synthesize userLocationAccuracyLabel;

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

@synthesize followMeSwitch;
@synthesize followMeBearingSlider;
@synthesize followMeDistanceSlider;
@synthesize followMeHeightSlider;

@synthesize kxMovieVC = _kxMovieVC;
@synthesize availableStreams = _availableStreams;

#define kMaxPacketSize 1024
#define kGCSBryansTestStream @"kGCSBryansTestStream"
#define kGCSZ3Stream @"kGCSZ3Stream"
#define kGCSVideoScaleFactor 0.4

// GameKit Session ID for app
#define kTankSessionID @"groundStation"

#define AIRPLANE_ICON_SIZE 48

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
    uavView.image = [GCSMapViewController imageWithImage: [UIImage imageNamed:@"airplane.png"] 
                                                scaledToSize:CGSizeMake(AIRPLANE_ICON_SIZE,AIRPLANE_ICON_SIZE)
                                                rotation: 0];
    uavView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(airplanTapped:)];
    [uavView addGestureRecognizer:tap];
    uavView.centerOffset = CGPointMake(0, 0);
    
    currentGuidedAnnotation   = nil;
    requestedGuidedAnnotation = nil;
    
    gotoAltitude = 50;
    
    showProposedFollowPos = false;
    lastFollowMeUpdate = [NSDate date];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.delegate = self;
    locationManager.distanceFilter = 2.0f;
    [locationManager startUpdatingLocation];

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

-(CGSize)CGSizeFromSize:(CGSize) size
        withScaleFactor:(float) scaleFactor {
    CGSize newSize = CGSizeZero;
    newSize.width = size.width * scaleFactor;
    newSize.height = size.height * scaleFactor;
    return newSize;
}

-(void)connectToVideoStream {
    if ([self.kxMovieVC.view isDescendantOfView:self.parentViewController.view]) {
        [self.kxMovieVC.view removeFromSuperview];
    } else {
        [self.parentViewController.view addSubview:self.kxMovieVC.view];
        [self.view bringSubviewToFront:self.kxMovieVC.view];
        [self.kxMovieVC play];
    }
}

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
    [self connectToVideoStream];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Authenticate the local player as soon as possible
    [self authenticateLocalPlayer];
    
    // initialize debug console buffer
    [DebugLogger start:self.debugConsoleLabel];
    
    //Initialize GK peer variables
    self.peerStatus = kServer;
	//FIXME inherited from sample, I don't like it without a self
    gamePacketNumber = 0;
	self.gameSession = nil;
	self.gamePeerId = nil;
	self.lastHeartbeatDate = nil;
    
    //FIXME This will prevent app approval
	NSString *uid = [[UIDevice currentDevice] uniqueIdentifier];
	
    //FIXME inherited from sample, I don't like it without a self
    gamePacketNumber = 0;
	gameUniqueID = [uid hash];

	// Do any additional setup after loading the view, typically from a nib.
    [map addAnnotation:uavPos];
    
    // Add recognizer for long holds => GOTO point
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] 
                                                      initWithTarget:self action:@selector(handleLongPressGesture:)];
    longPressGesture.numberOfTapsRequired = 0;
    longPressGesture.numberOfTouchesRequired = 1;
    longPressGesture.minimumPressDuration = 1.0;
    [map addGestureRecognizer:longPressGesture];
    
    // Initialize subviews
    [ahIndicatorView setRoll: 0 pitch: 0];
    [compassView setHeading: 0];
    
    [airspeedView setScale:10];
    [airspeedView setValue:0];
    
    [altitudeView setScale:100];
    [altitudeView setValue:0];
    
    windIconView = [[UIImageView alloc] initWithImage:[GCSMapViewController image:[UIImage imageNamed:@"193-location-arrow.png"]
                                                                        withColor:[UIColor redColor]]];
    windIconView.frame = CGRectMake(10, 10, windIconView.frame.size.width, windIconView.frame.size.height);
    [map addSubview: windIconView];
    windIconView.transform = CGAffineTransformMakeRotation((WIND_ICON_OFFSET_ANG) * M_PI/180.0f);
    
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

     NSString *videoSource = [[NSUserDefaults standardUserDefaults] objectForKey:@"videoSource"];
    
    if ([videoSource isEqualToString:@"Z3"]) {
        [self configureVideoStreamWithName:kGCSZ3Stream andScaleFactor:kGCSVideoScaleFactor];
    }else {
        [self configureVideoStreamWithName:kGCSBryansTestStream andScaleFactor:kGCSVideoScaleFactor];
    }

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

- (IBAction) readMissionButtonClick {
    [[CommController appMLI] issueStartReadMissionRequest];
}

- (IBAction) changeControlModeSegment {
    NSInteger idx = controlModeSegment.selectedSegmentIndex;
    NSLog(@"changeControlModeSegment: %d", idx);
    [self disableFollowMeMode];
    switch (idx) {
        case CONTROL_MODE_RC:
            break;
            
        case CONTROL_MODE_AUTO:
            [[CommController appMLI] issueSetAUTOModeCommand];
            break;
            
        case CONTROL_MODE_GUIDED:
            break;
    }
}

- (IBAction) followMeSliderChanged:(UISlider*)slider {
    showProposedFollowPos = true;
    [self updateFollowMePosition];
}

- (IBAction) followMeSwitchChanged:(UISwitch*)s {
    showProposedFollowPos = true;
    [self updateFollowMePosition];
}

- (void) disableFollowMeMode {
    [followMeSwitch setOn:NO animated:YES];
    showProposedFollowPos = false;
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
        [self disableFollowMeMode];
    }
    
    [self clearGuidedPositions];

    // Drop an icon for the proposed GUIDED point
    currentGuidedAnnotation = [[GuidedPointAnnotation alloc] initWithCoordinate:coordinates];
    [map addAnnotation:currentGuidedAnnotation];
    [map setNeedsDisplay];

    [[CommController appMLI] issueGOTOCommand:coordinates withAltitude:altitude];
}


- (void) updateFollowMePosition {
    // Determine user coord
    // FIXME: get CLLocation from location manager, ensure accurate fix, etc
    CLLocationCoordinate2D userCoord = CLLocationCoordinate2DMake(47.258842, 11.331070);
    //CLLocationCoordinate2D userCoord = userPosition.coordinate;
    
    // Determine new position
    float bearing  = M_PI + (2 * M_PI * followMeBearingSlider.value);
    float distance = (5 + 195 * followMeDistanceSlider.value); // 5 - 200 m away
    followMeHeightOffset = (30 * followMeHeightSlider.value);  // 0 -  30 m relative to home
    
    static const float R = 6371000;
    
    float userLat  = userCoord.latitude*DEG2RAD;
    float userLong = userCoord.longitude*DEG2RAD;
    
    float angD = distance/R;
    float followMeLat  = asin(sin(userLat)*cos(angD) + cos(userLat)*sin(angD)*cos(bearing));
    float followMeLong = userLong + atan2(sin(bearing)*sin(angD)*cos(userLat), cos(angD) - sin(userLat)*sin(followMeLat));
    followMeLong = fmod((followMeLong + 3*M_PI), (2*M_PI)) - M_PI;

    followMeCoords = CLLocationCoordinate2DMake(followMeLat*RAD2DEG, followMeLong*RAD2DEG);
    
    // Update map
    if (requestedGuidedAnnotation != nil)
        [map removeAnnotation:requestedGuidedAnnotation];
    
    if (showProposedFollowPos) {
        requestedGuidedAnnotation = [[RequestedPointAnnotation alloc] initWithCoordinate:followMeCoords];
        [map addAnnotation:requestedGuidedAnnotation];
        [map setNeedsDisplay];
    }
    
    NSLog(@"FollowMe lat/long: %f,%f [accuracy: %f]", followMeLat*RAD2DEG, followMeLong*RAD2DEG, userPosition.horizontalAccuracy);
    if (followMeSwitch.isOn &&
        (-[lastFollowMeUpdate timeIntervalSinceNow]) > FOLLOW_ME_MIN_UPDATE_TIME &&
        userPosition.horizontalAccuracy >= 0 &&
        userPosition.horizontalAccuracy <= FOLLOW_ME_REQUIRED_ACCURACY) {
        lastFollowMeUpdate = [NSDate date];
        
        [self issueGuidedCommand:followMeCoords withAltitude:followMeHeightOffset withFollowing:YES];
    }
}

- (IBAction) externalButtonClick {
    
    GKMatchRequest *request = [[GKMatchRequest alloc] init];
    request.minPlayers = 2;
    NSUInteger friendCount = [self.myFriends count];
    request.maxPlayers = 2;

    //Max realtime friends is 4
    if(friendCount<4)
    {
        request.maxPlayers = friendCount + 1;
        request.playersToInvite = self.myIdentifiers;
    }
    GKMatchmakerViewController *mmvc = [[GKMatchmakerViewController alloc]
                                         initWithMatchRequest:request];
    mmvc.matchmakerDelegate = self;
    [self presentModalViewController:mmvc animated:YES];
    
    //Comment out local for now
    /*
    GKPeerPickerController*		picker;
	picker = [[GKPeerPickerController alloc] init]; // note: picker is released in various picker delegate methods when picker use is done.
	picker.delegate = self;
	[picker show]; // show the Peer Picker
     */
}


#pragma mark -
#pragma mark GameCenter Initialization
- (void) authenticateLocalPlayer
{
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    [localPlayer authenticateWithCompletionHandler:^(NSError *error) {
        if (localPlayer.isAuthenticated)
        {
            // Player was successfully authenticated.
            // Perform additional tasks for the authenticated player.
            [self retrieveFriends];
            [self registerForInvites];

        }
    }];
}

- (void) retrieveFriends
{
    GKLocalPlayer *lp = [GKLocalPlayer localPlayer];
    if (lp.authenticated)
    {
        [lp loadFriendsWithCompletionHandler:^(NSArray *friends, NSError *error) {
            if (friends != nil)
            {
                [self loadPlayerData: friends];
            }
        }];
    }
}

- (void) loadPlayerData: (NSArray *) identifiers
{
    self.myIdentifiers = identifiers;
    [GKPlayer loadPlayersForIdentifiers:identifiers withCompletionHandler:^(NSArray *friends, NSError *error) {
        if (error != nil)
        {
            // Handle the error.
        }
        if (friends != nil)
        {
            // Process the array of GKPlayer objects.
            if ([friends count] > 0)
            {
                [DebugLogger console:@"You have friends!  You aren't a loner after all!"];
                self.myFriends = friends;
            }
            else
            {
                [DebugLogger console:@"There is only but one in the wolfpack"];
            }
        }
    }];
}

- (void) registerForInvites
{
    [GKMatchmaker sharedMatchmaker].inviteHandler = ^(GKInvite *acceptedInvite,
                                                      NSArray *playersToInvite) {
        // Insert application-specific code here to clean up any games in progress.
        NSLog(@"Invite received");
        if (acceptedInvite)
        {
            GKMatchmakerViewController *mmvc = [[GKMatchmakerViewController alloc]
                                                 initWithInvite:acceptedInvite];
            mmvc.matchmakerDelegate = self;
            [self presentModalViewController:mmvc animated:YES];
        }
        else if (playersToInvite)
        {
            GKMatchRequest *request = [[GKMatchRequest alloc] init];
            request.minPlayers = 2;
            request.maxPlayers = 4;
            request.playersToInvite = playersToInvite;
            GKMatchmakerViewController *mmvc = [[GKMatchmakerViewController alloc]
                                                 initWithMatchRequest:request];
            mmvc.matchmakerDelegate = self;
            [self presentModalViewController:mmvc animated:YES];
        }
    };
    
}

- (void) inviteFriends: (NSArray*) identifiers
{
    GKFriendRequestComposeViewController *friendRequestViewController = [[GKFriendRequestComposeViewController alloc] init];
    //FIXME fill out these delegate friend methods
    friendRequestViewController.composeViewDelegate = self;
    if (identifiers)
    {
        [friendRequestViewController addRecipientsWithPlayerIDs: identifiers];
    }
    [self presentViewController: friendRequestViewController animated: YES completion:nil];
}

- (void)friendRequestComposeViewControllerDidFinish:(GKFriendRequestComposeViewController *)viewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark Peer Picker Related Methods

-(void)startPicker {
	GKPeerPickerController*		picker;
	
	self.gameState = kStatePicker;			// we're going to do Multiplayer!
	
	picker = [[GKPeerPickerController alloc] init]; // note: picker is released in various picker delegate methods when picker use is done.
	picker.delegate = self;
	[picker show]; // show the Peer Picker
}

#pragma mark GKPeerPickerControllerDelegate Methods

- (void)peerPickerControllerDidCancel:(GKPeerPickerController *)picker {
	// Peer Picker automatically dismisses on user cancel. No need to programmatically dismiss.
    
	// autorelease the picker.
	picker.delegate = nil;
	
	// invalidate and release game session if one is around.
	if(self.gameSession != nil)	{
		[self invalidateSession:self.gameSession];
		self.gameSession = nil;
	}
	
	// go back to start mode
	self.gameState = kStateStartGame;
}

/*
 *	Note: No need to implement -peerPickerController:didSelectConnectionType: delegate method since this app does not support multiple connection types.
 *		- see reference documentation for this delegate method and the GKPeerPickerController's connectionTypesMask property.
 */

//
// Provide a custom session that has a custom session ID. This is also an opportunity to provide a session with a custom display name.
//
- (GKSession *)peerPickerController:(GKPeerPickerController *)picker sessionForConnectionType:(GKPeerPickerConnectionType)type {
	GKSession *session = [[GKSession alloc] initWithSessionID:kTankSessionID displayName:nil sessionMode:GKSessionModePeer];
	return session; // peer picker retains a reference, so autorelease ours so we don't leak.
}

- (void)peerPickerController:(GKPeerPickerController *)picker didConnectPeer:(NSString *)peerID toSession:(GKSession *)session {
	// Remember the current peer.
	self.gamePeerId = peerID;  // copy
	
	// Make sure we have a reference to the game session and it is set up
	self.gameSession = session; // retain
	self.gameSession.delegate = self;
	[self.gameSession setDataReceiveHandler:self withContext:NULL];
	
	// Done with the Peer Picker so dismiss it.
	[picker dismiss];
	picker.delegate = nil;
	
	// Start Multiplayer game by entering a cointoss state to determine who is server/client.
	self.gameState = kStateMultiplayerCointoss;
}


#pragma mark -
#pragma mark GKMatchMakerDelegate

//Completing a Match Request
- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFindMatch:(GKMatch *)match
{
    [viewController dismissModalViewControllerAnimated:YES];
    self.myMatch = match; // Use a retaining property to retain the match.
    match.delegate = self;
    if (!self.matchStarted && match.expectedPlayerCount == 0)
    {
        self.matchStarted = YES;
        // Insert application-specific code to begin the match.
        NSLog(@"Take it from here");
    }
}
- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFindPlayers:(NSArray *)playerIDs
{
    NSLog(@"Did findFindPlayers");
    
}
//Handling Cancellations (required method)
- (void)matchmakerViewControllerWasCancelled:(GKMatchmakerViewController *)viewController
{
    NSLog(@"MatchMaker Cancelled");
    [viewController dismissModalViewControllerAnimated:YES];
}
//Handling Errors (required method)
- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFailWithError:(NSError *)error
{
    NSLog(@"Error occurred:%@",error);
    [viewController dismissModalViewControllerAnimated:YES];
}
//Hosted Matches not yet supported
//Hosted Matches
//– matchmakerViewController:didReceiveAcceptFromHostedPlayer:


#pragma mark -
#pragma mark GKMatchDelegate Methods

- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID
{
    NSLog(@"Got some data!!!!");
}

#pragma mark -
#pragma mark Session Related Methods

//
// invalidate session
//
- (void)invalidateSession:(GKSession *)session {
	if(session != nil) {
		[session disconnectFromAllPeers];
		session.available = NO;
		[session setDataReceiveHandler: nil withContext: NULL];
		session.delegate = nil;
	}
}

#pragma mark Data Send/Receive Methods

/*
 * Getting a data packet. This is the data receive handler method expected by the GKSession.
 * We set ourselves as the receive data handler in the -peerPickerController:didConnectPeer:toSession: method.
 */
- (void)receiveData:(NSData *)data fromPeer:(NSString *)peer inSession:(GKSession *)session context:(void *)context {
	static int lastPacketTime = -1;
	unsigned char *incomingPacket = (unsigned char *)[data bytes];
	int *pIntData = (int *)&incomingPacket[0];
	//
	// developer  check the network time and make sure packers are in order
	//
	int packetTime = pIntData[0];
	int packetID = pIntData[1];
	if(packetTime < lastPacketTime && packetID != NETWORK_COINTOSS) {
		return;
	}
	
	lastPacketTime = packetTime;
	switch( packetID ) {
		case NETWORK_COINTOSS:
        {
            // coin toss to determine roles of the two players
            int coinToss = pIntData[2];
            // if other player's coin is higher than ours then that player is the server
            if(coinToss > gameUniqueID) {
                self.peerStatus = kClient;
            }
        }
			break;
		case NETWORK_HEARTBEAT:
        {
            // Received heartbeat data with other player's position, destination, and firing status.
            
            /*
             // update the other player's info from the heartbeat
             tankInfo *ts = (tankInfo *)&incomingPacket[8];		// tank data as seen on other client
             int peer = (self.peerStatus == kServer) ? kClient : kServer;
             tankInfo *ds = &tankStats[peer];					// same tank, as we see it on this client
             memcpy( ds, ts, sizeof(tankInfo) );
             */
            
            // update heartbeat timestamp
            self.lastHeartbeatDate = [NSDate date];
            
            // if we were trying to reconnect, set the state back to multiplayer as the peer is back
            if(self.gameState == kStateMultiplayerReconnect) {
                if(self.connectionAlert && self.connectionAlert.visible) {
                    [self.connectionAlert dismissWithClickedButtonIndex:-1 animated:YES];
                }
                self.gameState = kStateMultiplayer;
            }
        }
			break;
		default:
			// error
			break;
	}
}

- (void)sendNetworkPacket:(GKSession *)session packetID:(int)packetID withData:(void *)data ofLength:(int)length reliable:(BOOL)howtosend {
	// the packet we'll send is resued
	static unsigned char networkPacket[kMaxPacketSize];
	const unsigned int packetHeaderSize = 2 * sizeof(int); // we have two "ints" for our header
	
	if(length < (kMaxPacketSize - packetHeaderSize)) { // our networkPacket buffer size minus the size of the header info
		int *pIntData = (int *)&networkPacket[0];
		// header info
		pIntData[0] = gamePacketNumber++;
		pIntData[1] = packetID;
		// copy data in after the header
		memcpy( &networkPacket[packetHeaderSize], data, length );
		
		NSData *packet = [NSData dataWithBytes: networkPacket length: (length+8)];
		if(howtosend == YES) {
			[session sendData:packet toPeers:[NSArray arrayWithObject:self.gamePeerId] withDataMode:GKSendDataReliable error:nil];
		} else {
			[session sendData:packet toPeers:[NSArray arrayWithObject:self.gamePeerId] withDataMode:GKSendDataUnreliable error:nil];
		}
	}
}

#pragma mark GKSessionDelegate Methods

// we've gotten a state change in the session
- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state {
	if(self.gameState == kStatePicker) {
		return;				// only do stuff if we're in multiplayer, otherwise it is probably for Picker
	}
	
	if(state == GKPeerStateDisconnected) {
		// We've been disconnected from the other peer.
		
		// Update user alert or throw alert if it isn't already up
		NSString *message = [NSString stringWithFormat:@"Could not reconnect with %@.", [session displayNameForPeer:peerID]];
		if((self.gameState == kStateMultiplayerReconnect) && self.connectionAlert && self.connectionAlert.visible) {
			self.connectionAlert.message = message;
		}
		else {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Lost Connection" message:message delegate:self cancelButtonTitle:@"End Game" otherButtonTitles:nil];
			self.connectionAlert = alert;
			[alert show];
		}
		
		// go back to start mode
		self.gameState = kStateStartGame; 
	} 
}



- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"OK"]) {
        // Let's go!
        [self issueGuidedCommand:gotoCoordinates withAltitude:gotoAltitude withFollowing:NO];
    }
}


-(void)handleLongPressGesture:(UIGestureRecognizer*)sender {
    if (sender.state != UIGestureRecognizerStateBegan)
        return;

    // Set the coordinates of the map point being held down
    gotoCoordinates = [map convertPoint:[sender locationInView:map] toCoordinateFromView:map];
    
    // Confirm acceptance of GOTO point
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Set GOTO position"
                                                      message:[NSString stringWithFormat:@"%0.5f,%0.5f %0.1fm",
                                                                gotoCoordinates.longitude, gotoCoordinates.latitude, gotoAltitude]
                                                     delegate:self
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:@"Cancel", nil];
    
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
    [view setMessage:[NSString stringWithFormat:@"%0.5f,%0.5f %0.1fm",
                      gotoCoordinates.longitude, gotoCoordinates.latitude, gotoAltitude]];    
}

// FIXME: move the below utilities to some "utils" file
+ (NSString*) mavModeEnumToString:(enum MAV_MODE)mode {
    NSString *str = [NSString stringWithFormat:@""];
    if (mode & MAV_MODE_FLAG_TEST_ENABLED)          str = [str stringByAppendingString:@"Test "];
    if (mode & MAV_MODE_FLAG_AUTO_ENABLED)          str = [str stringByAppendingString:@"Auto "];
    if (mode & MAV_MODE_FLAG_GUIDED_ENABLED)        str = [str stringByAppendingString:@"Guided "];
    if (mode & MAV_MODE_FLAG_STABILIZE_ENABLED)     str = [str stringByAppendingString:@"Stabilize "];
    if (mode & MAV_MODE_FLAG_HIL_ENABLED)           str = [str stringByAppendingString:@"HIL "];
    if (mode & MAV_MODE_FLAG_MANUAL_INPUT_ENABLED)  str = [str stringByAppendingString:@"Manual "];
    if (mode & MAV_MODE_FLAG_CUSTOM_MODE_ENABLED)   str = [str stringByAppendingString:@"Custom "];
    if (!(mode & MAV_MODE_FLAG_SAFETY_ARMED))       str = [str stringByAppendingString:@"(Disarmed)"];
    return str;
}

+ (NSString*) mavStateEnumToString:(enum MAV_STATE)state {
    switch (state) {
        case MAV_STATE_UNINIT:      return @"Uninitialized";
        case MAV_STATE_BOOT:        return @"Boot";
        case MAV_STATE_CALIBRATING: return @"Calibrating";
        case MAV_STATE_STANDBY:     return @"Standby";
        case MAV_STATE_ACTIVE:      return @"Active";
        case MAV_STATE_CRITICAL:    return @"Critical";
        case MAV_STATE_EMERGENCY:   return @"Emergency";
        case MAV_STATE_POWEROFF:    return @"Power Off";
        case MAV_STATE_ENUM_END:    break;
    }
    return [NSString stringWithFormat:@"MAV_STATE (%d)", state];
}

+ (NSString*) mavCustomModeToString:(int)customMode {
    switch (customMode) {
        case MANUAL:        return @"Manual";
        case CIRCLE:        return @"Circle";
        case STABILIZE:     return @"Stabilize";
        case FLY_BY_WIRE_A: return @"FBW_A";
        case FLY_BY_WIRE_B: return @"FBW_B";
        case FLY_BY_WIRE_C: return @"FBW_C";
        case AUTO:          return @"Auto";
        case RTL:           return @"RTL";
        case LOITER:        return @"Loiter";
        case TAKEOFF:       return @"Takeoff";
        case LAND:          return @"Land";
        case GUIDED:        return @"Guided";
        case INITIALISING:  return @"Initialising";

    }
    return [NSString stringWithFormat:@"CUSTOM_MODE (%d)", customMode];
}

- (void) handlePacket:(mavlink_message_t*)msg {
    
    // FIXME: try to avoid repeated work here 
    // (i.e. if yaw hasn't changed, or position hasn't discernibly 
    // changed relative to view, don't update)
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
            
            [numSatellitesLabel setText:[NSString stringWithFormat:@"%d", gpsRawIntPkt.satellites_visible]];
            [gpsFixTypeLabel    setText: (gpsRawIntPkt.fix_type == 3) ? @"3D" :
                                        ((gpsRawIntPkt.fix_type == 2) ? @"2D" : @"No fix")];
        }
        break;
            
        case MAVLINK_MSG_ID_GPS_STATUS:
        {
            mavlink_gps_status_t gpsStatus;
            mavlink_msg_gps_status_decode(msg, &gpsStatus);
            [numSatellitesLabel setText:[NSString stringWithFormat:@"%d", gpsStatus.satellites_visible]];
        }
        break;
            
        case MAVLINK_MSG_ID_ATTITUDE:
        {
            mavlink_attitude_t attitudePkt;
            mavlink_msg_attitude_decode(msg, &attitudePkt);
            
            uavView.image = [GCSMapViewController imageWithImage: [UIImage imageNamed:@"airplane.png"] 
                                                    scaledToSize:CGSizeMake(AIRPLANE_ICON_SIZE,AIRPLANE_ICON_SIZE)
                                                        rotation: attitudePkt.yaw];
            
            [ahIndicatorView setRoll:-attitudePkt.roll pitch:attitudePkt.pitch];
            [ahIndicatorView requestRedraw];
            
            [sysUptimeLabel  setText:[NSString stringWithFormat:@"%0.1f s", attitudePkt.time_boot_ms/1000.0f]];
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
            
            [throttleLabel    setText:[NSString stringWithFormat:@"%d%%", vfrHudPkt.throttle]];
            [climbRateLabel   setText:[NSString stringWithFormat:@"%0.1f m/s", vfrHudPkt.climb]];
            [groundSpeedLabel setText:[NSString stringWithFormat:@"%0.1f m/s", vfrHudPkt.groundspeed]];
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
            [windDirLabel    setText:[NSString stringWithFormat:@"%d", (int)wind.direction]];
            [windSpeedLabel  setText:[NSString stringWithFormat:@"%0.1f m/s", wind.speed]];
            [windSpeedZLabel setText:[NSString stringWithFormat:@"%0.1f m/s", wind.speed_z]];
            
            windIconView.transform = CGAffineTransformMakeRotation(((360 + (int)wind.direction + WIND_ICON_OFFSET_ANG) % 360) * M_PI/180.0f);
        }
        break;
            
        case MAVLINK_MSG_ID_HWSTATUS:
        {
            mavlink_hwstatus_t hwStatus;
            mavlink_msg_hwstatus_decode(msg, &hwStatus);
            [sysVoltageLabel setText:[NSString stringWithFormat:@"%0.2fV", hwStatus.Vcc/1000.f]];
        }
        break;
            
        case MAVLINK_MSG_ID_MEMINFO:
        {
            mavlink_meminfo_t memFree;
            mavlink_msg_meminfo_decode(msg, &memFree);
            [sysMemFreeLabel setText:[NSString stringWithFormat:@"%0.1fkB", memFree.freemem/1024.0f]];
        }
        break;
            
        case MAVLINK_MSG_ID_HEARTBEAT:
        {
            mavlink_heartbeat_t heartbeat;
            mavlink_msg_heartbeat_decode(msg, &heartbeat);
            
            [customModeLabel    setText:[GCSMapViewController mavCustomModeToString:  heartbeat.custom_mode]];
            [baseModeLabel      setText:[GCSMapViewController mavModeEnumToString:    heartbeat.base_mode]];
            [statusLabel        setText:[GCSMapViewController mavStateEnumToString:   heartbeat.system_status]];
            
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
                [self disableFollowMeMode];
                [self clearGuidedPositions];
            }
            lastCustomMode = heartbeat.custom_mode;
        }
        break;
    }
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
        view.image = [GCSMapViewController image:[UIImage imageNamed:@"13-target.png"]
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

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    // FIXME: mark some error
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *location = locationManager.location;
    NSTimeInterval age = -[location.timestamp timeIntervalSinceNow];
    NSLog(@"locationManager didUpdateLocations: %@ (age = %0.1fs)", location.description, age);
    if (age > 5.0) return;
    
    userLocationAccuracyLabel.text = [NSString stringWithFormat:@"%0.1fm", location.horizontalAccuracy];

    if (location.horizontalAccuracy >= 0 && location.horizontalAccuracy <= FOLLOW_ME_REQUIRED_ACCURACY) {
        userLocationAccuracyLabel.textColor = [UIColor greenColor];
    } else {
        userLocationAccuracyLabel.textColor = [UIColor redColor];
    }
    
    userPosition = location;
    [self updateFollowMePosition];
}

@end
