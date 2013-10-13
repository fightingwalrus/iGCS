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

- (id)initWithInterface:(iGCSMavLinkInterface*)interface
{
    if ((self = [super init])) {
        _interface = interface;
        //
        _title    = @"Requesting Mission";
        _subtitle = @"Initiating Request";
        _timeout  = MAVLINK_MISSION_RXTX_RETRANSMISSION_TIMEOUT;
    }
    return self;
}

- (void) checkForACK:(mavlink_message_t)packet withHandler:(MavLinkRetryingRequestHandler*)handler {
    if (packet.msgid == MAVLINK_MSG_ID_MISSION_COUNT) {
        mavlink_mission_count_t count;
        mavlink_msg_mission_count_decode(&packet, &count);
        
        WaypointsHolder* rxMission = [[WaypointsHolder alloc] initWithExpectedCount:count.count];
        [handler continueWithRequest:[[RxMissionItems alloc] initWithInterface:_interface andMission:rxMission]];
    }
}

- (void) performRequest {
    [_interface issueRawMissionRequestList];
}

@end

