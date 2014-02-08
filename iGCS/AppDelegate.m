//
//  AppDelegate.m
//  iGCS
//
//  Created by Claudio Natoli on 5/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

#import "CommController.h"

#include <Dropbox/Dropbox.h>


#import "DebugLogger.h"

#define REQUIRE_WALRUS 0

@implementation AppDelegate

static AppDelegate *shared;

@synthesize window = _window;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
#ifdef VIDEOSTREAMING
    // set up defaults
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"videoSource": @"testStream", @"videoScaleFactor": @1,
     @"videoDisplayLocation": @"corner"}];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
#endif
    
    DBAccountManager* accountMgr = [[DBAccountManager alloc] initWithAppKey:@"upqcuw4fwo1hotd" secret:@"bqbhx0yn1my6emt"];
    [DBAccountManager setSharedManager:accountMgr];
    DBAccount *account = accountMgr.linkedAccount;
    
    if (account) {
        DBFilesystem *filesystem = [[DBFilesystem alloc] initWithAccount:account];
        [DBFilesystem setSharedFilesystem:filesystem];
    }
    
    //TODO: Not sure this should exist
	alertView = [[UIAlertView alloc] initWithTitle:@"Accessory Not Found"
										   message:@"Fighting Walrus Radio is not attached."
										  delegate:self
								 cancelButtonTitle:@"Retry"
								 otherButtonTitles:@"More Info", nil];
    

    
    shared = self;

    // Configure ios version specific settings
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {

    } else {
        // Status bar content is black by default on ios7
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        self.window.tintColor = [[GCSThemeManager sharedInstance] appTintColor];
    }
    
    NSLog(@"Application finished launching.");

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    if (alertView.visible) {
		[alertView dismissWithClickedButtonIndex:0 animated:YES];
	}
    
	NSLog(@"Going Inactive");
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    
	[updateTimer invalidate]; // shutdown the timer;
    
	NSLog(@"Entering Background");
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    
	NSLog(@"Entering Foreground");
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    
    NSLog(@"Became Active");
	// startup my application update timer
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    
    [[CommController sharedInstance] closeAllInterfaces];
    
    if (alertView.visible) {
		[alertView dismissWithClickedButtonIndex:0 animated:YES];
	}
    
	NSLog(@"Terminating");
}

// Called when an alert button is tapped.
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	switch (buttonIndex) {
		case 0:
			break;
		case 1:
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.fightingwalrus.com"]];
		default:
			break;
	}
}



+(AppDelegate*)sharedDelegate
{
    return shared;
}

static int counter = 0;


- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    

    NSLog(@"openURL: Assuming URL is for Dropbox API.");

    DBAccount *account = [[DBAccountManager sharedManager] handleOpenURL:url];
    if (account) {
        DBFilesystem *filesystem = [[DBFilesystem alloc] initWithAccount:account];
        [DBFilesystem setSharedFilesystem:filesystem];
        NSLog(@"App linked successfully!");
        return YES;
    }
    
    return NO;
}

@end
