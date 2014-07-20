//
//  MainViewController.m
//  iGCS
//
//  Created by Claudio Natoli on 5/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MainViewController.h"

#import "SWRevealViewController.h"

#import "CommsViewController.h"
#import "GCSMapViewController.h"

#import "CommController.h"
#import "DataRateRecorder.h"

#import "GaugeViewCommon.h"
#import "GCSFirmwareUtils.h"
#import "GCSActivityIndicatorView.h"

@interface MainViewController ()
@property (nonatomic, strong) UIAlertView *updateFirmwareAlert;
@property (nonatomic, strong) UIAlertView *firmwareUpdateCompleteAlert;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@end


@implementation MainViewController

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
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

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
#if DO_NSLOG
    if ([self isViewLoaded]) {
        NSLog(@"\tMainViewController::didReceiveMemoryWarning: view is still loaded");
    } else {
        NSLog(@"\tMainViewController::didReceiveMemoryWarning: view is NOT loaded");
    }
#endif
}


- (void)awakeFromNib
{
    // Get the views for convenience
    // FIXME: adopt a cleaner pattern for this (see also viewDidLoad)
    SWRevealViewController *gcsRevealVC = [[self viewControllers] objectAtIndex:0];
    [gcsRevealVC view];
    self.gcsMapVC     = (GCSMapViewController*)[gcsRevealVC frontViewController];
    self.gcsSidebarVC = (GCSSidebarController*)[gcsRevealVC rearViewController].childViewControllers.lastObject;
    
    self.gcsMapVC.followMeControlDelegate    = self.gcsSidebarVC;
    self.gcsSidebarVC.followMeChangeListener = self.gcsMapVC;
    
    self.waypointVC = [[self viewControllers] objectAtIndex:1];
    self.commsVC    = [[self viewControllers] objectAtIndex:2];
    self.debugVC    = [[self viewControllers] objectAtIndex:3];
    
    // Initialize MavLink Interfaces

    [CommController sharedInstance].mainVC = self;

    // Hide tabBar on iPhone
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self.tabBar setHidden:YES];
    }
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Access view of all controllers to force load
    for (id controller in [self viewControllers]) {
        [controller view];
    }
    
    // Create the shared data rate recorder
    _dataRateRecorder = [[DataRateRecorder alloc] init];
    
    // Wire up the data rate recorder references
    self.gcsMapVC.dataRateRecorder = _dataRateRecorder;
    self.commsVC.dataRateRecorder  = _dataRateRecorder;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

#pragma mark - radio update UI

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

    CGSize thisViewSize = self.view.bounds.size;
    self.activityIndicatorView.center = CGPointMake(thisViewSize.width / 2.0, thisViewSize.height / 2.0);
    [self.view addSubview:self.activityIndicatorView];
    [self.view bringSubviewToFront:self.activityIndicatorView];
    [self.activityIndicatorView startAnimating];

    [self performSelector:@selector(stopAndRemoveActivityIndicator) withObject:self afterDelay:5.0f];
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
        //    [[CommController sharedInstance] startFWRFirmwareUpdateMode];
        //    [[CommController sharedInstance].fwrFirmwareInterface updateFwrFirmware];
    }
}

@end
