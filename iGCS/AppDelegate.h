//
//  AppDelegate.h
//  iGCS
//
//  Created by Claudio Natoli on 5/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FightingWalrusProtocol.h"

#define TESTING 1
#define GLOBAL_TINT [UIColor colorWithRed:0.80 green:0.52 blue:0.25 alpha:1.0]  // Peru Brown

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    FightingWalrusProtocol *walrus;
	UIAlertView *alertView;
	NSTimer *updateTimer;
}

@property (strong, nonatomic) UIWindow *window;
+(AppDelegate*)sharedDelegate;
@end
