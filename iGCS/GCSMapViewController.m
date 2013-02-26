//
//  FirstViewController.m
//  iGCS
//
//  Created by Claudio Natoli on 5/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GCSMapViewController.h"
#import <MapKit/MKUserLocation.h>

#import "MainViewController.h"
#import "WaypointAnnotation.h"
#import "GaugeViewCommon.h"

@implementation GCSMapViewController

@synthesize map;
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

@synthesize autoButton;

#define kMaxPacketSize 1024


typedef enum {
	kStateStartGame,
	kStatePicker,
	kStateMultiplayer,
	kStateMultiplayerCointoss,
	kStateMultiplayerReconnect
} gameStates;

typedef enum {
	NETWORK_ACK,					// no packet
	NETWORK_COINTOSS,				// decide who is going to be the server
	NETWORK_MOVE_EVENT,				// send position
	NETWORK_FIRE_EVENT,				// send fire
	NETWORK_HEARTBEAT				// send of entire state at regular intervals
} packetCodes;

typedef enum {
	kServer,
	kClient
} gameNetwork;

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
    uavView.centerOffset = CGPointMake(0, 0);
    
    gotoPos = nil;
    gotoAltitude = 50;
    
    trackMKMapPointsLen = 1000;
    trackMKMapPoints = malloc(trackMKMapPointsLen * sizeof(MKMapPoint));
    numTrackPoints = 0;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Authenticate the local player as soon as possible
    [self authenticateLocalPlayer];
    
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
    map.delegate = self;
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

- (IBAction) readWaypointButtonClick {
    [(MainViewController*)[self parentViewController] issueReadWaypointsRequest];
}

- (IBAction) autoButtonClick {
    [(MainViewController*)[self parentViewController] issueSetAUTOModeCommand];
}

- (IBAction) externalButtonClick {
    
    GKMatchRequest *request = [[GKMatchRequest alloc] init];
    request.minPlayers = 2;
    request.maxPlayers = 2;
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
                NSLog(@"You have friends!  You aren't a loner after all!");
            }
            else
            {
                NSLog(@"There is only but one in the wolfpack");
            }
        }
    }];
}

