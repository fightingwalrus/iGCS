//
//  MainViewController.h
//  iGCS
//
//  Created by Claudio Natoli on 5/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h" // For TestFlight control

#ifdef REDPARK
#import "RscMgr.h"
#endif

#import <MapKit/MKMapView.h>

@class GCSMapViewController;
@class GCSSidebarController;
@class CommsViewController;
@class WaypointsViewController;
@class DebugViewController;
@class DataRateRecorder;
@class GCSFirmwareUtils;

@interface MainViewController : UITabBarController <UIAlertViewDelegate>

@property (weak) AppDelegate *appDelegate;

@property (strong) GCSMapViewController *gcsMapVC;
@property (strong) GCSSidebarController *gcsSidebarVC;
@property (strong) WaypointsViewController *waypointVC;
@property (strong) CommsViewController *commsVC;
@property (strong) DebugViewController *debugVC;

@property (nonatomic, strong) DataRateRecorder *dataRateRecorder;
@end
