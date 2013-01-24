//
//  MainViewController.h
//  iGCS
//
//  Created by Claudio Natoli on 5/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RscMgr.h"
#import <MapKit/MKMapView.h>

@class GCSMapViewController;
@class CommsViewController;
@class WaypointsViewController;

@class WaypointsHolder;

@interface MainViewController : UITabBarController <RscMgrDelegate> {
    RscMgr *rscMgr;
    bool cableConnected;
    
    bool mavLinkInitialized;
    NSNumber *heartbeatOnlyCount;
    
    GCSMapViewController *gcsMapVC;
    CommsViewController *commsVC;
    WaypointsViewController *waypointVC;
}

- (void) requestNextWaypointOrACK:(WaypointsHolder*)waypoints;
- (void) issueReadWaypointsRequest;
- (void) issueGOTOCommand:(CLLocationCoordinate2D)coordinates withAltitude:(float)altitude;
- (void) issueSetAUTOModeCommand;


@end
