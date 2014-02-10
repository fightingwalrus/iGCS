//
//  CommController.h
//  iGCS
//
//  Created by Andrew Aarestad on 2/22/13.
//
//

#import <Foundation/Foundation.h>
#import <ExternalAccessory/ExternalAccessory.h>


#import "CommConnection.h"
#import "CommConnectionPool.h"

#import "RedparkSerialCable.h"
#import "BluetoothStream.h"

#import "iGCSMavLinkInterface.h"
#import "iGCSRadioConfig.h"
#import "RNBluetoothInterface.h"
#import "FightingWalrusInterface.h"

#import "CommInterface.h"

#import "MainViewController.h"



@interface CommController : NSObject

@property (nonatomic, retain) CommConnectionPool *connectionPool;
@property (nonatomic, retain) MainViewController *mainVC;
@property (nonatomic, retain) iGCSMavLinkInterface *mavLinkInterface;
@property (nonatomic, retain) RNBluetoothInterface *rnBluetooth;
@property (nonatomic, retain) RedparkSerialCable *redParkCable;
@property (nonatomic, retain) iGCSRadioConfig *radioConfig;
@property (nonatomic, retain) FightingWalrusInterface *fightingWalrusInterface;

+(CommController *)sharedInstance;

-(void)start:(MainViewController*)mvc;

-(void) startBluetoothTx;
-(void) startBluetoothRx;
-(void) closeAllInterfaces;

@end
