//
//  CommController.m
//  iGCS
//
//  Created by Andrew Aarestad on 2/22/13.
//
//

#import "CommController.h"
#import "SoundUtils.h"
#import "GCSAccessoryFirmwareUtils.h"

NSString * const GCSCommControllerRadioNotConnected = @"com.fightingwalrus.commcontroller.radio.notconnected";

@interface CommController()
@property (nonatomic, strong) UIAlertView *alertView;
@property (nonatomic, readwrite) BOOL doubleTap;
@property (readwrite) NSUInteger accesoryConnectID;
@property (readwrite) NSUInteger accesoryDisconnectID;
@end

@implementation CommController

+(CommController *)sharedInstance {
    static CommController *sharedObject = nil;
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
        sharedObject = [[self alloc] init];
    });
    
    return sharedObject;
}

-(instancetype) init {
    self = [super init];
    if (self) {
        _connectionPool = [[CommConnectionPool alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessoryConnected:)
                                                     name:EAAccessoryDidConnectNotification object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessoryDisconnected:)
                                                     name:EAAccessoryDidDisconnectNotification object:nil];

        [[EAAccessoryManager sharedAccessoryManager] registerForLocalNotifications];

    }
    return self;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
#pragma mark NSNotifications

- (void)accessoryConnected:(NSNotification *)notification {
	NSLog(@"FightingWalrusInterface: accessoryConnected");
    NSLog(@"FightingWalrusInterface: accessoryConnected: notification Name: %@",notification.name);
    NSLog(@"Notification: %@",notification.userInfo);

    // handle duplication messages we always get on connect
    EAAccessory *connectedAccessor = notification.userInfo[EAAccessoryKey];
    if(self.accesoryConnectID != connectedAccessor.connectionID) {
        self.accesoryConnectID = connectedAccessor.connectionID;
        [self performSelector:@selector(startTelemetryMode) withObject:nil afterDelay:1.5];
        [SoundUtils vibrateOrBeepBeep];
    }
}

- (void)accessoryDisconnected:(NSNotification *)notification {
	NSLog(@"FightingWalrusInterface: accessoryDisconnected");
    NSLog(@"FightingWalrusInterface: accessoryDisconnected: notification Name: %@",notification.name);
    // handle duplication messages we always get on dissconnect
    [self closeAllInterfaces];
}

// input: instance of MainViewController - used to trigger view updates during comm operations
// called at startup for app to initialize interfaces
// input: instance of MainViewController - used to trigger view updates during comm operations
-(void)startTelemetryMode {
    DDLogInfo(@"CommController: startTelemetryMode");
    @try {
        NSAssert(self.mainVC, @"CommController.startTelemetryMode: mainVC cannot be nil");
        // Reset any active connections in the connection pool first
        [self closeAllInterfaces];

        self.mavLinkInterface = [iGCSMavLinkInterface createWithViewController:self.mainVC];
        NSAssert(self.mavLinkInterface, @"CommController.startTelemetryMode: mavLinkInterface cannot be nil");

        GCSAccessory accessory = [self connectedAccessory];
        if (accessory == GCSAccessoryFightingWalrusRadio) {
            
            self.fightingWalrusInterface = [FightingWalrusInterface createWithProtocolString:GCSProtocolStringTelemetry];

            NSAssert(self.fightingWalrusInterface, @"CommController.startTelemetryMode: fightingWalrusInterface cannot be nil");

            [self setupNewConnectionsWithRemoteInterface:self.fightingWalrusInterface
                                       andLocalInterface:self.mavLinkInterface];
        } else if (accessory == GCSAccessoryRedpark) {

            #ifdef REDPARK
            self.redParkCable = [RedparkSerialCable createWithViews:self.mainVC];
            [self setupNewConnectionsWithRemoteInterface:self.redParkCable
                                       andLocalInterface:self.mavLinkInterface];
            #endif

        } else if (accessory == GCSAccessoryRovingBluetooth) {
            self.rnBluetooth = [RNBluetoothInterface create];
            [self setupNewConnectionsWithRemoteInterface:self.rnBluetooth
                                       andLocalInterface:self.mavLinkInterface];

        } else {
            DDLogInfo(@"No supported accessory connected");
        }
    }
    @catch (NSException *exception) {
        DDLogError(@"Error starting Telemetry Mode %@",[exception description]);
    }
}

