//
//  iGCSMavLinkInterface.m
//  iGCS
//
//  Created by Andrew Aarestad on 2/22/13.
//
//

#import "AppDelegate.h" // For TestFlight control

#import "MavLinkTools.h"
#import "DateTimeUtils.h"
#import "iGCSMavLinkInterface.h"

#import "GCSMapViewController.h"
#import "GCSSidebarController.h"
#import "CommsViewController.h"
#import "WaypointsViewController.h"

#import "DataRateRecorder.h"

#import "mavlink_helpers.h"

#import "GaugeViewCommon.h"

#import "Logger.h"

#import "MavLinkRetryingRequestHandler.h"
#import "SetWPRequest.h"
#import "RxMissionRequestList.h"
#import "TxMissionItemCount.h"

@implementation iGCSMavLinkInterface


// TODO: Limit scope of these variables
iGCSMavLinkInterface *appMLI;
mavlink_message_t msg;
mavlink_status_t status;
mavlink_heartbeat_t heartbeat;
MavLinkRetryingRequestHandler* retryRequestHandler;

+(iGCSMavLinkInterface*)createWithViewController:(MainViewController*)mainVC
{
    iGCSMavLinkInterface *interface = [[iGCSMavLinkInterface alloc] init];
    interface.mainVC = mainVC;
    appMLI = interface;
    retryRequestHandler = [[MavLinkRetryingRequestHandler alloc] init];
    
    return interface;
}

-(void)close {
    NSLog(@"iGCSMavLinkInterface: close is a noop");
}

-(void)setupLogger{
    DateTimeUtils *dtUtils = [[DateTimeUtils alloc] init];
    NSString *logName = [dtUtils dateStringInUTCWithExtension:@"log"];
    _mavlinkLogger = [[MavLinkLogger alloc] initWithLogName:logName];
}

static void send_uart_bytes(mavlink_channel_t chan, uint8_t *buffer, uint16_t len)
{
    NSLog(@"iGCSMavLinkInterface:send_uart_bytes: sending %hu chars to connection pool", len);
    [appMLI produceData:buffer length:len];
}

// MavLink destination override
-(void)consumeData:(uint8_t*)bytes length:(int)length
{
    @autoreleasepool {
        // Notify receipt of length bytes
        [self.mainVC.dataRateRecorder bytesReceived:length];
        
        // set up log file the first time we get any data
        if (!_mavlinkLogger) {
            [self setupLogger];
        }

//        if (length > 0) {
//            NSMutableData *someData = [[NSMutableData alloc] init];
//            [someData appendBytes:bytes length:length];
//            NSString *string = [[NSString alloc] initWithData:someData encoding:NSASCIIStringEncoding];
//            NSLog(@"consumeData: %@", string);
//        }

        // Pass each byte to the MAVLINK parser
        for (unsigned int byteIdx = 0; byteIdx < length; byteIdx++) {
            if (mavlink_parse_char(MAVLINK_COMM_0, bytes[byteIdx], &msg, &status)) {
                // We completed a packet, so...
                if (msg.msgid == MAVLINK_MSG_ID_HEARTBEAT) {
                    [Logger console:@"MavLink Heartbeat."];
                    
                    // If we haven't gotten anything but heartbeats in 5 seconds re-request the messages
                    if (++self.heartbeatOnlyCount >= 5) {
                        self.mavLinkInitialized = NO;
                    }

                    if (!self.mavLinkInitialized) {
                        
                        self.mavLinkInitialized = YES;
                        
                        // Decode the heartbeat message
                        mavlink_msg_heartbeat_decode(&msg, &heartbeat);
                        mavlink_system.sysid  = msg.sysid;
                        mavlink_system.compid = (msg.compid+1) % 255; // Use a compid that is distinct from the vehicle's
                        
                        [Logger console:@"Sending request for MavLink messages."];
                        
                        // Send requests to set the stream rates
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
                        
                        
                        
                        [self startReadMissionRequest];

                        if (!self.heartbeatTimer) {
                            self.heartbeatTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                                                    target:self
                                                                                  selector:@selector(sendHeatbeatToAutopilot)
                                                                                 userInfo:nil repeats:YES];
                        }

                    }
                } else {
                    // If we get any other message than heartbeat, we are getting the messages we requested
                    self.heartbeatOnlyCount = 0;
                }
                
                // Pass to the retrying request handler in case we need to process an ACK
                [retryRequestHandler checkForAckOnCurrentRequest:msg];
                
                // Then send the packet on to the child views
                [self.mainVC.gcsMapVC handlePacket:&msg];
                [self.mainVC.gcsSidebarVC handlePacket:&msg];
                [self.mainVC.waypointVC handlePacket:&msg];
                [self.mainVC.commsVC  handlePacket:&msg];
                [self.mavlinkLogger handlePacket:&msg];
            }
        }
    }
}


