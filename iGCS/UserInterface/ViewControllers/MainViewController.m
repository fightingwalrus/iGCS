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
#import "GCSMapViewController+DataRate.h"

#import "CommController.h"
#import "DataRateRecorder.h"

#import "GaugeViewCommon.h"
#import "GCSFirmwareUpdateManager.h"

@interface MainViewController ()
@property (nonatomic, strong) GCSFirmwareUpdateManager *firmwareManager;
@end

@implementation MainViewController

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)awakeFromNib {
    // Get the views for convenience
    // FIXME: adopt a cleaner pattern for this (see also viewDidLoad)
    SWRevealViewController *gcsRevealVC = [self viewControllers][0];
    [gcsRevealVC view];
    self.gcsMapVC     = (GCSMapViewController*)[gcsRevealVC frontViewController];
    self.gcsSidebarVC = (GCSSidebarController*)[gcsRevealVC rearViewController].childViewControllers.lastObject;
    
    self.gcsMapVC.followMeControlDelegate    = self.gcsSidebarVC;
    self.gcsSidebarVC.followMeChangeListener = self.gcsMapVC;
    
    self.waypointVC = [self viewControllers][1];
    self.commsVC    = [self viewControllers][2];

#ifdef DEBUG
    self.debugVC    = [self viewControllers][3];
#endif

    // Initialize MavLink Interfaces

    [CommController sharedInstance].mainVC = self;

// Don't show debug view controller in tab bar if we are not on a debug build
#ifndef DEBUG
    NSArray *tabBarControllers = @[gcsRevealVC, self.waypointVC, self.commsVC];
    [self setViewControllers:tabBarControllers animated:NO];
#endif

    // Hide tabBar on iPhone
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self.tabBar setHidden:YES];
    }

    self.firmwareManager = [[GCSFirmwareUpdateManager alloc] initWithTargetView:self.view];
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
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

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

@end
