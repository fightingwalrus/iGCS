//
//  iGCSMavLinkInterface.m
//  iGCS
//
//  Created by Andrew Aarestad on 2/22/13.
//
//

#import "AppDelegate.h" // For TestFlight control


#import "MavLinkTools.h"

#import "iGCSMavLinkInterface.h"


#import "CommsViewController.h"
#import "GCSMapViewController.h"
#import "WaypointsViewController.h"

#import "mavlink_helpers.h"


#import "GaugeViewCommon.h"

#import "Logger.h"



@implementation iGCSMavLinkInterface


+(iGCSMavLinkInterface*)createWithViewController:(MainViewController*)mainVC
{
    iGCSMavLinkInterface *interface = [[iGCSMavLinkInterface alloc] init];
    
    interface.mainVC = mainVC;
    
    appMLI = interface;
    
    return interface;
}

- (void) issueGOTOCommand:(CLLocationCoordinate2D)coordinates withAltitude:(float)altitude {
    /*
     //FIXME CAUSED PILOT TO LOSE CONTROL IN STABILIZE MODE
    mavlink_msg_mission_item_send(MAVLINK_COMM_0, msg.sysid, msg.compid, 0, MAV_FRAME_GLOBAL_RELATIVE_ALT, MAV_CMD_NAV_WAYPOINT,
                                  2, // Special flag that indicates this is a GUIDED mode packet
                                  0, 0, 0, 0, 0,
                                  coordinates.latitude, coordinates.longitude, altitude);
     */
    // FIXME: should check for ACK, and retry a few times if not ACKnowledged

}


// TODO: Limit scope of these variables
mavlink_message_t msg;
mavlink_status_t status;
mavlink_heartbeat_t heartbeat;



