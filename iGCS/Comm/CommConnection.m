//
//  MavLinkConnection.m
//  iGCS
//
//  Created by Andrew Aarestad on 2/22/13.
//
//

#import "CommConnection.h"

@implementation CommConnection


+(CommConnection*)createForSource:(CommInterface*)source destination:(CommInterface*)destination
{
    
    CommConnection *conn = [[CommConnection alloc] init];
    
    conn.source = source;
    conn.destination = destination;
    
    return conn;
    
}

@end
