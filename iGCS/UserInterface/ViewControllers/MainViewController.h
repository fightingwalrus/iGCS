//
//  MainViewController.h
//  iGCS
//
//  Created by Claudio Natoli on 5/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h" // For TestFlight control
#import "MavLinkPacketHandler.h"

#ifdef REDPARK
#import "RscMgr.h"
#endif

#import <MapKit/MKMapView.h>

@class DataRateRecorder;
@class WaypointsHolder;

@interface MainViewController : UITabBarController <UIAlertViewDelegate, MavLinkPacketHandler>

@property (weak) AppDelegate *appDelegate;
@property (nonatomic, strong, readonly) DataRateRecorder *dataRateRecorder;

- (void) resetWaypoints:(WaypointsHolder*)mission;
@end