// MavLink destination override
-(void)consumeData:(uint8_t*)bytes length:(int)length
{
    @autoreleasepool {
        
        // Notify the comms view of receipt of n bytes
        [self.mainVC.commsVC bytesReceived: length];
        
        // Pass each byte to the MAVLINK parser
        for (unsigned int byteIdx = 0; byteIdx < length; byteIdx++) {
            if (mavlink_parse_char(MAVLINK_COMM_0, bytes[byteIdx], &msg, &status)) {
                // We completed a packet, so...
                //[Logger console:@"Completed packet"];
                switch (msg.msgid) {
                    case MAVLINK_MSG_ID_HEARTBEAT:
                        [Logger console:@"MavLink Heartbeat."];
                        self.heartbeatOnlyCount = [NSNumber numberWithInt:[self.heartbeatOnlyCount intValue] + 1];
                        //If we haven't gotten anything but heartbeats in 5 seconds re-request the messages
                        if([self.heartbeatOnlyCount intValue] > 5)
                        {
                            self.mavLinkInitialized = NO;
                        }
                        if (!self.mavLinkInitialized) {
                            TESTFLIGHT_CHECKPOINT(@"FIRST HEARTBEAT");
                            
                            self.mavLinkInitialized = YES;
                            
                            // Decode the heartbeat message
                            mavlink_msg_heartbeat_decode(&msg, &heartbeat);
                            mavlink_system.sysid = msg.sysid;
                            mavlink_system.compid = msg.compid;
                            
                            [Logger console:@"Sending request for MavLink messages."];
                            
                            // Send request sto set the stream rates
                            mavlink_msg_request_data_stream_send(MAVLINK_COMM_0, msg.sysid, msg.compid,
                                                                 MAV_DATA_STREAM_ALL, 0, 0); // stop all
                            
                            mavlink_msg_request_data_stream_send(MAVLINK_COMM_0, msg.sysid, msg.compid,
                                                                 MAV_DATA_STREAM_RAW_SENSORS, RATE_RAW_SENSORS, 1);
                            mavlink_msg_request_data_stream_send(MAVLINK_COMM_0, msg.sysid, msg.compid,
                                                                 MAV_DATA_STREAM_RC_CHANNELS, RATE_RC_CHANNELS, 1);
                            mavlink_msg_request_data_stream_send(MAVLINK_COMM_0, msg.sysid, msg.compid,
                                                                 MAV_DATA_STREAM_RAW_CONTROLLER, RATE_RAW_CONTROLLER, 1);
                            mavlink_msg_request_data_stream_send(MAVLINK_COMM_0, msg.sysid, msg.compid,
                                                                 MAV_DATA_STREAM_EXTENDED_STATUS, RATE_CHAN2, 1);
                            mavlink_msg_request_data_stream_send(MAVLINK_COMM_0, msg.sysid, msg.compid,
                                                                 MAV_DATA_STREAM_POSITION, RATE_GPS_POS_INT, 1);
                            mavlink_msg_request_data_stream_send(MAVLINK_COMM_0, msg.sysid, msg.compid,
                                                                 MAV_DATA_STREAM_EXTRA1, RATE_ATTITUDE, 1);
                            mavlink_msg_request_data_stream_send(MAVLINK_COMM_0, msg.sysid, msg.compid,
                                                                 MAV_DATA_STREAM_EXTRA2, RATE_VFR_HUD, 1);
                            mavlink_msg_request_data_stream_send(MAVLINK_COMM_0, msg.sysid, msg.compid,
                                                                 MAV_DATA_STREAM_EXTRA3, RATE_EXTRA3, 1);
                            
                            [self issueReadWaypointsRequest];
                        }
                        
                        /* // Cheat to turn heartbeats into waypoints for iterative display on CommsView
                         static int z = 0;
                         if ([waypoints allWaypointsReceivedP]) {
                         mavlink_waypoint_t waypoint = [waypoints getWaypoint:(z % [waypoints numWaypoints])];
                         mavlink_msg_waypoint_encode(msg.sysid, msg.compid, &msg, &waypoint);
                         }
                         z++;
                         //*/
                        
                        /* // Check to turn heartbeats into next waypoint updates
                         static int z = 0;
                         if (z++ % 10 == 0) {
                         mavlink_waypoint_current_t currentWaypoint;
                         currentWaypoint.seq = z/50;
                         mavlink_msg_waypoint_current_encode(msg.sysid, msg.compid, &msg, &currentWaypoint);
                         
                         }
                         //*/
                        break;
                        
                    case MAVLINK_MSG_ID_MISSION_COUNT:
                    {
                        [Logger console:@"MavLink MissionCount."];
                        
                        mavlink_mission_count_t count;
                        mavlink_msg_mission_count_decode(&msg, &count);
                        
                        self.waypoints = [[WaypointsHolder alloc] initWithExpectedCount:count.count];
                        [self requestNextWaypointOrACK:self.waypoints];
                    }
                        break;
                        
                    case MAVLINK_MSG_ID_MISSION_ITEM:
                    {
                        [Logger console:@"MavLink MissionItem."];
                        
                        mavlink_mission_item_t waypoint;
                        mavlink_msg_mission_item_decode(&msg, &waypoint);
                        
                        [self.waypoints addWaypoint:waypoint];
                        [self requestNextWaypointOrACK:self.waypoints];
                    }
                        break;
                        
                    case MAVLINK_MSG_ID_GLOBAL_POSITION_INT:
                    case MAVLINK_MSG_ID_ATTITUDE:
                    case MAVLINK_MSG_ID_VFR_HUD:
                        break;
                        
                    default:
                    {
                        //If we get any other message than heartbeat, we are getting the messages we requested
                        self.heartbeatOnlyCount = [NSNumber numberWithInt:0];
                    }
                        //NSLog(@"UNHANDLED message with ID %d", msg.msgid);
                        break;
                }
                // Then send the packet on to the child views
#if 0
                for (id view in [self viewControllers]) {
                    [view handlePacket:&msg];
                }
#else
                [self.mainVC.gcsMapVC handlePacket:&msg];
                [self.mainVC.commsVC  handlePacket:&msg];
                [self.mainVC.waypointVC handlePacket:&msg];
#endif
            }
        }
    }
    

}



