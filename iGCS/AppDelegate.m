//
//  AppDelegate.m
//  iGCS
//
//  Created by Claudio Natoli on 5/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

#import "DDFileLogger.h"
#import "DDTTYLogger.h"

// API keys for hockeyapp.net etc are passed in via scrips/build.sh
// from a private xcconfig file using GCC_PREPROCESSOR_DEFINITIONS
#if defined(HOCKEY_APP_BETA_ID) && defined(HOCKEY_APP_BETA_SECRET)
#import <HockeySDK/HockeySDK.h>
#endif

#import "CommController.h"
#import "GCSSpeechManager.h"

@implementation AppDelegate

static AppDelegate *shared;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
#if DEBUG
    DDFileLogger* fileLogger = [[DDFileLogger alloc] init];
    fileLogger.rollingFrequency = 60 * 60 * 1; // 1 hour
    fileLogger.logFileManager.maximumNumberOfLogFiles = 5;
    [DDLog addLogger:fileLogger];
#endif
    [DDLog addLogger:[DDTTYLogger sharedInstance]];

    
#if defined(HOCKEY_APP_BETA_ID) && defined(HOCKEY_APP_BETA_SECRET)
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:HOCKEY_APP_BETA_ID];
    [[BITHockeyManager sharedHockeyManager].authenticator setAuthenticationSecret:HOCKEY_APP_BETA_SECRET];
    [[BITHockeyManager sharedHockeyManager].authenticator setIdentificationType:BITAuthenticatorIdentificationTypeHockeyAppEmail];
    [[BITHockeyManager sharedHockeyManager] startManager];
    [[BITHockeyManager sharedHockeyManager].authenticator authenticateInstallation];
#endif

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

    // call on startup to setup NSNotifcation observers
    [GCSSpeechManager sharedInstance];

    DDLogInfo(@"Application finished launching.");

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */

    [[CommController sharedInstance] closeAllInterfaces];
    if (alertView.visible) {
		[alertView dismissWithClickedButtonIndex:0 animated:YES];
	}
    
	NSLog(@"Going Inactive");
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */

	[updateTimer invalidate]; // shutdown the timer;
    
	NSLog(@"Entering Background");
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    
	NSLog(@"Entering Foreground");
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    
    NSLog(@"Became Active");
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    [[CommController sharedInstance] startTelemetryMode];
}

- (void)applicationWillTerminate:(UIApplication *)application {
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
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	switch (buttonIndex) {
		case 0:
			break;
		case 1:
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.fightingwalrus.com"]];
		default:
			break;
	}
}


+(AppDelegate*)sharedDelegate {
    return shared;
}


- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return NO;
}

@end
