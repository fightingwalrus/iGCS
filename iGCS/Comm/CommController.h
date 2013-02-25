//
//  CommController.h
//  iGCS
//
//  Created by Andrew Aarestad on 2/22/13.
//
//

#import <Foundation/Foundation.h>

#import "MavLinkConnection.h"
#import "MavLinkConnectionPool.h"

#import "RedparkSerialCable.h"
#import "FightingWalrusRadio.h"
#import "SocketStream.h"
#import "BluetoothStream.h"

#import "iGCSMavLinkInterface.h"


#import "MavLinkInterface.h"

#import "MainViewController.h"



@interface CommController : NSObject





+(void)start:(MainViewController*)mvc;

+(void) startBluetooth:(BOOL)isPeripheral;

+(iGCSMavLinkInterface*)appMLI;


@end
