//
//  MavLinkLogger.h
//  iGCS
//
//  Created by Andrew Brown on 8/22/13.
//
//

#import <Foundation/Foundation.h>
#import "MavLinkPacketHandler.h"

@interface MavLinkLogger : NSObject <MavLinkPacketHandler> {
    NSMutableData *_writeBuffer;
    NSFileHandle *_fileHandle;
}

-(id)initWithLogName:(NSString *)logName;
-(void)handlePacket:(mavlink_message_t *)msg;

@end
