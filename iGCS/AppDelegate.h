//
//  AppDelegate.h
//  iGCS
//
//  Created by Claudio Natoli on 5/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FightingWalrusProtocol.h"
#import "GCSThemeManager.h"

#define TESTING 1

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    FightingWalrusProtocol *walrus;
	UIAlertView *alertView;
	NSTimer *updateTimer;
}

@property (strong, nonatomic) UIWindow *window;
+(AppDelegate*)sharedDelegate;
@end