// TODO: Move me into requests class
- (void) issueReadWaypointsRequest {
    
#if 0
    // Debug - add a couple fake waypoints when requested
    mavlink_mission_item_t waypoint;
    WaypointsHolder *zz = [[WaypointsHolder alloc] initWithExpectedCount:2];
    waypoint.seq = 0; waypoint.command =  0; waypoint.x = 47.258842; waypoint.y = 11.331070; waypoint.z = 584; [zz addWaypoint:waypoint];
    waypoint.seq = 1; waypoint.command = 16; waypoint.x = 47.260709; waypoint.y = 11.348920; waypoint.z = 100; [zz addWaypoint:waypoint];
    waypoint.seq = 2; waypoint.command = 16; waypoint.x = 47.264815; waypoint.y = 11.347847; waypoint.z = 100; [zz addWaypoint:waypoint];
    
    // MAV_CMD_CONDITION_CHANGE_ALT
    waypoint.seq = 3; waypoint.command = 113; waypoint.x = 0; waypoint.y = 0; waypoint.z = 0; waypoint.param1 = 100; waypoint.param2 = 2000; [zz addWaypoint:waypoint];

    waypoint.seq = 4; waypoint.command = 16; waypoint.x = 47.262573; waypoint.y = 11.324630; waypoint.z = 100; [zz addWaypoint:waypoint];
    waypoint.seq = 5; waypoint.command = 16; waypoint.x = 47.258262; waypoint.y = 11.325445; waypoint.z = 100; [zz addWaypoint:waypoint];
    // MAV_CMD_DO_JUMP
    waypoint.seq = 6; waypoint.command = 177; waypoint.x = 0; waypoint.y = 0; waypoint.z = 0; waypoint.param1 = 1; waypoint.param3 = 5; [zz addWaypoint:waypoint];

    
    waypoint.seq = 7; waypoint.command = 16; waypoint.x = 47.258757; waypoint.y = 11.330380; waypoint.z =  50; [zz addWaypoint:waypoint];
    waypoint.seq = 8; waypoint.command = 16; waypoint.x = 47.259427; waypoint.y = 11.336904; waypoint.z =  20; [zz addWaypoint:waypoint];
    waypoint.seq = 9; waypoint.command = 21; waypoint.x = 47.259864; waypoint.y = 11.340809; waypoint.z = 100; [zz addWaypoint:waypoint];
    
    [self.mainVC.gcsMapVC resetWaypoints: zz];
    [self.mainVC.waypointVC resetWaypoints: zz];
#endif
    mavlink_msg_mission_ack_send(MAVLINK_COMM_0, msg.sysid, msg.compid, 0); // send ACK just in case...
    
    // Start Read MAV waypoint protocol transaction
    mavlink_msg_mission_request_list_send(MAVLINK_COMM_0, msg.sysid, msg.compid);
}


- (void) issueSetAUTOModeCommand {
    for (unsigned int i = 0; i < 2; i++) {
        mavlink_msg_set_mode_send(MAVLINK_COMM_0, msg.sysid, MAV_MODE_FLAG_CUSTOM_MODE_ENABLED, AUTO);
        [NSThread sleepForTimeInterval:0.01];
    }
}

- (void) requestNextWaypointOrACK:(WaypointsHolder*)waypoints {
    if ([waypoints allWaypointsReceivedP]) {
        // Finish Read MAV waypoint protocol transaction
        mavlink_msg_mission_ack_send(MAVLINK_COMM_0, msg.sysid, msg.compid, 0);
        
        // Let the GCSMapView and WaypointsView know we've got new waypoints
        [self.mainVC.gcsMapVC   resetWaypoints: self.waypoints];
        [self.mainVC.waypointVC resetWaypoints: self.waypoints];
    } else {
        mavlink_msg_mission_request_send(MAVLINK_COMM_0, msg.sysid, msg.compid, [waypoints numWaypoints]);
    }
}


iGCSMavLinkInterface *appMLI;

static void send_uart_bytes(mavlink_channel_t chan, uint8_t *buffer, uint16_t len)
{
    
    NSLog(@"iGCSMavLinkInterface:send_uart_bytes: sending %hu chars to connection pool", len);
    
    [appMLI produceData:buffer length:len];
    


}



@end