-(void)startFWRConfigMode {
    DDLogDebug(@"startFWRConfigMode");
    [self closeAllInterfaces];

    GCSAccessory accessory = [self connectedAccessory];
    if (accessory == GCSAccessoryFightingWalrusRadio) {

        self.radioConfig = [[iGCSRadioConfig alloc] init];
        self.fightingWalrusInterface = [FightingWalrusInterface createWithProtocolString:GCSProtocolStringConfig];
        [self setupNewConnectionsWithRemoteInterface:self.fightingWalrusInterface andLocalInterface:self.radioConfig];

    } else {
        DDLogDebug(@"No supported accessory connected");
        [[NSNotificationCenter defaultCenter] postNotificationName:GCSCommControllerRadioNotConnected object:nil];
    }
}

-(void)startFWRFirmwareUpdateMode {
    DDLogDebug(@"startFWRConfigMode");
    [self closeAllInterfaces];

    GCSAccessory accessory = [self connectedAccessory];
    if (accessory == GCSAccessoryFightingWalrusRadio) {

        self.accessoryFirmwareInterface = [[GCSAccessoryFirmwareInterface alloc] init];
        self.fightingWalrusInterface = [FightingWalrusInterface createWithProtocolString:GCSProtocolStringUpdate];
        [self setupNewConnectionsWithRemoteInterface:self.fightingWalrusInterface andLocalInterface:self.accessoryFirmwareInterface];

    } else {
        DDLogDebug(@"No supported accessory connected");
        [[NSNotificationCenter defaultCenter] postNotificationName:GCSCommControllerRadioNotConnected object:nil];
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
    DDLogInfo(@"Created BluetoothStream for Tx: %@",[bts description]);
}

-(void) startBluetoothRx {
    // Start Bluetooth driver
    BluetoothStream *bts = [BluetoothStream createForRx];
    
    // Create connection from redpark to bts
    [self.connectionPool createConnection:bts destination:self.mavLinkInterface];
    DDLogInfo(@"Created BluetoothStream for Rx: %@",[bts description]);
}

#pragma mark - helpers
-(GCSAccessory)connectedAccessory {
    NSMutableArray *accessories = [[NSMutableArray alloc] initWithArray:[[EAAccessoryManager sharedAccessoryManager]
                                                                         connectedAccessories]];
    GCSAccessory gcsAccessory = GCSAccessoryNotSupported;
    for (EAAccessory *accessory in accessories) {
        DDLogDebug(@"%@",accessory.manufacturer);

        if ([GCSAccessoryFirmwareUtils isAccessorySupportedWithAccessory:accessory]) {
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

#pragma mark - alert messages


- (void)showAccessoryConnectedAlertWithUserInfo:(NSDictionary *)userInfo {
#ifdef DEBUG
	DDLogInfo(@"accessoryConnected");
    NSString *message = [NSString stringWithFormat:@"Accessor connected with userInfo: %@", userInfo];
    self.alertView = [[UIAlertView alloc] initWithTitle:@"Accessory Connected!!!" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [self.alertView show];
#endif
}

- (void)showAccessoryDisconnectedAlertWithUserInfo:(NSDictionary *)userInfo {
#ifdef DEBUG
	DDLogInfo(@"accessoryDisconnected");
    NSString *message = [NSString stringWithFormat:@"Accessor Disconnected: %@", userInfo];
    self.alertView = [[UIAlertView alloc] initWithTitle:@"Accessory Disconnected" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [self.alertView show];
#endif
}

#pragma UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    return;
}

@end
