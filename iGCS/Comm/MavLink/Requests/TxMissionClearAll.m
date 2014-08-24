//
//  TxMissionClearAll.m
//  iGCS
//
//  Created by Claudio Natoli on 23/08/2014.
//
//

#import "TxMissionClearAll.h"

@implementation TxMissionClearAll

- (id)initWithInterface:(iGCSMavLinkInterface*)interface
{
    if ((self = [super init])) {
        _interface    = interface;
        
        _title    = @"Transmitting Mission";
        _subtitle = [NSString stringWithFormat:@"Clearing Mission"];
        _timeout  = MAVLINK_TX_MISSION_ITEM_COUNT_RETRANSMISSION_TIMEOUT;
    }
    return self;
}

- (void) checkForACK:(mavlink_message_t)packet withHandler:(MavLinkRetryingRequestHandler*)handler {
    mavlink_mission_ack_t ack;
    
    switch (packet.msgid) {
        case MAVLINK_MSG_ID_MISSION_ACK:
            mavlink_msg_mission_ack_decode(&packet, &ack);
            if (ack.type != MAV_MISSION_INVALID_SEQUENCE) {
                bool success = (ack.type == MAV_MISSION_ACCEPTED);
                if (success) {
                    [_interface loadNewMission:[[WaypointsHolder alloc] initWithExpectedCount:0]];
                }
                [handler completedWithSuccess:success];
            }
            break;
    }
}

- (void) performRequest {
    [_interface issueRawMissionClearAll];
}

@end
