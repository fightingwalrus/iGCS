//
//  MavLinkConnectionPool.h
//  iGCS
//
//  Created by Andrew Aarestad on 2/22/13.
//
//

#import <Foundation/Foundation.h>
#import "CommInterface.h"
#import "CommConnection.h"

@interface CommConnectionPool : NSObject

@property (strong) NSMutableArray *sourceInterfaces;
@property (strong) NSMutableArray *destinationInterfaces;
@property (strong) NSMutableArray *connections;

-(void)addDestination:(CommInterface*)interface;
-(void)addSource:(CommInterface*)interface;
-(void)interface:(CommInterface*)interface producedBytes:(uint8_t*)bytes length:(int)length;

-(void)createConnection:(CommInterface*)source destination:(CommInterface*)destination;
-(void)closeAllInterfaces;

@end
