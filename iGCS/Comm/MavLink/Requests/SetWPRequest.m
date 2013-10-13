//
//  SetWPRequest.m
//  iGCS
//
//  Created by Claudio Natoli on 13/10/13.
//
//

#import "SetWPRequest.h"

@implementation SetWPRequest

- (id)initWithInterface:(iGCSMavLinkInterface*)interface andSequence:(uint16_t)sequence;
{
    if ((self = [super init])) {
        _interface = interface;
        _sequence = sequence;
        //
        _title = [NSString stringWithFormat:@"Setting Waypoint %d", sequence];
        _subtitle = @"Sending";
        _timeout = 2.0; // seconds
    }
    return self;
}

- (void) checkForACK:(mavlink_message_t)packet withHandler:(MavLinkRetryingRequestHandler*)handler {
    if (packet.msgid == MAVLINK_MSG_ID_MISSION_CURRENT) {
        mavlink_mission_current_t current;
        mavlink_msg_mission_current_decode(&packet, &current);
        if (current.seq == _sequence) {
            [handler requestCompleted:YES];
        }
    }
}

- (void) performRequest {
    [_interface issueRawSetWPCommand:_sequence];
}

@end
