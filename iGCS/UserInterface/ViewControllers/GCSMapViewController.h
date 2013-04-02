//
//  FirstViewController.h
//  iGCS
//
//  Created by Claudio Natoli on 5/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WaypointMapBaseController.h"
#import <GameKit/GameKit.h>

#import "ArtificialHorizonView.h"
#import "CompassView.h"
#import "VerticalScaleView.h"
#import "MavLinkPacketHandler.h"

#import "GotoPointAnnotation.h"

@interface GCSMapViewController : WaypointMapBaseController <MavLinkPacketHandler, GKPeerPickerControllerDelegate, GKSessionDelegate, GKMatchmakerViewControllerDelegate, GKMatchDelegate>
{
    MKPointAnnotation *uavPos; 
    MKAnnotationView *uavView;
    
    GotoPointAnnotation *gotoPos;
    CLLocationCoordinate2D gotoCoordinates;
    float gotoAltitude;
    
    int				gamePacketNumber;
    int				gameUniqueID;
}

@property(nonatomic) NSInteger		gameState;
@property(nonatomic) NSInteger		peerStatus;

@property(nonatomic, retain) GKSession	 *gameSession;
@property(nonatomic, copy)	 NSString	 *gamePeerId;
@property(nonatomic, retain) NSDate		 *lastHeartbeatDate;
@property(nonatomic, retain) UIAlertView *connectionAlert;

@property(nonatomic, strong) GKMatch *myMatch;
@property(nonatomic) BOOL matchStarted;
@property(nonatomic, strong) NSArray *myFriends;
@property(nonatomic, strong) NSArray *myIdentifiers;
@property (strong, nonatomic) IBOutlet UILabel *debugConsoleLabel;

#define WIND_ICON_OFFSET_ANG 135

@property (nonatomic, retain) IBOutlet UIImageView *windIconView;
@property (nonatomic, retain) IBOutlet ArtificialHorizonView *ahIndicatorView;
@property (nonatomic, retain) IBOutlet CompassView           *compassView;
@property (nonatomic, retain) IBOutlet VerticalScaleView     *airspeedView;
@property (nonatomic, retain) IBOutlet VerticalScaleView     *altitudeView;

@property (nonatomic, retain) IBOutlet UILabel     *customModeLabel;
@property (nonatomic, retain) IBOutlet UILabel     *baseModeLabel;
@property (nonatomic, retain) IBOutlet UILabel     *statusLabel;

@property (nonatomic, retain) IBOutlet UILabel     *gpsFixTypeLabel;
@property (nonatomic, retain) IBOutlet UILabel     *numSatellitesLabel;

@property (nonatomic, retain) IBOutlet UILabel     *sysUptimeLabel;
@property (nonatomic, retain) IBOutlet UILabel     *sysVoltageLabel;
@property (nonatomic, retain) IBOutlet UILabel     *sysMemFreeLabel;

@property (nonatomic, retain) IBOutlet UILabel     *throttleLabel;
@property (nonatomic, retain) IBOutlet UILabel     *climbRateLabel;
@property (nonatomic, retain) IBOutlet UILabel     *groundSpeedLabel;
@property (nonatomic, retain) IBOutlet UILabel     *windDirLabel;
@property (nonatomic, retain) IBOutlet UILabel     *windSpeedLabel;
@property (nonatomic, retain) IBOutlet UILabel     *windSpeedZLabel;
@property (nonatomic, retain) IBOutlet UILabel     *voltageLabel;
@property (nonatomic, retain) IBOutlet UILabel     *currentLabel;

@property (nonatomic, retain) IBOutlet UIButton    *autoButton;

- (IBAction) readWaypointButtonClick;
- (IBAction) autoButtonClick;
- (IBAction) externalButtonClick;

@end
