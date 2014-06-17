//
//  WiFlyInterface.h
//  iGCS
//
//  Created by James Adams on 6/17/14.
//
//

// See http://www.communistech.com/blog/?s=wifly#infra for full details on a WiFly bridge
// Here is the gist though:
//
/*
 Commands for configuring a WiFly module:
 
 set uart baudrate 57600
 save
 reboot
 set wlan join 7
 set ip dhcp 4
 set ip address 10.0.0.1
 set ip net 255.255.255.0
 set ip gateway 10.0.0.1
 set ip proto 2
 set apmode ssid APMNetwork
 save APMNetwork
 save
 reboot
 
 */

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
