//
//  TxMissionCommon.m
//  iGCS
//
//  Created by Claudio Natoli on 23/08/2014.
//
//

#import "TxMissionCommon.h"

@implementation TxMissionCommon

+ (void) handleAck:(mavlink_mission_ack_t)ack
       onInterface:(iGCSMavLinkInterface*)interface
       withHandler:(MavLinkRetryingRequestHandler*)handler
        andMission:(WaypointsHolder*)mission {
    // Vehicle responded with
    //  * out of sequence: ignore, and await the next request
    //  * mission accepted: we're done
    //  * anything else: something broke
    if (ack.type != MAV_MISSION_INVALID_SEQUENCE) {
        BOOL success = (ack.type == MAV_MISSION_ACCEPTED);
        [interface completedWriteMissionRequestSuccessfully:success withMission:mission];
        [handler completedWithSuccess:success];
    }
}

@end
