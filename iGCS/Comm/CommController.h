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
#import "GCSFWRFirmwareInterface.h"

#import "RNBluetoothInterface.h"
#import "FightingWalrusInterface.h"
#import "BluetoothStream.h"
#ifdef REDPARK
#import "RedparkSerialCable.h"
#endif


typedef NS_ENUM(NSUInteger, GCSAccessory) {
    GCSAccessoryRovingBluetooth,
    GCSAccessoryRedpark,
    GCSAccessoryFightingWalrusRadio,
    GCSAccessoryNotSupported
};

@interface CommController : NSObject <UIAlertViewDelegate>

@property (nonatomic, retain) MainViewController *mainVC;
@property (nonatomic, retain) CommConnectionPool *connectionPool;

// local interfaces
@property (nonatomic, retain) iGCSMavLinkInterface *mavLinkInterface;
@property (nonatomic, retain) iGCSRadioConfig *radioConfig;
@property (nonatomic, strong) GCSFWRFirmwareInterface *fwrFirmwareInterface;

// remote interfaces
@property (nonatomic, retain) RNBluetoothInterface *rnBluetooth;
@property (nonatomic, retain) FightingWalrusInterface *fightingWalrusInterface;
#ifdef REDPARK
@property (nonatomic, retain) RedparkSerialCable *redParkCable;
#endif

+(CommController *)sharedInstance;

-(void)startFWRConfigMode;
-(void)startFWRFirmwareUpdateMode;

// called to start or restart telemetry mode
// self.mainVC cannot be nil
-(void)startTelemetryMode;


-(void) startBluetoothTx;
-(void) startBluetoothRx;
-(void) closeAllInterfaces;
-(GCSAccessory)connectedAccessory;

@end

extern NSString * const GCSCommControllerFightingWalrusRadioNotConnected;
