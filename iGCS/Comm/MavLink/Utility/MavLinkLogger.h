//
//  MavLinkLogger.h
//  iGCS
//
//  Created by Andrew Brown on 8/22/13.
//
//

#import <Foundation/Foundation.h>
#import "MavLinkPacketHandler.h"
#import "DateTimeUtils.h"

@interface MavLinkLogger : NSObject <MavLinkPacketHandler> {
    NSFileHandle *_fileHandle;
    DateTimeUtils *_dateTimeUtils;
    dispatch_queue_t serialQueue;
}

-(instancetype)initWithLogName:(NSString *)logName NS_DESIGNATED_INITIALIZER;
-(void)handlePacket:(mavlink_message_t *)msg;

@end
