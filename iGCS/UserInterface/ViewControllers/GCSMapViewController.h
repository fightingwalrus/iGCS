//
//  FirstViewController.h
//  iGCS
//
//  Created by Claudio Natoli on 5/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WaypointMapBaseController.h"
#import <GLKit/GLKit.h>

#import "ArtificialHorizonView.h"
#import "CompassView.h"
#import "VerticalScaleView.h"
#import "MavLinkPacketHandler.h"

#import "RequestedPointAnnotation.h"
#import "GuidedPointAnnotation.h"

#ifdef VIDEOSTREAMING
#import "KxMovieViewController.h"
#endif

#import "GCSSidebarController.h"

@interface GCSMapViewController : WaypointMapBaseController <MavLinkPacketHandler, GLKViewDelegate, GCSFollowMeCtrlChangeProtocol>
{
    MKPointAnnotation *uavPos; 
    MKAnnotationView *uavView;
    
    GLKView *videoOverlayView;
    EAGLContext *_context;
    NSMutableDictionary *_availableStreams;

    GuidedPointAnnotation *currentGuidedAnnotation;
    RequestedPointAnnotation *requestedGuidedAnnotation;

    CLLocationCoordinate2D gotoCoordinates;
    float gotoAltitude;
    
    CLLocationCoordinate2D followMeCoords;
    float followMeHeightOffset; // relative to home
    BOOL showProposedFollowPos;
    NSDate *lastFollowMeUpdate;
    uint32_t lastCustomMode;

    int				gamePacketNumber;
    int				gameUniqueID;
}

@property (retain, readonly) id <GCSFollowMeCtrlProtocol> followMeControlDelegate;

@property(nonatomic, retain) NSDate		 *lastHeartbeatDate;
@property(nonatomic, retain) UIAlertView *connectionAlert;

@property(nonatomic, strong) NSArray *myFriends;
@property(nonatomic, strong) NSArray *myIdentifiers;
@property (strong, nonatomic) IBOutlet UILabel *debugConsoleLabel;

@property (nonatomic, retain) IBOutlet UIButton *sidebarButton;
- (IBAction)toggleSidebar:(id)sender;

#define WIND_ICON_OFFSET_ANG 135

@property (nonatomic, retain) IBOutlet UIImageView *windIconView;
@property (nonatomic, retain) IBOutlet ArtificialHorizonView *ahIndicatorView;
@property (nonatomic, retain) IBOutlet CompassView           *compassView;
@property (nonatomic, retain) IBOutlet VerticalScaleView     *airspeedView;
@property (nonatomic, retain) IBOutlet VerticalScaleView     *altitudeView;

@property (nonatomic, retain) IBOutlet UILabel *armedLabel;
@property (nonatomic, retain) IBOutlet UILabel *customModeLabel;
@property (nonatomic, retain) IBOutlet UISegmentedControl *controlModeSegment;
@property (nonatomic, retain) IBOutlet UILabel *voltageLabel;
@property (nonatomic, retain) IBOutlet UILabel *currentLabel;

#ifdef VIDEOSTREAMING
@property (nonatomic, retain) KxMovieViewController *kxMovieVC;
@property (nonatomic, retain) NSDictionary *availableStreams;
#endif

- (IBAction) changeControlModeSegment;

+ (BOOL) isAcceptableFollowMePosition:(CLLocation*)pos;

@end
