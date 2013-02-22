//
//  CommController.h
//  iGCS
//
//  Created by Andrew Aarestad on 2/22/13.
//
//

#import <Foundation/Foundation.h>

#import "MavLinkConnection.h"
#import "MavLinkConnectionPool.h"

#import "RedparkSerialCable.h"
#import "FightingWalrusRadio.h"
#import "SocketStream.h"
#import "BluetoothStream.h"

#import "iGCSMavLinkInterface.h"


#import "MavLinkInterface.h"


typedef void (^ MavLinkReceivedCallback)(NSDictionary*);



@interface CommController : NSObject

+(void)start:(MavLinkReceivedCallback)mavLinkReceivedBlock;

@end
