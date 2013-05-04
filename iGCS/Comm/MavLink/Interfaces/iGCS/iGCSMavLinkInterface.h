//
//  iGCSMavLinkInterface.h
//  iGCS
//
//  Created by Andrew Aarestad on 2/22/13.
//
//

#import <Foundation/Foundation.h>
#import "MavLinkInterface.h"
#import "MainViewController.h"


#import "WaypointsHolder.h"

@interface iGCSMavLinkInterface : MavLinkInterface






@property (strong) MainViewController *mainVC;
@property (strong) NSNumber *heartbeatOnlyCount;
@property BOOL mavLinkInitialized;
@property (strong) WaypointsHolder *waypoints;


+(iGCSMavLinkInterface*)createWithViewController:(MainViewController*)mainVC;


- (void) requestNextWaypointOrACK:(WaypointsHolder*)waypoints;
- (void) issueReadMissionRequest;
- (void) issueGOTOCommand:(CLLocationCoordinate2D)coordinates withAltitude:(float)altitude;
- (void) issueSetAUTOModeCommand;


@end
