//
//  MavLinkConnectionPool.h
//  iGCS
//
//  Created by Andrew Aarestad on 2/22/13.
//
//

#import <Foundation/Foundation.h>
#import "MavLinkInterface.h"
#import "MavLinkConnection.h"

@interface MavLinkConnectionPool : NSObject





@property (strong) NSMutableArray *sourceInterfaces;
@property (strong) NSMutableArray *destinationInterfaces;

@property (strong) NSMutableArray *connections;

-(void)addDestination:(MavLinkInterface*)interface;
-(void)addSource:(MavLinkInterface*)interface;


-(void)interface:(MavLinkInterface*)interface producedBytes:(uint8_t*)bytes length:(int)length;


-(void)createConnection:(MavLinkInterface*)source destination:(MavLinkInterface*)destination;

@end
