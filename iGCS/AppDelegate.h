//
//  AppDelegate.h
//  iGCS
//
//  Created by Claudio Natoli on 5/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <FacebookSDK/FacebookSDK.h>

#import "FightingWalrusProtocol.h"

#define TESTING 1

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    FightingWalrusProtocol *walrus;
    
    
	UIAlertView *alertView;
    
    
	NSTimer *updateTimer;
    
}

@property (strong, nonatomic) UIWindow *window;

// FBSample logic
// In this sample the app delegate maintains a property for the current
// active session, and the view controllers reference the session via
// this property, as well as play a role in keeping the session object
// up to date; a more complicated application may choose to introduce
// a simple singleton that owns the active FBSession object as well
// as access to the object by the rest of the application
@property (strong, nonatomic) FBSession *session;


+(AppDelegate*)sharedDelegate;

- (void)openSession;

@end
