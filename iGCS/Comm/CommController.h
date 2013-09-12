//
//  CommController.h
//  iGCS
//
//  Created by Andrew Aarestad on 2/22/13.
//
//

#import <Foundation/Foundation.h>

#import "CommConnection.h"
#import "CommConnectionPool.h"

#import "RedparkSerialCable.h"
#import "FightingWalrusRadio.h"
#import "SocketStream.h"
#import "BluetoothStream.h"

#import "iGCSMavLinkInterface.h"
#import "iGCSRadioConfig.h"

#import "CommInterface.h"

#import "MainViewController.h"



@interface CommController : NSObject

+(void)start:(MainViewController*)mvc;

+(void) startBluetoothTx;
+(void) startBluetoothRx;

+(iGCSMavLinkInterface*)appMLI;

+(void) closeAllInterfaces;

@end
