//
//  RxMissionRequestList.m
//  iGCS
//
//  Created by Claudio Natoli on 13/10/13.
//
//

#import "RxMissionRequestList.h"
#import "RxMissionItems.h"

@implementation RxMissionRequestList

- (instancetype)initWithInterface:(iGCSMavLinkInterface*)interface {
    if ((self = [super init])) {
        _interface = interface;

        _title    = @"Requesting Mission";
        _subtitle = @"Initiating Request";
        _timeout  = MAVLINK_RX_MISSION_RETRANSMISSION_TIMEOUT;
    }
    return self;
}

- (void) checkForACK:(mavlink_message_t)packet withHandler:(MavLinkRetryingRequestHandler*)handler {
    if (packet.msgid == MAVLINK_MSG_ID_MISSION_COUNT) {
        mavlink_mission_count_t count;
        mavlink_msg_mission_count_decode(&packet, &count);
        
        WaypointsHolder* rxMission = [[WaypointsHolder alloc] initWithExpectedCount:count.count];

        if (count.count == 0) {
            // No items to request, so...
            [_interface completedReadMissionRequest:rxMission];
            [handler completedWithSuccess:YES];
        } else {
            // Start requesting mission items
            [handler continueWithRequest:[[RxMissionItems alloc] initWithInterface:_interface andMission:rxMission]];
        }
    }
}

- (void) performRequest {
    [_interface issueRawMissionRequestList];
}

@end

