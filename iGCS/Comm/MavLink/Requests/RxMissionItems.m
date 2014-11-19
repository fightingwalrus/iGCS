//
//  RxMissionItems.m
//  iGCS
//
//  Created by Claudio Natoli on 13/10/13.
//
//

#import "RxMissionItems.h"

@implementation RxMissionItems

- (instancetype)initWithInterface:(iGCSMavLinkInterface*)interface andMission:(WaypointsHolder*)mission {
    if ((self = [super init])) {
        _interface = interface;
        _mission   = mission;

        _title    = @"Requesting Mission";
        _subtitle = [NSString stringWithFormat:@"Getting Waypoint #%lu", (unsigned long)[_mission numWaypoints]];
        _timeout  = MAVLINK_RX_MISSION_RETRANSMISSION_TIMEOUT;
    }
    return self;
}

- (void) checkForACK:(mavlink_message_t)packet withHandler:(MavLinkRetryingRequestHandler*)handler {
    if (packet.msgid == MAVLINK_MSG_ID_MISSION_ITEM) {
        mavlink_mission_item_t waypoint;
        mavlink_msg_mission_item_decode(&packet, &waypoint);
        
        // Is this the item we were expecting?
        if ([_mission numWaypoints] == waypoint.seq) {
            [_mission addWaypoint:waypoint];

            // Are we done?
            if ([_mission hasReceivedAllWaypoints]) {
                [_interface completedReadMissionRequest:_mission];
                [handler completedWithSuccess:YES];   // FIXME: was originally the first line of this branch but caused crashes; investigate why.
            } else {
                // Let's get the next waypoint
                [handler continueWithRequest:[[RxMissionItems alloc] initWithInterface:_interface andMission:_mission]];
            }
        }
    }
}

- (void) performRequest {
    [_interface issueRawMissionRequest:[_mission numWaypoints]];
}

@end

