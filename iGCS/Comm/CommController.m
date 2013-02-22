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



// called at startup for app to initialize interfaces and register
// its mavlink input block
+(void)start:(MavLinkReceivedCallback)mavLinkReceivedBlock
{

    // TODO: Load settings for which interfaces to use
    
    
    
    connections = [[MavLinkConnectionPool alloc] init];
    
    
    
    // configure input connection as redpark cable
    RedparkSerialCable *redParkCable = [RedparkSerialCable createConnection];
    
    [connections addInput:redParkCable];
    
    
    // configure output connection as iGCSMavLinkInterface
    iGCSMavLinkInterface *appInput = [iGCSMavLinkInterface createWithReceiveBlock: mavLinkReceivedBlock];
    [connections addOutput:appInput];
    
    
}





@end
