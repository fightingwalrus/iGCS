//
//  CommController.m
//  iGCS
//
//  Created by Andrew Aarestad on 2/22/13.
//
//

#import "CommController.h"



@implementation CommController



static MavLinkConnectionPool *connections;
static MainViewController *mainVC;

static iGCSMavLinkInterface *appMLI;

static BluetoothStream *bts;


// called at startup for app to initialize interfaces
// input: instance of MainViewController - used to trigger view updates during comm operations
+(void)start:(MainViewController*)mvc
{
    
    connections = [[MavLinkConnectionPool alloc] init];
    
    mainVC = mvc;
    
    [self createDefaultConnections];
    
    
    
}



// TODO: Move this stuff to user defaults controllable in app views
+(void)createDefaultConnections
{
    // configure input connection as redpark cable
    RedparkSerialCable *redParkCable = [RedparkSerialCable createWithViews:mainVC];
    
    [connections addSource:redParkCable];
    
    
    // configure output connection as iGCSMavLinkInterface
    appMLI = [iGCSMavLinkInterface createWithViewController:mainVC];
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



// TODO: Make this input an enum instead of BOOL
+(void) startBluetooth:(BOOL)isPeripheral
{    
    if (isPeripheral)
    {
        bts = [BluetoothStream createForPeripheral];
    }
    else
    {
        bts = [BluetoothStream createForCentral];
    }
    
    NSLog(@"Created BluetoothStream: %@",[bts description]);
    
}



+(void) closeAllConnections
{
    if (bts)
    {
        
    }
}


@end




