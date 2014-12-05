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

@interface MavLinkLogger : NSObject <MavLinkPacketHandler>

-(instancetype)initWithLogName:(NSString *)logName NS_DESIGNATED_INITIALIZER;
-(void)handlePacket:(mavlink_message_t *)msg;

@end
