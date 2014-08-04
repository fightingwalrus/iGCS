//
//  GCSFirmwareUpdatManager.m
//  iGCS
//
//  Created by Andrew Brown on 7/21/14.
//
//

#import "GCSFirmwareUpdateManager.h"
#import "GCSFWRFirmwareInterface.h"
#import "GCSFirmwareUtils.h"
#import "GCSActivityIndicatorView.h"
#import "CommController.h"

@interface GCSFirmwareUpdateManager ()
@property (nonatomic, strong) UIAlertView *updateFirmwareAlert;
@property (nonatomic, strong) UIAlertView *firmwareUpdateCompleteAlert;
@property (nonatomic, strong) UIAlertView *fwrNotConnectedAlert;
@property (nonatomic, strong) GCSActivityIndicatorView *activityIndicatorView;
@property (nonatomic, weak) UIView *targetView;
@end

@implementation GCSFirmwareUpdateManager

#pragma mark - radio update UI

-(id)initWithTargetView:(UIView *)aTargetView {
    self = [super init];
    if (self) {
        _targetView = aTargetView;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alertUserToUpateFirmware)
                                                     name:GCSFirmwareUtilsFwrFirmwareNeedsUpdated object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alertViewFirmwareUpdateComplete)
                                                     name:GCSFirmewareIntefaceFirmwareUpdateSuccess object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alertViewFirmwareUpdateFailed)
                                                     name:GCSFirmewareIntefaceFirmwareUpdateFail object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alertViewFwrNotConnected)
                                                     name:GCSCommControllerFightingWalrusRadioNotConnected object:nil];

    }
    return self;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)alertUserToUpateFirmware {
    self.updateFirmwareAlert = [[UIAlertView alloc] initWithTitle:@"Update Firmware"
                                                          message:@"The Fighting Walrus Radio firmware needs to be upgraded."
                                                         delegate:self
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
    [self.updateFirmwareAlert show];
}

-(void)alertViewFirmwareUpdateComplete {
    self.firmwareUpdateCompleteAlert = [[UIAlertView alloc] initWithTitle:@"Firmware Updated"
                                                                  message:@"Please disconnect and reconnect Fighting Walrus Radio to complete firmware upgrade."
                                                                 delegate:self
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles:nil];
    [self.firmwareUpdateCompleteAlert show];
}

-(void)alertViewFwrNotConnected {
    self.fwrNotConnectedAlert = [[UIAlertView alloc] initWithTitle:@"Accessory not connected"
                                                          message:@"The Fighting Walrus Radio is not connected."
                                                         delegate:self
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
    [self.fwrNotConnectedAlert show];
}

-(void)showActivityIndicator {
    self.activityIndicatorView = [[GCSActivityIndicatorView alloc] init];
    [self.activityIndicatorView centerOnView:self.targetView];
    [self.activityIndicatorView startAnimating];
    [self performSelector:@selector(stopAndRemoveActivityIndicator) withObject:self afterDelay:15.0f];
}

-(void)stopAndRemoveActivityIndicator {
    [self.activityIndicatorView stopAnimating];
    [self.activityIndicatorView removeFromSuperview];
}

-(void)alertViewFirmwareUpdateFailed {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Firmware Updated Failed"
                                                    message:@"Could not update Firmware."
                                                   delegate:self cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

#pragma UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView == self.updateFirmwareAlert) {
        // 1. put up splinner
        [self showActivityIndicator];

        // 2. start firmware upload
            [[CommController sharedInstance] startFWRFirmwareUpdateMode];
            [[CommController sharedInstance].fwrFirmwareInterface updateFwrFirmware];

    } else {
        [self stopAndRemoveActivityIndicator];
    }
}

@end
