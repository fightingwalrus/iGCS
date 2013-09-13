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

typedef NS_ENUM(NSUInteger, GCSCommInterface) {
    GCSRovingBluetoothNetworkCommInterface,
    GCSRedparkCommInterface,
    GCSFightingWalrusRadioCommInterface
};

@implementation CommController

+(CommController *)sharedInstance{
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

// called at startup for app to initialize interfaces
// input: instance of MainViewController - used to trigger view updates during comm operations
-(void)start:(MainViewController*)mvc
{
    @try {
        self.mainVC = mvc;
        
        [self createDefaultConnections:GCSRovingBluetoothNetworkCommInterface];
        
        [DebugLogger console:@"Created default connections in CommController."];
    }
    @catch (NSException *exception) {
        [DebugLogger dumpException:exception];
    }
}

#pragma mark -
#pragma mark connection managment
-(void)createDefaultConnections:(GCSCommInterface) commInterface {
    
    // Reset any active connections in the connection pool first
    [self closeAllInterfaces];
    
    _mavLinkInterface = [iGCSMavLinkInterface createWithViewController:self.mainVC];
    [_connectionPool addDestination:self.mavLinkInterface];
    [DebugLogger console:@"Configured iGCS Application as MavLink consumer."];
    
    if (commInterface == GCSRovingBluetoothNetworkCommInterface) {
        [DebugLogger console: @"Creating RovingNetworks connection."];
        [self setupBluetoothConnections];
        [DebugLogger console:@"RovingNetworks disabled..."];
        
    } else if (commInterface ==  GCSRedparkCommInterface) {
        [self setupRedparkConnections];
        
    } else if (commInterface == GCSFightingWalrusRadioCommInterface) {
        NSLog(@"FWR Not currectly supported");
    } else {
        NSLog(@"createDefaultConnections: unsupported Inteface specificed");
    }
}

-(void) setupBluetoothConnections {
    if (!_rnBluetooth) {
        _rnBluetooth = [RNBluetoothInterface create];
    }
    
    if (_rnBluetooth) {
        [_connectionPool addSource:_rnBluetooth];
        
        [_connectionPool createConnection:_rnBluetooth destination:_mavLinkInterface];
        
        [DebugLogger console:@"Connected RN Bluetooth Rx to iGCS Application input."];
        
        [_connectionPool createConnection:_mavLinkInterface destination:_rnBluetooth];
        
        [DebugLogger console:@"Connected iGCS Application output to RN Bluetooth Tx."];
    } else {
        [DebugLogger console:@"Could not establish bluetooth inteface"];
    }
}

-(void)setupRedparkConnections {
    if (!_redParkCable) {
        [DebugLogger console:@"Starting Redpark connection."];
        _redParkCable = [RedparkSerialCable createWithViews:_mainVC];
    }
    
    if (_redParkCable) {
        // configure input connection as redpark cable
        [DebugLogger console:@"Redpark started."];
        [_connectionPool addSource:_redParkCable];
        
        // Forward redpark RX to app input
        [_connectionPool createConnection:_redParkCable destination:_mavLinkInterface];
        [DebugLogger console:@"Connected Redpark Rx to iGCS Application input."];
        
        // Forward app output to redpark TX
        [_connectionPool createConnection:_mavLinkInterface destination:_redParkCable];
        [DebugLogger console:@"Connected iGCS Application output to Redpark Tx."];
    }
}

-(void) closeAllInterfaces
{
    [_connectionPool closeAllInterfaces];
}

#pragma mark -
#pragma mark Bluetooth

-(void) startBluetoothTx
{
    // Start Bluetooth driver
    BluetoothStream *bts = [BluetoothStream createForTx];
    
    // Create connection from redpark to bts
    [_connectionPool createConnection:_redParkCable destination:bts];
    
    [DebugLogger console:@"Created BluetoothStream for Tx."];
    NSLog(@"Created BluetoothStream for Tx: %@",[bts description]);
}

-(void) startBluetoothRx
{
    // Start Bluetooth driver
    BluetoothStream *bts = [BluetoothStream createForRx];
    
    // Create connection from redpark to bts
    [_connectionPool createConnection:bts destination:_mavLinkInterface];
    
    [DebugLogger console:@"Created BluetoothStream for Rx."];
    NSLog(@"Created BluetoothStream for Rx: %@",[bts description]);
}

@end
