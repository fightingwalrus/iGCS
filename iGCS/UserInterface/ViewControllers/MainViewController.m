//
//  MainViewController.m
//  iGCS
//
//  Created by Claudio Natoli on 5/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MainViewController.h"

#import "CommsViewController.h"
#import "GCSMapViewController.h"

#import "CommController.h"

#import "GaugeViewCommon.h"


@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {    
    }
    return self;
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
    self.gcsMapVC   = [[self viewControllers] objectAtIndex:0];
    self.waypointVC = [[self viewControllers] objectAtIndex:1];
    self.commsVC    = [[self viewControllers] objectAtIndex:2];
    self.debugVC    = [[self viewControllers] objectAtIndex:3];
    
    // Initialize MavLink Interfaces
    
    // TODO: Use NSNotifications for view updates instead of passing ref to self
    [[CommController sharedInstance] start:self];
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











@end
