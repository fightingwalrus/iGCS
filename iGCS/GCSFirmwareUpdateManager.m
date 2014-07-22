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
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
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

    }
    return self;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)alertUserToUpateFirmware {
    self.updateFirmwareAlert = [[UIAlertView alloc] initWithTitle:@"Update Firmware"
                                                          message:@"The Fighting Walrus Radio firmware needs updated."
                                                         delegate:self
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
    [self.updateFirmwareAlert show];
}

-(void)alertViewFirmwareUpdateComplete {
    self.firmwareUpdateCompleteAlert = [[UIAlertView alloc] initWithTitle:@"Firmware Updated"
                                                                  message:@"Fighting Walrus Radio's firmware has been updated. \
                                        Please disconnect and reconnect the Fighting Walrus Radio to complete the upgrade."
                                                                 delegate:self
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles:nil];
    [self.firmwareUpdateCompleteAlert show];
}

-(void)showActivityIndicator {
    self.activityIndicatorView = [[GCSActivityIndicatorView alloc] init];

    CGSize thisViewSize = self.targetView.bounds.size;
    self.activityIndicatorView.center = CGPointMake(thisViewSize.width / 2.0, thisViewSize.height / 2.0);
    [self.targetView addSubview:self.activityIndicatorView];
    [self.targetView bringSubviewToFront:self.activityIndicatorView];
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
