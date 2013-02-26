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
    [mainVC.debugVC errorMessage:@"Test message."];
    
    
    
}



// TODO: Move this stuff to user defaults controllable in app views
+(void)createDefaultConnections
{
    
    appMLI = [iGCSMavLinkInterface createWithViewController:mainVC];
    
    // configure input connection as redpark cable
    redParkCable = [RedparkSerialCable createWithViews:mainVC];
    
    [connections addSource:redParkCable];
    
    
    // configure output connection as iGCSMavLinkInterface
    [connections addDestination:appMLI];
    
    
    
    // Forward redpark RX to app input
    [connections createConnection:redParkCable destination:appMLI];
    
    
    // Forward app output to redpark TX
    [connections createConnection:appMLI destination:redParkCable];
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
    
    
    NSLog(@"Created BluetoothStream for Tx: %@",[bts description]);
    
}

+(void) startBluetoothRx
{
    // Start Bluetooth driver
    BluetoothStream *bts = [BluetoothStream createForRx];
    
    
    // Create connection from redpark to bts
    [connections createConnection:bts destination:appMLI];
    
    
    NSLog(@"Created BluetoothStream for Rx: %@",[bts description]);
    
}


+(void) closeAllInterfaces
{
    [connections closeAllInterfaces];
}


@end




