//
//  RedparkSerialCable.h
//  iGCS
//
//  Created by Andrew Aarestad on 2/22/13.
//
//

#import <Foundation/Foundation.h>
#import "CommInterface.h"
#import "MainViewController.h"

@class GCDAsyncSocket;

@interface WiFlyInterface : CommInterface

+(WiFlyInterface*)createWithViews:(MainViewController*)mvc;

@property(strong, nonatomic) GCDAsyncSocket *socket;

@property (strong) MainViewController *mainVC;
@property(assign) BOOL connected;

- (void)connectTo3DRRadio;

@end
