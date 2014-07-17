//
//  CommController.m
//  iGCS
//
//  Created by Andrew Aarestad on 2/22/13.
//
//

#import "CommController.h"
#import "DebugViewController.h"
#import "DebugLogger.h"

typedef NS_ENUM(NSUInteger, GCSAccessory) {
    GCSAccessoryRovingBluetooth,
    GCSAccessoryRedpark,
    GCSAccessoryFightingWalrusRadio,
    GCSAccessoryNotSupported
};

@implementation CommController

+(CommController *)sharedInstance {
    static CommController *sharedObject = nil;
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
        sharedObject = [[self alloc] init];
    });
    
    return sharedObject;
}

-(id) init {
    self = [super init];
    if (self) {
        _connectionPool = [[CommConnectionPool alloc] init];
    }
    return self;
}

// input: instance of MainViewController - used to trigger view updates during comm operations
// called at startup for app to initialize interfaces
// input: instance of MainViewController - used to trigger view updates during comm operations
-(void)startTelemetryMode {
    @try {
        NSAssert(self.mainVC != nil, @"CommController.startTelemetryMode: mainVC cannot be nil");
        // Reset any active connections in the connection pool first
        [self closeAllInterfaces];

        self.mavLinkInterface = [iGCSMavLinkInterface createWithViewController:self.mainVC];

        GCSAccessory accessory = [self connectedAccessory];
        if (accessory == GCSAccessoryFightingWalrusRadio) {
            
            self.fightingWalrusInterface = [FightingWalrusInterface createWithProtocolString:GCSProtocolStringTelemetry];
            [self setupNewConnectionsWithRemoteInterface:self.fightingWalrusInterface
                                       andLocalInterface:self.mavLinkInterface];

        } else if (accessory == GCSAccessoryRedpark) {

            #ifdef REDPARK
            self.redParkCable = [RedparkSerialCable createWithViews:_mainVC];
            [self setupNewConnectionsWithRemoteInterface:self.redParkCable
                                       andLocalInterface:self.mavLinkInterface];
            #endif

        } else if (accessory == GCSAccessoryRovingBluetooth) {
            self.rnBluetooth = [RNBluetoothInterface create];
            [self setupNewConnectionsWithRemoteInterface:self.rnBluetooth
                                       andLocalInterface:self.mavLinkInterface];

        } else {
            NSLog(@"No supported accessory connected");
        }

        [DebugLogger console:@"Created default connections in CommController."];
    }
    @catch (NSException *exception) {
        [DebugLogger dumpException:exception];
    }
}

-(void)startFWRConfigMode {
    NSLog(@"startFWRConfigMode");
    [self closeAllInterfaces];

    GCSAccessory accessory = [self connectedAccessory];
    if (accessory == GCSAccessoryFightingWalrusRadio) {

        self.radioConfig = [[iGCSRadioConfig alloc] init];
        self.fightingWalrusInterface = [FightingWalrusInterface createWithProtocolString:GCSProtocolStringConfig];
        [self setupNewConnectionsWithRemoteInterface:self.fightingWalrusInterface andLocalInterface:self.radioConfig];

    } else {
        NSLog(@"No supported accessory connected");
    }
}

-(void)startFWRFirmwareUpdateMode {
    NSLog(@"startFWRConfigMode");
    [self closeAllInterfaces];

    GCSAccessory accessory = [self connectedAccessory];
    if (accessory == GCSAccessoryFightingWalrusRadio) {

        self.fwrFirmwareInterface = [[GCSFWRFirmwareInterface alloc] init];
        self.fightingWalrusInterface = [FightingWalrusInterface createWithProtocolString:GCSProtocolStringUpdate];
        [self setupNewConnectionsWithRemoteInterface:self.fightingWalrusInterface andLocalInterface:self.fwrFirmwareInterface];

    } else {
        NSLog(@"No supported accessory connected");
    }
}


#pragma mark -
#pragma mark connection managment

-(BOOL)setupNewConnectionsWithRemoteInterface:(CommInterface *)remoteInterface
                            andLocalInterface:(CommInterface *)localInterface {

    if (!remoteInterface && !localInterface) {
        return NO;
    }

    // add source and destination
    [self.connectionPool addSource:remoteInterface];
    [self.connectionPool addDestination:localInterface];

    // configure inbound connection (drone->gcs)
    [self.connectionPool createConnection:remoteInterface destination:localInterface];

    // configure outbound connection (gcs->drone)
    [self.connectionPool createConnection:localInterface destination:remoteInterface];

    return YES;
}

-(void) closeAllInterfaces {
    [self.connectionPool closeAllInterfaces];
}

#pragma mark -
#pragma mark Bluetooth

-(void) startBluetoothTx {
    // Start Bluetooth driver
    BluetoothStream *bts = [BluetoothStream createForTx];
    
    // Create connection from redpark to bts
#ifdef REDPARK
    [self.connectionPool createConnection:self.redParkCable destination:bts];
#endif
    [DebugLogger console:@"Created BluetoothStream for Tx."];
    NSLog(@"Created BluetoothStream for Tx: %@",[bts description]);
}

-(void) startBluetoothRx {
    // Start Bluetooth driver
    BluetoothStream *bts = [BluetoothStream createForRx];
    
    // Create connection from redpark to bts
    [self.connectionPool createConnection:bts destination:self.mavLinkInterface];
    
    [DebugLogger console:@"Created BluetoothStream for Rx."];
    NSLog(@"Created BluetoothStream for Rx: %@",[bts description]);
}

#pragma mark - helpers
-(GCSAccessory)connectedAccessory {
    NSMutableArray *accessories = [[NSMutableArray alloc] initWithArray:[[EAAccessoryManager sharedAccessoryManager]
                                                                         connectedAccessories]];

    GCSAccessory gcsAccessory = GCSAccessoryNotSupported;
    for (EAAccessory *accessory in accessories) {
        NSLog(@"%@",accessory.manufacturer);
        [DebugLogger console:[NSString stringWithFormat:@"%@",accessory.manufacturer]];

        if ([accessory.manufacturer isEqualToString:@"Fighting Walrus LLC"]) {
            gcsAccessory = GCSAccessoryFightingWalrusRadio;
            break;
        }

        if ([accessory.manufacturer isEqualToString:@"Redpark"]) {
            gcsAccessory = GCSAccessoryRedpark;
            break;
        }

        if([accessory.manufacturer isEqualToString:@"Roving Networks"]) {
            gcsAccessory = GCSAccessoryRovingBluetooth;
            break;
        }
    }
    return gcsAccessory;
}

@end
