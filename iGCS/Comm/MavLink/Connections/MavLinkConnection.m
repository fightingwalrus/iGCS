//
//  MavLinkConnection.m
//  iGCS
//
//  Created by Andrew Aarestad on 2/22/13.
//
//

#import "MavLinkConnection.h"

@implementation MavLinkConnection


+(MavLinkConnection*)createForSource:(MavLinkInterface*)source destination:(MavLinkInterface*)destination
{
    
    MavLinkConnection *conn = [[MavLinkConnection alloc] init];
    
    conn.source = source;
    conn.destination = destination;
    
    return conn;
    
}

@end
