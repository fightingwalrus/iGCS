//
//  GCSSidebarController.h
//  iGCS
//
//  Created by Claudio Natoli on 31/01/2014.
//
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CLLocation.h>

#import "MavLinkPacketHandler.h"

@interface FollowMeCtrlValues : NSObject
@property (nonatomic, assign) double bearing;
@property (nonatomic, assign) double distance;
@property (nonatomic, assign) double altitudeOffset;
@property (nonatomic, assign) BOOL   isActive;
@end

@protocol GCSFollowMeCtrlProtocol <NSObject>
- (void) followMeDeactivate;
- (FollowMeCtrlValues*) followMeControlValues;
- (void) followMeLocationAccuracy:(CLLocationAccuracy)accuracy isAcceptable:(BOOL)acceptable;
@end

@protocol GCSFollowMeCtrlChangeProtocol <NSObject>
- (void) followMeControlChange:(FollowMeCtrlValues*)vals;
@end

@interface GCSSidebarController : UITableViewController <MavLinkPacketHandler, GCSFollowMeCtrlProtocol, UIAlertViewDelegate>

@property (weak) id <GCSFollowMeCtrlChangeProtocol> followMeChangeListener;

@property (nonatomic, retain) IBOutlet UILabel *mavBaseModeLabel;
@property (nonatomic, retain) IBOutlet UILabel *mavCustomModeLabel;
@property (nonatomic, retain) IBOutlet UILabel *mavStatusLabel;

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

// Temporary controls to mock out future UI control of "follow" me mode
@property (nonatomic, retain) IBOutlet UILabel  *userLocationAccuracyLabel;
@property (nonatomic, retain) IBOutlet UISwitch *followMeSwitch;
@property (nonatomic, retain) IBOutlet UISlider *followMeBearingSlider;
@property (nonatomic, retain) IBOutlet UISlider *followMeDistanceSlider;
@property (nonatomic, retain) IBOutlet UISlider *followMeHeightSlider;
- (IBAction) followMeSwitchChanged:(UISwitch*)s;
- (IBAction) followMeSliderChanged:(UISlider*)slider;

@property (nonatomic, retain) IBOutlet UILabel *sysUptimeLabel;
@property (nonatomic, retain) IBOutlet UILabel *sysVoltageLabel;
@property (nonatomic, retain) IBOutlet UILabel *sysMemFreeLabel;
@property (nonatomic, strong) IBOutlet UILabel *sysRemoteRSSI;
@property (nonatomic, strong) IBOutlet UILabel *sysLocalRSSI;


@end
