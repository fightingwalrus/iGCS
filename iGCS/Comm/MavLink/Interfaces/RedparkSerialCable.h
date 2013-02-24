//
//  RedparkSerialCable.h
//  iGCS
//
//  Created by Andrew Aarestad on 2/22/13.
//
//

#import <Foundation/Foundation.h>
#import "MavLinkInterface.h"
#import "RscMgr.h"

#import "MainViewController.h"

@interface RedparkSerialCable : MavLinkInterface <RscMgrDelegate>

+(RedparkSerialCable*)createWithViews:(MainViewController*)mvc;



@property (strong) RscMgr *rscMgr;
@property BOOL cableConnected;



@property (strong) MainViewController *mainVC;


@end
