//
//  MavLinkLogger.h
//  iGCS
//
//  Created by Andrew Zheng on 8/22/13.
//
//

#import <Foundation/Foundation.h>
#import "MavLinkPacketHandler.h"

@interface MavLinkLogger : NSObject <MavLinkPacketHandler, NSStreamDelegate> {
    
}

-(void)handlePacket:(mavlink_message_t *)msg;

@end
