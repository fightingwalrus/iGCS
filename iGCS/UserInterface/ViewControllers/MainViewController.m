//
//  MainViewController.m
//  iGCS
//
//  Created by Claudio Natoli on 5/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MainViewController.h"

#import "SWRevealViewController.h"

#import "GCSMapViewController.h"
#import "GCSMapViewController+DataRate.h"
#import "WaypointsViewController.h"
#import "CommsViewController.h"
#import "DebugViewController.h"

#import "CommController.h"
#import "DataRateRecorder.h"

#import "GaugeViewCommon.h"
#import "GCSAccessoryFirmwareManager.h"

@interface MainViewController ()
@property (strong) GCSMapViewController *gcsMapVC;
@property (strong) GCSSidebarController *gcsSidebarVC;
@property (strong) WaypointsViewController *waypointVC;
@property (strong) CommsViewController *commsVC;
@property (strong) DebugViewController *debugVC;

@property (nonatomic, strong) GCSAccessoryFirmwareManager *firmwareManager;
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

#ifdef DEBUG
    self.commsVC    = [self viewControllers][2];
    self.debugVC    = [self viewControllers][3];
#endif

    // Initialize MavLink Interfaces

    [CommController sharedInstance].mainVC = self;

// Hide all tabs except map view and mission editor in release mode
#ifndef DEBUG
    NSArray *tabBarControllers = @[gcsRevealVC, self.waypointVC];
    [self setViewControllers:tabBarControllers animated:NO];


    // Hide tabBar on iPhone
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self.tabBar setHidden:YES];
    }
#endif

    self.firmwareManager = [[GCSAccessoryFirmwareManager alloc] initWithTargetView:self.view];
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

- (void) handlePacket:(mavlink_message_t*)msg {
    [self.gcsMapVC handlePacket:msg];
    [self.gcsSidebarVC handlePacket:msg];
    [self.waypointVC handlePacket:msg];
#ifdef DEBUG
    [self.commsVC  handlePacket:msg];
#endif
}

- (void) replaceMission:(WaypointsHolder*)mission {
    [self.gcsMapVC   replaceMission:mission];
    [self.waypointVC replaceMission:mission];
}

@end
