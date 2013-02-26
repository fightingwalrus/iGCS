//
//  CommController.m
//  iGCS
//
//  Created by Andrew Aarestad on 2/22/13.
//
//

#import "CommController.h"

#import "DebugViewController.h"

@implementation CommController



static MavLinkConnectionPool *connections;
static MainViewController *mainVC;

static iGCSMavLinkInterface *appMLI;

static RedparkSerialCable *redParkCable;


// called at startup for app to initialize interfaces
// input: instance of MainViewController - used to trigger view updates during comm operations
+(void)start:(MainViewController*)mvc
{
    
    connections = [[MavLinkConnectionPool alloc] init];
    
    mainVC = mvc;
    
    [self createDefaultConnections];
    
    [mainVC.debugVC consoleMessage:@"Created default connections in CommController."];
    
    
    
}



// TODO: Move this stuff to user defaults controllable in app views
+(void)createDefaultConnections
{
    
    appMLI = [iGCSMavLinkInterface createWithViewController:mainVC];
    
    // configure input connection as redpark cable
    [mainVC.debugVC consoleMessage:@"Starting Redpark connection."];
    redParkCable = [RedparkSerialCable createWithViews:mainVC];
    
    [mainVC.debugVC consoleMessage:@"Redpark started."];
    [connections addSource:redParkCable];
    
    
    // configure output connection as iGCSMavLinkInterface
    [connections addDestination:appMLI];
    
    [mainVC.debugVC consoleMessage:@"Configured iGCS Application as MavLink consumer."];
    
    
    
    // Forward redpark RX to app input
    [connections createConnection:redParkCable destination:appMLI];
    
    
    [mainVC.debugVC consoleMessage:@"Connected Redpark Rx to iGCS Application input."];
    
    
    // Forward app output to redpark TX
    [connections createConnection:appMLI destination:redParkCable];
    
    
    [mainVC.debugVC consoleMessage:@"Connected iGCS Application output to Redpark Tx."];
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
    
    
    [mainVC.debugVC consoleMessage:@"Created BluetoothStream for Tx."];
    
    NSLog(@"Created BluetoothStream for Tx: %@",[bts description]);
    
}

+(void) startBluetoothRx
{
    // Start Bluetooth driver
    BluetoothStream *bts = [BluetoothStream createForRx];
    
    
    // Create connection from redpark to bts
    [connections createConnection:bts destination:appMLI];
    
    
    [mainVC.debugVC consoleMessage:@"Created BluetoothStream for Rx."];
    NSLog(@"Created BluetoothStream for Rx: %@",[bts description]);
    
}


+(void) closeAllInterfaces
{
    [connections closeAllInterfaces];
}


@end




