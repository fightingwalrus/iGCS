//
//  TxMissionCommon.h
//  iGCS
//
//  Created by Claudio Natoli on 23/08/2014.
//
//

#import <Foundation/Foundation.h>
#import "MavLinkRetryingRequestHandler.h"
#import "iGCSMavLinkInterface.h"

@interface TxMissionCommon : NSObject

+ (void) handleAck:(mavlink_mission_ack_t)ack onInterface:(iGCSMavLinkInterface*)interface withHandler:(MavLinkRetryingRequestHandler*)handler andMission:(WaypointsHolder*)mission;

@end
