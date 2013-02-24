//
//  MavLinkInterface.m
//  iGCS
//
//  Created by Andrew Aarestad on 2/22/13.
//
//

#import "MavLinkInterface.h"

#import "MavLinkConnectionPool.h"

@implementation MavLinkInterface



-(void)consumeData:(uint8_t*)bytes length:(int)length
{
    // gets called when matching source interface in a MavLinkConnection has new data
    
    // must always be overridden for destination interfaces
    assert(0);

}



// call this method for source interfaces when new data is available
-(void)produceData:(uint8_t*)bytes length:(int)length
{
    
    // ConnectionPool must be assigned
    assert(self.connectionPool);
    
    [self.connectionPool interface:self producedBytes:bytes length:length];
    
    
}



@end