#pragma mark - Mission Transactions: receiving

- (void) startReadMissionRequest {
    [retryRequestHandler startRetryingRequest:[[RxMissionRequestList alloc] initWithInterface:self]];
}

- (void) issueRawMissionRequestList {
    // Start Read MAV waypoint protocol transaction
    mavlink_msg_mission_request_list_send(MAVLINK_COMM_0, msg.sysid, msg.compid);
}

- (void) issueRawMissionRequest:(uint16_t)sequence {
    // Request the waypoint with sequence
    mavlink_msg_mission_request_send(MAVLINK_COMM_0, msg.sysid, msg.compid, sequence);
}

- (void) issueRawMissionAck {
    // Finish Read MAV waypoint protocol transaction
    mavlink_msg_mission_ack_send(MAVLINK_COMM_0, msg.sysid, msg.compid, MAV_MISSION_ACCEPTED);
}

- (void) loadNewMission:(WaypointsHolder*)mission {
    // Let the GCSMapView and WaypointsView know we've got new waypoints
    //NSLog(@"Loading mission:\n%@", [waypoints toOutputFormat]);
    [self.mainVC.gcsMapVC   resetWaypoints:mission];
    [self.mainVC.waypointVC resetWaypoints:mission];
}


#pragma mark - Mission Transactions: sending

- (void) startWriteMissionRequest:(WaypointsHolder*)waypoints {
    [retryRequestHandler startRetryingRequest:[[TxMissionItemCount alloc] initWithInterface:self andMission:waypoints]];
}

- (void) issueRawMissionCount:(uint16_t)numItems {
    mavlink_msg_mission_count_send(MAVLINK_COMM_0, msg.sysid, msg.compid, numItems);
}

- (void) issueRawMissionItem:(mavlink_mission_item_t)item {
    mavlink_msg_mission_item_send(MAVLINK_COMM_0, msg.sysid, msg.compid,
                                  item.seq, item.frame, item.command, item.current, item.autocontinue,
                                  item.param1, item.param2, item.param3, item.param4,
                                  item.x, item.y, item.z);
}


#pragma mark - Set current waypoint

- (void) startSetWaypointRequest:(uint16_t)sequence {
    [retryRequestHandler startRetryingRequest:[[SetWPRequest alloc] initWithInterface:self andSequence:sequence]];
}

- (void) issueRawSetWaypointCommand:(uint16_t)sequence {
    mavlink_msg_mission_set_current_send(MAVLINK_COMM_0, msg.sysid, msg.compid, sequence);
}


#pragma mark - Miscellaneous requests

- (void) issueGOTOCommand:(CLLocationCoordinate2D)coordinates withAltitude:(float)altitude {
     mavlink_msg_mission_item_send(MAVLINK_COMM_0, msg.sysid, msg.compid, 0, MAV_FRAME_GLOBAL_RELATIVE_ALT, MAV_CMD_NAV_WAYPOINT,
                                   2, // Special flag that indicates this is a GUIDED mode packet
                                   0, 0, 0, 0, 0,
                                   coordinates.latitude, coordinates.longitude, altitude);
    // FIXME: should check for ACK, and retry a few times if not ACKnowledged
}

- (void) issueSetAUTOModeCommand {
    for (unsigned int i = 0; i < 2; i++) {
        mavlink_msg_set_mode_send(MAVLINK_COMM_0, msg.sysid, MAV_MODE_FLAG_CUSTOM_MODE_ENABLED, AUTO);
        [NSThread sleepForTimeInterval:0.01];
    }
}


- (void) loadDemoMission {
    WaypointsHolder* demo = [WaypointsHolder createDemoMission];
    //NSLog(@"Loading mission:\n%@", [[WaypointsHolder createFromQGCString:[demo toOutputFormat]] toOutputFormat]);
    
    [self.mainVC.gcsMapVC resetWaypoints: demo];
    [self.mainVC.waypointVC resetWaypoints: demo];
}

-(void) sendHeatbeatToAutopilot {
    mavlink_msg_heartbeat_send(MAVLINK_COMM_0, MAV_TYPE_GCS, MAV_AUTOPILOT_INVALID, 0, 0, 0);
}

@end