- (void) registerForInvites
{
    [GKMatchmaker sharedMatchmaker].inviteHandler = ^(GKInvite *acceptedInvite,
                                                      NSArray *playersToInvite) {
        // Insert application-specific code here to clean up any games in progress.
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
        // Drop an icon for the proposed GOTO point
        if (gotoPos != nil)
            [map removeAnnotation:gotoPos];

        gotoPos = [[GotoPointAnnotation alloc] initWithCoordinate:gotoCoordinates];
        [map addAnnotation:gotoPos];
        [map setNeedsDisplay];
        
        // Let's go!
        [(MainViewController*)[self parentViewController] issueGOTOCommand: gotoCoordinates withAltitude:gotoAltitude];
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

- (void) removeExistingWaypointAnnotations {
    [map removeAnnotations:
        [map.annotations
            filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(self isKindOfClass: %@)",
                                         [WaypointAnnotation class]]]];
}

- (WaypointAnnotation *) getWaypointAnnotation:(int)waypointSeq {
    for (unsigned int i =0; i < [map.annotations count]; i++) {
        id annotation = [map.annotations objectAtIndex:i];
        if ([annotation isKindOfClass:[WaypointAnnotation class]]) {
            WaypointAnnotation *waypointAnnotation = (WaypointAnnotation*)annotation;
            if ([waypointAnnotation isCurrentWaypointP:waypointSeq]) {
                return waypointAnnotation;
            }
        }
    }
    return nil;
}

- (void) updateWaypoints:(WaypointsHolder *)_waypoints {

    // Clean up existing objects
    [self removeExistingWaypointAnnotations];
    [map removeOverlay:waypointRoutePolyline];

    // Get the nav-specfic waypoints
    WaypointsHolder *navWaypoints = [_waypoints getNavWaypoints];
    unsigned int numWaypoints = [navWaypoints numWaypoints];

    MKMapPoint *navMKMapPoints = malloc(sizeof(MKMapPoint) * numWaypoints);
    
    // Add waypoint annotations, and convert to array of MKMapPoints
    for (unsigned int i = 0; i < numWaypoints; i++) {
        mavlink_mission_item_t waypoint = [navWaypoints getWaypoint:i];
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(waypoint.x, waypoint.y);
        
        // Add the annotation
        WaypointAnnotation *annotation = [[WaypointAnnotation alloc] initWithCoordinate:coordinate andWayPoint:waypoint];
        [map addAnnotation:annotation];
        
        // Construct the MKMapPoint
        navMKMapPoints[i] = MKMapPointForCoordinate(coordinate);
    }
        
    // Add the polyline overlay
    waypointRoutePolyline = [MKPolyline polylineWithPoints:navMKMapPoints count:numWaypoints];
    [map addOverlay:waypointRoutePolyline];
    
    // Set the map extents
    [map setVisibleMapRect:[waypointRoutePolyline boundingMapRect]];
    
    [map setNeedsDisplay];
    
    free(navMKMapPoints);
}

// FIXME: consider more efficient (and safe?) ways to do this - see iOS Breadcrumbs sample code
- (void) updateTrack:(CLLocationCoordinate2D)pos {
    MKMapPoint newPoint = MKMapPointForCoordinate(pos);
    
    // Check distance from 0
    if (MKMetersBetweenMapPoints(newPoint, MKMapPointForCoordinate(CLLocationCoordinate2DMake(0, 0))) < 1.0) {
        return;
    }

    // Check distance from last point
    if (numTrackPoints > 0) {
        if (MKMetersBetweenMapPoints(newPoint, trackMKMapPoints[numTrackPoints-1]) < 1.0) {
            return;
        }
    }

    // Check array bounds
    if (numTrackPoints == trackMKMapPointsLen) {
        MKMapPoint *newAlloc = realloc(trackMKMapPoints, trackMKMapPointsLen*2 * sizeof(MKMapPoint));
        if (newAlloc == nil)
            return;
        trackMKMapPoints = newAlloc;
        trackMKMapPointsLen *= 2;
    }
    
    // Add the next coord
    trackMKMapPoints[numTrackPoints] = newPoint;
    numTrackPoints++;
    
    // Clean up existing objects
    [map removeOverlay:trackPolyline];

    trackPolyline = [MKPolyline polylineWithPoints:trackMKMapPoints count:numTrackPoints];
    
    // Add the polyline overlay
    [map addOverlay:trackPolyline];
    [map setNeedsDisplay];
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
            [self updateTrack:pos];
        }
        break;
        */
        case MAVLINK_MSG_ID_GPS_RAW_INT:
        {
            mavlink_gps_raw_int_t gpsRawIntPkt;
            mavlink_msg_gps_raw_int_decode(msg, &gpsRawIntPkt);
            
            CLLocationCoordinate2D pos = CLLocationCoordinate2DMake(gpsRawIntPkt.lat/10000000.0, gpsRawIntPkt.lon/10000000.0);
            [uavPos setCoordinate:pos];
            [self updateTrack:pos];
            
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

            // We've seen a new waypoint, so...
            if (currentWaypointNum != currentWaypoint.seq) {
    
                // Reset the associated annotations
                for (int i = 0; i < 2; i++) {
                    WaypointAnnotation *annotation = [self getWaypointAnnotation:currentWaypointNum];
                    
                    // Update the current value (on the first iteration, we want this after the
                    // getWaypointAnnotation call, but before the addAnnotation)
                    currentWaypointNum = currentWaypoint.seq;

                    if (annotation) {
                        [map removeAnnotation:annotation];
                        [map addAnnotation:annotation];
                    }
                }
            }
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
                        
            // Dis/enable the AUTO button
            if ((heartbeat.custom_mode == AUTO) == autoButton.isEnabled) {
                autoButton.enabled = !autoButton.isEnabled;
            }
        }
        break;
    }
}

