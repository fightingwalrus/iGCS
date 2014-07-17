//
//  CommController.h
//  iGCS
//
//  Created by Andrew Aarestad on 2/22/13.
//
//

#import <Foundation/Foundation.h>
#import <ExternalAccessory/ExternalAccessory.h>

// VC dependency
#import "MainViewController.h"

// high level comm classes
#import "CommInterface.h"
#import "CommConnection.h"
#import "CommConnectionPool.h"

// local interfaces
#import "iGCSMavLinkInterface.h"
#import "RadioConfig.h"

#import "RNBluetoothInterface.h"
#import "FightingWalrusInterface.h"
#import "BluetoothStream.h"
#ifdef REDPARK
#import "RedparkSerialCable.h"
#endif

@interface CommController : NSObject

@property (nonatomic, retain) MainViewController *mainVC;
@property (nonatomic, retain) CommConnectionPool *connectionPool;

// local interfaces
@property (nonatomic, retain) iGCSMavLinkInterface *mavLinkInterface;
@property (nonatomic, retain) iGCSRadioConfig *radioConfig;

// remote interfaces
@property (nonatomic, retain) RNBluetoothInterface *rnBluetooth;
@property (nonatomic, retain) FightingWalrusInterface *fightingWalrusInterface;
#ifdef REDPARK
@property (nonatomic, retain) RedparkSerialCable *redParkCable;
#endif

+(CommController *)sharedInstance;

-(void)startFWRConfigMode;

// call to start/restart telemetry mode - requires self.mainVC
-(void)startTelemetryMode;


-(void) startBluetoothTx;
-(void) startBluetoothRx;
-(void) closeAllInterfaces;


@end
