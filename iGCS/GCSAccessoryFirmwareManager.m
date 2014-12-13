//
//  GCSFirmwareUpdatManager.m
//  iGCS
//
//  Created by Andrew Brown on 7/21/14.
//
//

#import "GCSAccessoryFirmwareManager.h"
#import "GCSAccessoryFirmwareInterface.h"
#import "GCSAccessoryFirmwareUtils.h"
#import "GCSActivityIndicatorView.h"
#import "CommController.h"

@interface GCSAccessoryFirmwareManager ()
@property (nonatomic, strong) UIAlertView *updateFirmwareAlert;
@property (nonatomic, strong) UIAlertView *firmwareUpdateCompleteAlert;
@property (nonatomic, strong) UIAlertView *notConnectedAlert;
@property (nonatomic, strong) GCSActivityIndicatorView *activityIndicatorView;
@property (nonatomic, strong) NSDictionary *accessoryModelName;
@property (nonatomic, weak) UIView *targetView;
@end

@implementation GCSAccessoryFirmwareManager

#pragma mark - init and lifecycle

-(instancetype)initWithTargetView:(UIView *)aTargetView {
    self = [super init];
    if (self) {
        _targetView = aTargetView;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alertUserToUpateFirmwareWithNotification:)
                                                     name:GCSAccessoryFirmwareNeedsUpdated object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alertViewFirmwareUpdateCompleteWithNotification:)
                                                     name:GCSAccessoryFirmwareUpdateSuccess object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alertViewFirmwareUpdateFailed)
                                                     name:GCSAccessoryFirmwareUpdateFail object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alertViewRadioNotConnected)
                                                     name:GCSCommControllerRadioNotConnected object:nil];

    }
    return self;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark  - NSNotification handlers and UI
-(void)alertUserToUpateFirmwareWithNotification:(NSNotification *)notification {
    NSString *message = [NSString stringWithFormat:@"The %@ firmware needs to be upgraded.",
                         [(EAAccessory *)notification.object name]];

    self.updateFirmwareAlert = [[UIAlertView alloc] initWithTitle:@"Update Firmware"
                                                          message:message
                                                         delegate:self
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
    [self.updateFirmwareAlert show];
}

-(void)alertViewFirmwareUpdateCompleteWithNotification:(NSNotification *)notification {
    NSString *message = [NSString stringWithFormat:@"Please disconnect and reconnect %@ to complete firmware upgrade.",
                         [(EAAccessory *)notification.object name]];

    self.firmwareUpdateCompleteAlert = [[UIAlertView alloc] initWithTitle:@"Firmware Updated"
                                                                  message:message
                                                                 delegate:self
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles:nil];
    [self.firmwareUpdateCompleteAlert show];
}

-(void)alertViewRadioNotConnected {

    self.notConnectedAlert = [[UIAlertView alloc] initWithTitle:@"Accessory not connected"
                                                          message:@"A supported accessory is not connected."
                                                         delegate:self
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
    [self.notConnectedAlert show];
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

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView == self.updateFirmwareAlert) {
        // 1. put up spinner
        [self showActivityIndicator];

        // 2. start firmware upload
        [[CommController sharedInstance] startFWRFirmwareUpdateMode];
        [[CommController sharedInstance].accessoryFirmwareInterface updateFirmware];

    } else {
        [self stopAndRemoveActivityIndicator];
    }
}

@end
