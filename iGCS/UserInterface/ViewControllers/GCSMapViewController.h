//
//  GCSMapViewController.h
//  iGCS
//
//  Created by Claudio Natoli on 5/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WaypointMapBaseController.h"

#import "ArtificialHorizonView.h"
#import "CompassView.h"
#import "GCSTelemetryLossOverlayView.h"
#import "VerticalScaleView.h"
#import "MavLinkPacketHandler.h"
#import "CorePlot-CocoaTouch.h"

#import "RequestedPointAnnotation.h"
#import "GuidedPointAnnotation.h"

#import "GCSSidebarController.h"

@interface GCSMapViewController : WaypointMapBaseController <MavLinkPacketHandler, GCSFollowMeCtrlChangeProtocol>

@property (weak) id <GCSFollowMeCtrlProtocol> followMeControlDelegate;

@property (nonatomic, strong) IBOutlet UILabel *debugConsoleLabel;

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

// 3 modes
//  * auto (initiates/returns to mission)
//  * misc (manual, stabilize, etc; not selectable)
//  * guided (goto/follow me)
@property (nonatomic, retain) IBOutlet UISegmentedControl *controlModeSegment;
@property (nonatomic, retain) IBOutlet NSLayoutConstraint *controlModeSegmentSizeConstraint;

@property (nonatomic, retain) IBOutlet CPTGraphHostingView *dataRateSparklineView;
@property (nonatomic, retain) IBOutlet UILabel *dataRateLabel;
@property (nonatomic, retain) IBOutlet UILabel *voltageLabel;
@property (nonatomic, retain) IBOutlet UILabel *currentLabel;

@property (nonatomic, retain) GCSTelemetryLossOverlayView *telemetryLossView;

- (IBAction) changeControlModeSegment;

+ (BOOL) isAcceptableFollowMePosition:(CLLocation*)pos;

@end
