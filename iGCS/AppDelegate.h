//
//  AppDelegate.h
//  iGCS
//
//  Created by Claudio Natoli on 5/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TestFlight.h"

#import "FightingWalrusProtocol.h"

#define TESTING 1

#ifdef TESTING
#define TESTFLIGHT_CHECKPOINT(X) [TestFlight passCheckpoint:(X)]
#else
#define TESTFLIGHT_CHECKPOINT(X)
#endif

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    FightingWalrusProtocol *walrus;
    
    
	UIAlertView *alertView;
    
    
	NSTimer *updateTimer;
    
}

@property (strong, nonatomic) UIWindow *window;

@end
