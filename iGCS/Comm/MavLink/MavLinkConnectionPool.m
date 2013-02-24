//
//  MavLinkConnectionPool.m
//  iGCS
//
//  Created by Andrew Aarestad on 2/22/13.
//
//

#import "MavLinkConnectionPool.h"

@implementation MavLinkConnectionPool


-(id)init
{
    self = [super init];
    if (self)
    {
        self.sourceInterfaces = [NSMutableArray array];
        self.destinationInterfaces = [NSMutableArray array];
        self.connections = [NSMutableArray array];
    }
    
    return self;
}


-(void)addSource:(MavLinkInterface*)interface
{
    [self.sourceInterfaces addObject:interface];
}
-(void)addDestination:(MavLinkInterface*)interface
{
    [self.destinationInterfaces addObject:interface];
}

-(void)createConnection:(MavLinkInterface*)source destination:(MavLinkInterface*)destination
{
    // TODO: Check to see if source and destination are already in source/destination lists,
    // if not, add them
    
    // TODO: Make sure a connection with these interfaces doesn't already exist
    
    MavLinkConnection *conn = [MavLinkConnection createForSource:source destination:destination];
    
    [self.connections addObject:conn];
    
}



-(void)interface:(MavLinkInterface*)interface producedBytes:(uint8_t*)bytes length:(int)length
{
    
    for (MavLinkConnection *connection in self.connections)
    {
        if ([connection.source isEqual:interface])
        {
            // Send the bytes to the destination for each matched connection
            [connection.destination consumeData:bytes length:length];
        }
    }
}

@end
