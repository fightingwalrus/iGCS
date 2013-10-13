//
//  TxMissionItemCount.m
//  iGCS
//
//  Created by Claudio Natoli on 13/10/13.
//
//

#import "TxMissionItemCount.h"
#import "TxMissionItem.h"

@implementation TxMissionItemCount

- (id)initWithInterface:(iGCSMavLinkInterface*)interface andMission:(WaypointsHolder*)mission;
{
    if ((self = [super init])) {
        _interface = interface;
        _mission   = mission;
        //
        _title    = @"Transmitting Mission";
        _subtitle = @"Sending Waypoint count";
        _timeout  = MAVLINK_MISSION_RXTX_RETRANSMISSION_TIMEOUT;
    }
    return self;
}

- (void) checkForACK:(mavlink_message_t)packet withHandler:(MavLinkRetryingRequestHandler*)handler {
    if (packet.msgid == MAVLINK_MSG_ID_MISSION_REQUEST) {
        mavlink_mission_request_t request;
        mavlink_msg_mission_request_decode(&packet, &request);
        if (request.seq == 0) {
            // Now start sending waypoints...
            [handler continueWithRequest:[[TxMissionItem alloc] initWithInterface:_interface withMission:_mission andCurrentIndex:0]];
        }
    }
}

- (void) performRequest {
    [_interface issueRawMissionCount:[_mission numWaypoints]];
}

@end
