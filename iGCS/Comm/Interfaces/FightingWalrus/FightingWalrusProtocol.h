//
//  FightingWalrusProtocol.h
//  iGCS
//
//  Created by Andrew Aarestad on 2/23/13.
//
//

#import <Foundation/Foundation.h>
#import "FightingWalrusMFI.h"

@interface FightingWalrusProtocol : FightingWalrusMFI {
    uint8_t AccStatus;
    uint8_t AccMajor;
    uint8_t AccMinor;
    uint8_t AccRev;
    uint8_t BoardID;
	
	//NSAutoreleasePool *thePool;
	NSThread *updateThread;
	
    float temperature;
    int pot;
    uint8_t switches;
	uint8_t counter;
}

@property (readonly) uint8_t AccStatus;
@property (readonly) uint8_t AccMajor;
@property (readonly) uint8_t AccMinor;
@property (readonly) uint8_t AccRev;
@property (readonly) uint8_t BoardID;

- (void) updateData;
@end
