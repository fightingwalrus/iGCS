//
//  CommInterface.m
//  iGCS
//
//  Created by Andrew Aarestad on 2/22/13.
//
//

#import "CommInterface.h"
#import "CommConnectionPool.h"

@implementation CommInterface

-(void)consumeData:(const uint8_t*)bytes length:(NSUInteger)length {
    // gets called when matching source interface in a MavLinkConnection has new data

    // must always be overridden for destination interfaces
    NSAssert(false, @"Tried to call consumeData that was not overridden by subclass.");
}

// call this method for source interfaces when new data is available
-(void)produceData:(const uint8_t*)bytes length:(NSUInteger)length {

    // ConnectionPool must be assigned
    NSAssert(self.connectionPool, @"connectionPool can not be nil.");
    if (!self.connectionPool) {
        DDLogError(@"Tried to call produceData, but no connectionPool was set.");
        return;
    }

    [self.connectionPool interface:self producedBytes:bytes length:length];
}

-(void) close {
    // override to handle interface-specific shutdown
    NSAssert(false, @"Tried to call close that was not overridden by subclass.");
}

@end
