//
//  MavLinkConnectionPool.m
//  iGCS
//
//  Created by Andrew Aarestad on 2/22/13.
//
//

#import "MavLinkConnectionPool.h"

#import "Logger.h"

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
    interface.connectionPool = self;
    [self.sourceInterfaces addObject:interface];
}
-(void)addDestination:(MavLinkInterface*)interface
{
    interface.connectionPool = self;
    [self.destinationInterfaces addObject:interface];
}

-(void)removeSource:(MavLinkInterface*)interface
{
    [self.sourceInterfaces removeObject:interface];
    [interface close];
}
-(void)removeDestination:(MavLinkInterface*)interface
{
    [self.destinationInterfaces removeObject:interface];
    [interface close];
}


-(void)removeAllConnections
{
    [self.connections removeAllObjects];
}

-(void)closeAllInterfaces
{
    for (MavLinkInterface *interface in self.sourceInterfaces)
    {
        [interface close];
    }
    for (MavLinkInterface *interface in self.destinationInterfaces)
    {
        [interface close];
    }
    
    [self removeAllConnections];
}


-(void)createConnection:(MavLinkInterface*)source destination:(MavLinkInterface*)destination
{
    // TODO: Check to see if source and destination are already in source/destination lists,
    // if not, add them
    
    // TODO: Make sure a connection with these interfaces doesn't already exist
    
    @try {
        MavLinkConnection *conn = [MavLinkConnection createForSource:source destination:destination];
    
        [self.connections addObject:conn];
        
    }
    @catch (NSException *e)
    {
        [Logger dumpException:e];
    }

}



-(void)interface:(MavLinkInterface*)interface producedBytes:(uint8_t*)bytes length:(int)length
{
    @try {
        for (MavLinkConnection *connection in self.connections)
        {
            if ([connection.source isEqual:interface])
            {
                // Send the bytes to the destination for each matched connection
                [connection.destination consumeData:bytes length:length];
            }
        }
    }
    @catch (NSException *e)
    {
        NSLog(@"Exception in forwarding data: %@",[e description]);
    }
    
}

@end