+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize rotation:(double)ang
{
    UIGraphicsBeginImageContext( newSize );
    //[image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    CGContextRef context = UIGraphicsGetCurrentContext();   
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformTranslate(transform, newSize.width/2, newSize.height/2);
    transform = CGAffineTransformRotate(transform, ang);
    CGContextConcatCTM(context, transform);
    
    [image drawInRect:CGRectMake(-newSize.width/2,-newSize.width/2,newSize.width,newSize.height)];

    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

// FIXME: move to some "utils" file
// ref: http://coffeeshopped.com/2010/09/iphone-how-to-dynamically-color-a-uiimage
+ (UIImage *)image:(UIImage*)img withColor:(UIColor*)color {
    
    
    // begin a new image context, to draw our colored image onto
    UIGraphicsBeginImageContext(img.size);
    
    // get a reference to that context we created
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // translate/flip the graphics context (for transforming from CG* coords to UI* coords
    CGContextTranslateCTM(context, 0, img.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGRect rect = CGRectMake(0, 0, img.size.width, img.size.height);
    CGContextDrawImage(context, rect, img.CGImage);
    
    // Set a mask that matches the shape of the image, then draw as black
    [[UIColor blackColor] setFill];
    CGContextSetBlendMode(context, kCGBlendModeDarken);
    CGContextClipToMask(context, rect, img.CGImage);
    CGContextAddRect(context, rect);
    CGContextDrawPath(context,kCGPathFill);

    // Now replace with the desired color
    [color setFill];
    CGContextSetBlendMode(context, kCGBlendModeLighten);
    CGContextClipToMask(context, rect, img.CGImage);
    CGContextAddRect(context, rect);
    CGContextDrawPath(context,kCGPathFill);
    
    // generate a new UIImage from the graphics context we drew onto
    UIImage *coloredImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
     
    //return the color-burned image
    return coloredImg;  
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // If it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    // Handle our custom annotations
    //
    if ([annotation isKindOfClass:[WaypointAnnotation class]]) {
        
        NSString* identifier = @"WAYPOINT";
        MKAnnotationView *view = (MKAnnotationView*) [map dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (view == nil) {
            view = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        } else {
            view.annotation = annotation;
        }
        
        WaypointAnnotation *waypointAnnotation = (WaypointAnnotation*)annotation;
        
        view.enabled = YES;
        view.canShowCallout = YES;
        
        // FIXME: memoize view.image generation
        if ([waypointAnnotation isCurrentWaypointP:currentWaypointNum]) {
            view.centerOffset = CGPointMake(0,0);      
            view.image = [GCSMapViewController image:[UIImage imageNamed:@"13-target.png"] 
                                           withColor:WAYPOINT_NAV_NEXT_COLOR];
        } else {
            view.centerOffset = CGPointMake(0,-12); // adjust for offset pointer in map marker        
            view.image = [GCSMapViewController image:[UIImage imageNamed:@"07-map-marker.png"] 
                                           withColor:[waypointAnnotation getColor]]; 
        }
        return view;
    }
    
    if ([annotation isKindOfClass:[GotoPointAnnotation class]]) {
        NSString* identifier = @"GOTOPOINT";
        MKAnnotationView *view = (MKAnnotationView*) [map dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (view == nil) {
            view = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        } else {
            view.annotation = annotation;
        }
        
        view.enabled = YES;
        view.canShowCallout = YES;
        view.centerOffset = CGPointMake(0,0);      
        view.image = [GCSMapViewController image:[UIImage imageNamed:@"13-target.png"] 
                                        withColor:WAYPOINT_LINE_COLOR];
        return view;
    }
    
    if ([annotation isKindOfClass:[MKPointAnnotation class]]) {
        return uavView;
    }
    
    return nil;
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id)overlay
{
    if (overlay == waypointRoutePolyline) {
        waypointRouteView = [[MKPolylineView alloc] initWithPolyline:overlay];
        waypointRouteView.fillColor     = WAYPOINT_LINE_COLOR;
        waypointRouteView.strokeColor   = WAYPOINT_LINE_COLOR;
        waypointRouteView.lineWidth     = 3;
        return waypointRouteView;
    } else if (overlay == trackPolyline) {
        trackView = [[MKPolylineView alloc] initWithPolyline:overlay];
        trackView.fillColor     = TRACK_LINE_COLOR;
        trackView.strokeColor   = TRACK_LINE_COLOR;
        trackView.lineWidth     = 2;
        return trackView;
    }
    
    return nil;
}

@end
