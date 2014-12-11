//
//  TxMissionItem.m
//  iGCS
//
//  Created by Claudio Natoli on 13/10/13.
//
//

#import "TxMissionItem.h"

@implementation TxMissionItem

- (instancetype)initWithInterface:(iGCSMavLinkInterface*)interface withMission:(WaypointsHolder*)mission andCurrentIndex:(uint16_t)currentIndex {
    if ((self = [super init])) {
        _interface    = interface;
        _mission      = mission;
        _currentIndex = currentIndex;

        _title    = @"Transmitting Mission";
        _subtitle = [NSString stringWithFormat:@"Sending Waypoint #%d", currentIndex];
        _timeout  = MAVLINK_TX_MISSION_ITEM_RETRANSMISSION_TIMEOUT;
    }
    return self;
}

- (void) checkForACK:(mavlink_message_t)packet withHandler:(MavLinkRetryingRequestHandler*)handler {
    mavlink_mission_request_t request;
    mavlink_mission_ack_t ack;
    
    switch (packet.msgid) {
        case MAVLINK_MSG_ID_MISSION_REQUEST:
            // Send requested waypoint
            mavlink_msg_mission_request_decode(&packet, &request);
            [handler continueWithRequest:[[TxMissionItem alloc] initWithInterface:_interface withMission:_mission andCurrentIndex:request.seq]];
            break;

        case MAVLINK_MSG_ID_MISSION_ACK:
            mavlink_msg_mission_ack_decode(&packet, &ack);
            [TxMissionCommon handleAck:ack onInterface:_interface withHandler:handler andMission:_mission];
            break;
    }
}

- (void) performRequest {
    // Send the requested mission item
    //   - for now, we assume that all coords are in the MAV_FRAME_GLOBAL_RELATIVE_ALT frame; see also issueGOTOCommand
    NSAssert(_currentIndex < [_mission numWaypoints], @"Requested waypoint %d of %lu", _currentIndex, (unsigned long)[_mission numWaypoints]);
    mavlink_mission_item_t item = [_mission getWaypoint:_currentIndex];
    item.seq = _currentIndex;
    item.frame = MAV_FRAME_GLOBAL_RELATIVE_ALT;
    item.current = 0;
    [_interface issueRawMissionItem:item];
}

@end
