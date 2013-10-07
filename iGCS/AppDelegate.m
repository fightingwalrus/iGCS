//
//  AppDelegate.m
//  iGCS
//
//  Created by Claudio Natoli on 5/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

#import "CommController.h"

#import <BugSense-iOS 2/BugSenseController.h>

#include <Dropbox/Dropbox.h>


#import "DebugLogger.h"

#define REQUIRE_WALRUS 0

#define ENABLE_BUGSENSE 1


@implementation AppDelegate

static AppDelegate *shared;

@synthesize window = _window;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    // set up defaults
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"videoSource": @"testStream", @"videoScaleFactor": @1,
     @"videoDisplayLocation": @"corner"}];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        // Yes, so just open the session (this won't display any UX).
        [self openSession];
    } else {
        // No, display the login page.
        //[self showLoginView];
    }
    
    
    if (ENABLE_BUGSENSE)
    {
        // removed key until open source bugsense key is set up
        //[BugSenseController sharedControllerWithBugSenseAPIKey:@"key_removed_for_open_source_port"];
    }
    

    
    DBAccountManager* accountMgr = [[DBAccountManager alloc] initWithAppKey:@"upqcuw4fwo1hotd" secret:@"bqbhx0yn1my6emt"];
    [DBAccountManager setSharedManager:accountMgr];
    DBAccount *account = accountMgr.linkedAccount;
    
    if (account) {
        DBFilesystem *filesystem = [[DBFilesystem alloc] initWithAccount:account];
        [DBFilesystem setSharedFilesystem:filesystem];
    }
    
    
    // TODO: Move this into FightingWalrus Interface to support non-FW operation
    // startup the external accessory manager
    
	walrus = [[FightingWalrusProtocol alloc] init];
    
    NSLog(@"Walrus protocol started.");
    
	alertView = [[UIAlertView alloc] initWithTitle:@"Accessory Not Found"
										   message:@"Fighting Walrus Radio is not attached."
										  delegate:self
								 cancelButtonTitle:@"Retry"
								 otherButtonTitles:@"More Info", nil];
    

    
    shared = self;
    
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
    
    [self.session handleDidBecomeActive];
    
    // TODO: Move this timer into the FightingWalrus radio only as radio poll rate
    updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 // every 100msecs
												   target:self
												 selector:@selector(appUpdate:)
												 userInfo:nil
												  repeats:YES];
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    
    [CommController closeAllInterfaces];
    
    [self.session close];
    
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

// periodic timer to poll the accessory
// TODO: Move this into FW Interface
- (void)appUpdate:(NSTimer*)theTimer
{
    //[DebugLogger console:@"appUpdate: %i",counter];
    counter++;
    
	if([walrus isConnected])
	{
        // Poll accessory
        // No data currently polled from radio, data is handled as stream events
	}
    else
    {
        if (REQUIRE_WALRUS)
        {
            // Nothing is connected so show the alert
		
            if (![alertView isVisible]) {
                [alertView show];
            }
        }
		
    }
}


- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    
    if([[url scheme] caseInsensitiveCompare:@"fb"] == NSOrderedSame)
    {
        NSLog(@"FacebookAPI:openURL: %@",[url description]);
        return [self.session handleOpenURL:url];
    }
    else
    {
        NSLog(@"openURL: Assuming URL is for Dropbox API.");
        
        DBAccount *account = [[DBAccountManager sharedManager] handleOpenURL:url];
        if (account) {
            DBFilesystem *filesystem = [[DBFilesystem alloc] initWithAccount:account];
            [DBFilesystem setSharedFilesystem:filesystem];
            NSLog(@"App linked successfully!");
            return YES;
        }
    }
    
    return NO;
    
    
}



- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error
{
    NSLog(@"FBSession state changed: %u",state);
    switch (state) {
        case FBSessionStateOpen: {
            NSLog(@"FBSessionStateOpen");
            // UIViewController *topViewController = [self.navController topViewController];
            /*
            if ([[topViewController modalViewController]
                 isKindOfClass:[SCLoginViewController class]]) {
                [topViewController dismissModalViewControllerAnimated:YES];
            }*/
        }
            break;
        case FBSessionStateClosed:
            NSLog(@"FBSessionStateClosed");
        case FBSessionStateClosedLoginFailed:
            NSLog(@"FBSessionStateClosedLoginFailed");
            // Once the user has logged in, we want them to
            // be looking at the root view.
            //[self.navController popToRootViewControllerAnimated:NO];
            
            [FBSession.activeSession closeAndClearTokenInformation];
            
            //[self showLoginView];
            break;
        default:
            NSLog(@"default");
            break;
    }
    
    if (error) {
        UIAlertView *loginFailView = [[UIAlertView alloc]
                                  initWithTitle:@"Error"
                                  message:error.localizedDescription
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [loginFailView show];
    }
}

- (void)openSession
{
    if (self.session.isOpen) {
        // if a user logs out explicitly, we delete any cached token information, and next
        // time they run the applicaiton they will be presented with log in UX again; most
        // users will simply close the app or switch away, without logging out; this will
        // cause the implicit cached-token login to occur on next launch of the application
        [self.session closeAndClearTokenInformation];
        
    } else {
        if (self.session.state != FBSessionStateCreated) {
            // Create a new, logged out session.
            self.session = [[FBSession alloc] init];
        }
        
        // if the session isn't open, let's open it now and present the login UX to the user
        [self.session openWithCompletionHandler:^(FBSession *session,
                                                         FBSessionState status,
                                                         NSError *error) {
            // and here we make sure to update our UX according to the new session state
            NSLog(@"FBSession open callback");  
            //[self updateView];
        }];
    }
    
    /*
    [FBSession openActiveSessionWithReadPermissions:nil
                                       allowLoginUI:YES
                                  completionHandler:
     ^(FBSession *session,
       FBSessionState state, NSError *error) {
         [self sessionStateChanged:session state:state error:error];
     }];
     */
}

@end
