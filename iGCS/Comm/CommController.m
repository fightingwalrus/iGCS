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
#import "RNBluetoothInterface.h"


@implementation CommController



static CommConnectionPool *connections;
static MainViewController *mainVC;
static iGCSMavLinkInterface *appMLI;
static RedparkSerialCable *redParkCable;
static RNBluetoothInterface *rnBluetooth;
static iGCSRadioConfig *radioConfig;

// called at startup for app to initialize interfaces
// input: instance of MainViewController - used to trigger view updates during comm operations
+(void)start:(MainViewController*)mvc
{
    @try {
        connections = [[CommConnectionPool alloc] init];
        
        mainVC = mvc;
        
        [self createDefaultConnections];
        
        [DebugLogger console:@"Created default connections in CommController."];
    }
    @catch (NSException *exception) {
        [DebugLogger dumpException:exception];
    }
    
}


// TODO: Move this stuff to user defaults controllable in app views
+(void)createDefaultConnections
{
    
    appMLI = [iGCSMavLinkInterface createWithViewController:mainVC];
    [connections addDestination:appMLI];
    [DebugLogger console:@"Configured iGCS Application as MavLink consumer."];
    
    [DebugLogger console: @"Creating RovingNetworks connection."];
//    rnBluetooth = [RNBluetoothInterface create];
    [DebugLogger console:@"RovingNetworks disabled..."];
    
    if (rnBluetooth)
    {
        [connections addSource:rnBluetooth];
        
        [connections createConnection:rnBluetooth destination:appMLI];
        
        [DebugLogger console:@"Connected RN Bluetooth Rx to iGCS Application input."];
        
        [connections createConnection:appMLI destination:rnBluetooth];
        
        [DebugLogger console:@"Connected iGCS Application output to RN Bluetooth Tx."];
    }
    
    else
        // Do Redpark instead
    {
        
        // configure input connection as redpark cable
        [DebugLogger console:@"Starting Redpark connection."];
        redParkCable = [RedparkSerialCable createWithViews:mainVC];
        
        [DebugLogger console:@"Redpark started."];
        [connections addSource:redParkCable];
    
        
        // Forward redpark RX to app input
        [connections createConnection:redParkCable destination:appMLI];
        
        
        [DebugLogger console:@"Connected Redpark Rx to iGCS Application input."];
        
        
        // Forward app output to redpark TX
        [connections createConnection:appMLI destination:redParkCable];
    
        
        [DebugLogger console:@"Connected iGCS Application output to Redpark Tx."];
        
    }

}


+(iGCSMavLinkInterface*)appMLI
{
    return appMLI;
}


+(void) startBluetoothTx
{
    // Start Bluetooth driver
    BluetoothStream *bts = [BluetoothStream createForTx];
    
    
    // Create connection from redpark to bts
    [connections createConnection:redParkCable destination:bts];
    
    
    [DebugLogger console:@"Created BluetoothStream for Tx."];
    
    NSLog(@"Created BluetoothStream for Tx: %@",[bts description]);
    
}

+(void) startBluetoothRx
{
    // Start Bluetooth driver
    BluetoothStream *bts = [BluetoothStream createForRx];
    
    
    // Create connection from redpark to bts
    [connections createConnection:bts destination:appMLI];
    
    
    [DebugLogger console:@"Created BluetoothStream for Rx."];
    NSLog(@"Created BluetoothStream for Rx: %@",[bts description]);
    
}


+(void) closeAllInterfaces
{
    [connections closeAllInterfaces];
}


@end




