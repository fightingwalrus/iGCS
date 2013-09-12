//
//  MavLinkInterface.m
//  iGCS
//
//  Created by Andrew Aarestad on 2/22/13.
//
//

#import "CommInterface.h"
#import "CommConnectionPool.h"
#import "Logger.h"

@implementation CommInterface

-(void)consumeData:(uint8_t*)bytes length:(int)length
{
    // gets called when matching source interface in a MavLinkConnection has new data
    
    // must always be overridden for destination interfaces
    [Logger error:@"Error: Tried to call consumeData that was not overridden by subclass."];
    assert(0);

}

// call this method for source interfaces when new data is available
-(void)produceData:(uint8_t*)bytes length:(int)length
{
    
    // ConnectionPool must be assigned
    if (!self.connectionPool)
    {
        [Logger error:@"Error: Tried to call produceData, but no connectionPool was set."];
    }
    assert(self.connectionPool);
    
    [self.connectionPool interface:self producedBytes:bytes length:length];
    
    
}


-(void) close
{
    // override to handle interface-specific shutdown
}


@end
