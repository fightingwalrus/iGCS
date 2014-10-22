//
//  TxMissionClearAll.m
//  iGCS
//
//  Created by Claudio Natoli on 23/08/2014.
//
//

#import "TxMissionClearAll.h"

@implementation TxMissionClearAll

- (id)initWithInterface:(iGCSMavLinkInterface*)interface {
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
            [TxMissionCommon handleAck:ack
                           onInterface:_interface
                           withHandler:handler
                            andMission:[[WaypointsHolder alloc] initWithExpectedCount:0]];
            break;
    }
}

- (void) performRequest {
    [_interface issueRawMissionClearAll];
}

@end
