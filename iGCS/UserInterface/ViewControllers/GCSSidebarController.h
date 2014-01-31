//
//  GCSSidebarController.h
//  iGCS
//
//  Created by Claudio Natoli on 31/01/2014.
//
//

#import <UIKit/UIKit.h>
#import "MavLinkPacketHandler.h"

@interface GCSSidebarController : UITableViewController <MavLinkPacketHandler>

@property (nonatomic, retain) IBOutlet UILabel     *gpsFixTypeLabel;
@property (nonatomic, retain) IBOutlet UILabel     *numSatellitesLabel;

@end
