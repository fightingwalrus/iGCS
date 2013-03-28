//
//  MainViewController.h
//  iGCS
//
//  Created by Claudio Natoli on 5/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h" // For TestFlight control

#import "RscMgr.h"
#import <MapKit/MKMapView.h>

@class GCSMapViewController;
@class CommsViewController;
@class WaypointsViewController;
@class DebugViewController;

@class WaypointsHolder;

@interface MainViewController : UITabBarController

@property (weak) AppDelegate *appDelegate;

@property (strong) GCSMapViewController *gcsMapVC;
@property (strong) CommsViewController *commsVC;
@property (strong) WaypointsViewController *waypointVC;
@property (strong) DebugViewController *debugVC;




@end
