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

@property (nonatomic, retain) IBOutlet UILabel *acVoltageLabel;
@property (nonatomic, retain) IBOutlet UILabel *acCurrentLabel;
@property (nonatomic, retain) IBOutlet UILabel *acThrottleLabel;
@property (nonatomic, retain) IBOutlet UILabel *acClimbRateLabel;
@property (nonatomic, retain) IBOutlet UILabel *acGroundSpeedLabel;

@property (nonatomic, retain) IBOutlet UILabel *gpsFixTypeLabel;
@property (nonatomic, retain) IBOutlet UILabel *numSatellitesLabel;

@property (nonatomic, retain) IBOutlet UILabel *windDirLabel;
@property (nonatomic, retain) IBOutlet UILabel *windSpeedLabel;
@property (nonatomic, retain) IBOutlet UILabel *windSpeedZLabel;

@property (nonatomic, retain) IBOutlet UILabel *sysUptimeLabel;
@property (nonatomic, retain) IBOutlet UILabel *sysVoltageLabel;
@property (nonatomic, retain) IBOutlet UILabel *sysMemFreeLabel;

@end
