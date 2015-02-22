//
//  iGCSMavLinkInterface.m
//  iGCS
//
//  Created by Andrew Aarestad on 2/22/13.
//
//

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

#import "MavLinkRetryingRequestHandler.h"
#import "SetWPRequest.h"
#import "RxMissionRequestList.h"
#import "TxMissionItemCount.h"
#import "TxMissionClearAll.h"
#import "RadioConfig.h"

#import "ArDroneUtils.h"
#import "mavlink_msg_manual_control.h"

#import "GCSCraftModes.h"
#import "GCSDataManager.h"
#import "TelemetryManagers.h"

@interface iGCSMavLinkInterface ()
@property (nonatomic, strong) GCSHeartbeatManager *heartbeatManager;
@end

@implementation iGCSMavLinkInterface

// TODO: Limit scope of these variables
iGCSMavLinkInterface *appMLI;
mavlink_message_t msg;
mavlink_status_t status;
mavlink_heartbeat_t heartbeat;
MavLinkRetryingRequestHandler* retryRequestHandler;

+(iGCSMavLinkInterface*)createWithViewController:(MainViewController*)mainVC {
    iGCSMavLinkInterface *interface = [[iGCSMavLinkInterface alloc] init];
    interface.mainVC = mainVC;
    appMLI = interface;
    retryRequestHandler = [[MavLinkRetryingRequestHandler alloc] init];

    return interface;
}

-(instancetype)init {
    self = [super init];
    if (self) {
        // radio has entered config mode
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRadioEnteredConfigMode)
                                                     name:GCSRadioConfigEnteredConfigMode object:nil];
        _heartbeatOnlyCount = 0;
        _heartbeatManager = [[GCSHeartbeatManager alloc] init];
    }
    return self;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)close {
    DDLogDebug(@"iGCSMavLinkInterface: close is a noop");
}

-(void)setupLogger{
    DateTimeUtils *dtUtils = [[DateTimeUtils alloc] init];
    NSString *logName = [dtUtils dateStringInUTCWithExtension:@"log"];
    _mavlinkLogger = [[MavLinkLogger alloc] initWithLogName:logName];
}

static void send_uart_bytes(mavlink_channel_t chan, const uint8_t *buffer, uint16_t len) {
    DDLogCVerbose(@"iGCSMavLinkInterface:send_uart_bytes: sending %hu chars to connection pool", len);
    [appMLI produceData:buffer length:len];
}

// MavLink destination override
-(void)consumeData:(const uint8_t*)bytes length:(NSUInteger)length {
    @autoreleasepool {
        // Notify receipt of length bytes
        [self.mainVC.dataRateRecorder bytesReceived:length];

        // Pass each byte to the MAVLINK parser
        for (NSUInteger byteIdx = 0; byteIdx < length; byteIdx++) {
            if (mavlink_parse_char(MAVLINK_COMM_0, bytes[byteIdx], &msg, &status)) {
                // We completed a packet, so...
                switch (msg.msgid) {
                    case MAVLINK_MSG_ID_HEARTBEAT:
                        [self processHeartbeat];
                        [self.heartbeatManager rescheduleLossCheck];
                        break;
                    case MAVLINK_MSG_ID_RADIO_STATUS:
                        DDLogDebug(@"Mavlink msg Radio Status found (109)");
                        DDLogDebug(@"Remote RSSI is %u", mavlink_msg_radio_status_get_remrssi(&msg));
                        if (mavlink_msg_radio_status_get_remrssi(&msg) > 50){
                            self.radioLinked = YES;
                        }
                        break;
                    case MAVLINK_MSG_ID_RADIO:
                        DDLogDebug(@"Mavlink msg Radio found (166)");
                        break;
                    case MAVLINK_MSG_ID_STATUSTEXT:
                        break;
                    case MAVLINK_MSG_ID_SYS_STATUS:
                        break;
                    default:
                        // If we get any other message than heartbeat or radio messages, we are getting the messages we requested
                        self.heartbeatOnlyCount = 0;
                        DDLogVerbose(@"The msg id is %d (0x%x)", msg.msgid, msg.msgid);
                        break;
                }
                // Pass to the retrying request handler in case we need to process an ACK
                [retryRequestHandler checkForAckOnCurrentRequest:msg];
                
                // Then send the packet on to the child views
                [self.mainVC handlePacket:&msg];
            }
        }
    }
}


#pragma mark - Mission Transactions: receiving
- (void) startReadMissionRequest {
    [retryRequestHandler startRetryingRequest:[[RxMissionRequestList alloc] initWithInterface:self]];
}

- (void) completedReadMissionRequest:(WaypointsHolder*)mission {
    [self issueRawMissionAck];     // acknowledge completion of mission reception
    [self loadNewMission:mission]; // load the mission
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

#pragma mark - Handle heartbeats
- (void) processHeartbeat {
    DDLogDebug(@"MavLink Heartbeat.");
    
    // If we haven't gotten anything but heartbeats or Radio messages in 5 seconds re-request the messages
    if ((++ _heartbeatOnlyCount) >= 5) {
        self.mavLinkInitialized = NO;
    }
    
    if (!self.mavLinkInitialized) {
        // only send heartbeat in normal data rate mode
        if (GCSStandardDataRateModeEnabled && !self.heartbeatTimer) {
            self.heartbeatTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                                   target:self
                                                                 selector:@selector(sendHeatbeatToAutopilot)
                                                                 userInfo:nil repeats:YES];
        }
    }
    
    if ((!self.mavLinkInitialized) && self.radioLinked) {
        
        self.mavLinkInitialized = YES;
        
        // Decode the heartbeat message
        mavlink_msg_heartbeat_decode(&msg, &heartbeat);
        mavlink_system.sysid  = msg.sysid;
        mavlink_system.compid = (msg.compid+1) % 255; // Use a compid that is distinct from the vehicle's
        
        //Reqeuest the data streams to be sent
        [self requestDataStreams];
    }
}

#pragma mark - request/stop MAVLink data streams
- (void) requestDataStreams {
    DDLogInfo(@"Sending request for MavLink messages.");
    
    // Send requests to set the stream rates
    
    mavlink_msg_request_data_stream_send(MAVLINK_COMM_0, msg.sysid, msg.compid,
                                         MAV_DATA_STREAM_ALL, 0, 0); // stop all
    
    // only message requested for low datarate mode
    mavlink_msg_request_data_stream_send(MAVLINK_COMM_0, msg.sysid, msg.compid,
                                         MAV_DATA_STREAM_EXTRA1, RATE_ATTITUDE, 1);
    
    if (GCSStandardDataRateModeEnabled) {
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
                                             MAV_DATA_STREAM_EXTRA2, RATE_VFR_HUD, 1);
        mavlink_msg_request_data_stream_send(MAVLINK_COMM_0, msg.sysid, msg.compid,
                                             MAV_DATA_STREAM_EXTRA3, RATE_EXTRA3, 1);
        
        
        // only start mission request if we are in normal data rate mode
        [self startReadMissionRequest];
    }
    
}

- (void)stopRecevingMessages {
    mavlink_msg_request_data_stream_send(MAVLINK_COMM_0, msg.sysid, msg.compid,
                                         MAV_DATA_STREAM_ALL, 0, 0); // stop all
}

- (void) loadNewMission:(WaypointsHolder*)mission {
    // Let the MainVC know we've got new waypoints
    DDLogDebug(@"Loading mission:\n%@", [mission toOutputFormat]);
    [self.mainVC replaceMission:mission];
}


#pragma mark - Mission Transactions: sending

- (void) startWriteMissionRequest:(WaypointsHolder*)mission {
    id<MavLinkRetryableRequest> req = (mission.numWaypoints == 0) ?
        [[TxMissionClearAll alloc] initWithInterface:self] :
        [[TxMissionItemCount alloc] initWithInterface:self andMission:mission];
    [retryRequestHandler startRetryingRequest:req];
}

- (void) completedWriteMissionRequestSuccessfully:(BOOL)success withMission:(WaypointsHolder*)mission {
    if (success) {
        [self loadNewMission:mission];
    }
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

- (void) issueRawMissionClearAll {
    mavlink_msg_mission_clear_all_send(MAVLINK_COMM_0, msg.sysid, msg.compid);
}

#pragma mark - Set current waypoint

- (void) startSetWaypointRequest:(uint16_t)sequence {
    [retryRequestHandler startRetryingRequest:[[SetWPRequest alloc] initWithInterface:self andSequence:sequence]];
}

- (void) issueRawSetWaypointCommand:(uint16_t)sequence {
    mavlink_msg_mission_set_current_send(MAVLINK_COMM_0, msg.sysid, msg.compid, sequence);
}


#pragma mark - Miscellaneous requests

+ (void)invokeBlock:(void (^)(void))block dispatchingAfter:(float)seconds {
    block();
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), block);
}

- (void) issueGOTOCommand:(CLLocationCoordinate2D)coordinates withAltitude:(float)altitude {
    // As per mission planner, send the GOTO command twice with a minor delay
    // (simple way to improve reliability without checking return ACK)
    [iGCSMavLinkInterface invokeBlock:^{ mavlink_msg_mission_item_send(MAVLINK_COMM_0, msg.sysid, msg.compid, 0,
                                                                       MAV_FRAME_GLOBAL_RELATIVE_ALT,
                                                                       MAV_CMD_NAV_WAYPOINT,
                                                                       // Special flag that indicates this is a GUIDED mode packet
                                                                       MAV_GOTO_HOLD_AT_CURRENT_POSITION,
                                                                       0, 0, 0, 0, 0,
                                                                       coordinates.latitude, coordinates.longitude, altitude);}
     dispatchingAfter:0.5];
}

+ (void) issueModeCommand:(uint32_t)mode {
    [iGCSMavLinkInterface invokeBlock:^{ mavlink_msg_set_mode_send(MAVLINK_COMM_0, msg.sysid, MAV_MODE_FLAG_CUSTOM_MODE_ENABLED, mode); }
                     dispatchingAfter:0.01];
}

- (void) issueSetAUTOModeCommand {
    [iGCSMavLinkInterface issueModeCommand:[GCSDataManager sharedInstance].craft.autoMode];
}

- (void) issueSetGuidedModeCommand {
    [iGCSMavLinkInterface issueModeCommand:[GCSDataManager sharedInstance].craft.guidedMode];
}

- (void) sendMavlinkTakeOffCommand {
    mavlink_msg_command_long_send(MAVLINK_COMM_0, msg.sysid, msg.compid, MAV_CMD_NAV_TAKEOFF, 0, 0, 0, 0, 0, 0, 0, 10);
}

- (void) sendLand {
    mavlink_msg_command_long_send(MAVLINK_COMM_0, msg.sysid, msg.compid, MAV_CMD_NAV_LAND, 0, 0, 0, 0, 0, 0, 0, 0);
}

- (void) sendReturnToLaunch {
    mavlink_msg_command_long_send(MAVLINK_COMM_0, msg.sysid, msg.compid, MAV_CMD_NAV_RETURN_TO_LAUNCH, 0, 0, 0, 0, 0, 0, 0, 0);
}

- (void) sendPairSpektrumDSMX{
    mavlink_msg_command_long_send(MAVLINK_COMM_0, msg.sysid, msg.compid, MAV_CMD_START_RX_PAIR, 0, 1, 0, 0, 0, 0, 0, 0);
}

- (void) sendMoveCommandWithPitch:(int16_t)pitch
                          andRoll:(int16_t)roll
                        andThrust:(int16_t)thrust
                           andYaw:(int16_t)yaw
                andSequenceNumber:(uint16_t)sequenceNumber{
    mavlink_msg_manual_control_send(msg.sysid, msg.compid, pitch, roll, thrust, yaw, sequenceNumber);
}


- (void) loadDemoMission {
    WaypointsHolder* demo = [WaypointsHolder createDemoMission];
    DDLogDebug(@"Loading mission:\n%@", [[WaypointsHolder createFromQGCString:[demo toOutputFormat]] toOutputFormat]);
    [self.mainVC replaceMission:demo];
}

-(void) sendHeatbeatToAutopilot {
    mavlink_msg_heartbeat_send(MAVLINK_COMM_0, MAV_TYPE_GCS, MAV_AUTOPILOT_INVALID, 0, 0, 0);
}

#pragma mark - NSNotifcation handlers
-(void) handleRadioEnteredConfigMode {
    [self.heartbeatTimer invalidate];
    self.heartbeatTimer = nil;
}

#pragma mark - ArDrone AT commands

- (void) arDroneTakeOff {
    const char* buf = [ArDroneAtUtilsAtCommandedTakeOff cStringUsingEncoding:NSASCIIStringEncoding];
    uint32_t len = (uint32_t)strlen(buf);
    [appMLI produceData:(uint8_t*)buf length:len];
}

- (void) arDroneLand {
    const char* buf = [ArDroneAtUtilsAtCommandedLand cStringUsingEncoding:NSASCIIStringEncoding];
    uint32_t len = (uint32_t)strlen(buf);
    [appMLI produceData:(uint8_t*)buf length:len];
}

- (void) arDroneCalibrateHorizontalPlane {
    const char* buf = [ArDroneAtUtilsCalibrateHorizontalPlane cStringUsingEncoding:NSASCIIStringEncoding];
    uint32_t len = (uint32_t)strlen(buf);
    [appMLI produceData:(uint8_t*)buf length:len];
}

- (void) arDroneCalibrateMagnetometer {
    const char* buf = [ArDroneAtUtilsCalibrateMagnetometer cStringUsingEncoding:NSASCIIStringEncoding];
    uint32_t len = (uint32_t)strlen(buf);
    [appMLI produceData:(uint8_t*)buf length:len];
}

- (void) arDroneToggleEmergency {
    const char* buf = [ArDroneAtUtilsToggleEmergency cStringUsingEncoding:NSASCIIStringEncoding];
    uint32_t len = (uint32_t)strlen(buf);
    [appMLI produceData:(uint8_t*)buf length:len];
}

- (void) arDroneResetWatchDogTimer {
    const char* buf = [ArDroneAtUtilsResetWatchDogTimer cStringUsingEncoding:NSASCIIStringEncoding];
    uint32_t len = (uint32_t)strlen(buf);
    [appMLI produceData:(uint8_t*)buf length:len];
}


- (void) arDronePhiM30 {
    const char* buf = [ArDroneAtUtilsPhiM30 cStringUsingEncoding:NSASCIIStringEncoding];
    uint32_t len = (uint32_t)strlen(buf);
    [appMLI produceData:(uint8_t*)buf length:len];
}

- (void) arDronePhi30 {
    const char* buf = [ArDroneAtUtilsPhi30 cStringUsingEncoding:NSASCIIStringEncoding];
    uint32_t len = (uint32_t)strlen(buf);
    [appMLI produceData:(uint8_t*)buf length:len];
}

- (void) arDroneThetaM30 {
    const char* buf = [ArDroneAtUtilsThetaM30 cStringUsingEncoding:NSASCIIStringEncoding];
    uint32_t len = (uint32_t)strlen(buf);
    [appMLI produceData:(uint8_t*)buf length:len];
}

- (void) arDroneTheta30 {
    const char* buf = [ArDroneAtUtilsTheta30 cStringUsingEncoding:NSASCIIStringEncoding];
    uint32_t len = (uint32_t)strlen(buf);
    [appMLI produceData:(uint8_t*)buf length:len];
}

- (void) arDroneTheta20degYaw200 {
    const char* buf = [ArDroneAtUtilsTheta20degYaw200 cStringUsingEncoding:NSASCIIStringEncoding];
    uint32_t len = (uint32_t)strlen(buf);
    [appMLI produceData:(uint8_t*)buf length:len];
}

- (void) arDroneTheta20degYawM200 {
    const char* buf = [ArDroneAtUtilsTheta20degYawM200 cStringUsingEncoding:NSASCIIStringEncoding];
    uint32_t len = (uint32_t)strlen(buf);
    [appMLI produceData:(uint8_t*)buf length:len];
}

- (void) arDroneTurnAround {
    const char* buf = [ArDroneAtUtilsTurnAround cStringUsingEncoding:NSASCIIStringEncoding];
    uint32_t len = (uint32_t)strlen(buf);
    [appMLI produceData:(uint8_t*)buf length:len];
}

- (void) arDroneTurnAroundGoDown {
    const char* buf = [ArDroneAtUtilsTurnAroundGoDown cStringUsingEncoding:NSASCIIStringEncoding];
    uint32_t len = (uint32_t)strlen(buf);
    [appMLI produceData:(uint8_t*)buf length:len];
}

- (void) arDroneYawShake {
    const char* buf = [ArDroneAtUtilsYawShake cStringUsingEncoding:NSASCIIStringEncoding];
    uint32_t len = (uint32_t)strlen(buf);
    [appMLI produceData:(uint8_t*)buf length:len];
}

- (void) arDroneYawDance {
    const char* buf = [ArDroneAtUtilsYawDance cStringUsingEncoding:NSASCIIStringEncoding];
    uint32_t len = (uint32_t)strlen(buf);
    [appMLI produceData:(uint8_t*)buf length:len];
}

- (void) arDronePhiDance {
    const char* buf = [ArDroneAtUtilsPhiDance cStringUsingEncoding:NSASCIIStringEncoding];
    uint32_t len = (uint32_t)strlen(buf);
    [appMLI produceData:(uint8_t*)buf length:len];
}

- (void) arDroneThetaDance {
    const char* buf = [ArDroneAtUtilsThetaDance cStringUsingEncoding:NSASCIIStringEncoding];
    uint32_t len = (uint32_t)strlen(buf);
    [appMLI produceData:(uint8_t*)buf length:len];
}

- (void) arDroneVzDance {
    const char* buf = [ArDroneAtUtilsVzDance cStringUsingEncoding:NSASCIIStringEncoding];
    uint32_t len = (uint32_t)strlen(buf);
    [appMLI produceData:(uint8_t*)buf length:len];
}

- (void) arDroneWave {
    const char* buf = [ArDroneAtUtilsWave cStringUsingEncoding:NSASCIIStringEncoding];
    uint32_t len = (uint32_t)strlen(buf);
    [appMLI produceData:(uint8_t*)buf length:len];
}

- (void) arDronePhiThetaMixed {
    const char* buf = [ArDroneAtUtilsPhiThetaMixed cStringUsingEncoding:NSASCIIStringEncoding];
    uint32_t len = (uint32_t)strlen(buf);
    [appMLI produceData:(uint8_t*)buf length:len];
}

- (void) arDroneFlipAhead {
    const char* buf = [ArDroneAtUtilsFlipAhead cStringUsingEncoding:NSASCIIStringEncoding];
    uint32_t len = (uint32_t)strlen(buf);
    [appMLI produceData:(uint8_t*)buf length:len];
}

- (void) arDroneFlipBehind {
    const char* buf = [ArDroneAtUtilsFlipBehind cStringUsingEncoding:NSASCIIStringEncoding];
    uint32_t len = (uint32_t)strlen(buf);
    [appMLI produceData:(uint8_t*)buf length:len];
}


- (void) arDroneFlipLeft {
    const char* buf = [ArDroneAtUtilsFlipLeft cStringUsingEncoding:NSASCIIStringEncoding];
    uint32_t len = (uint32_t)strlen(buf);
    [appMLI produceData:(uint8_t*)buf length:len];
}

- (void) arDroneFlipRight {
    const char* buf = [ArDroneAtUtilsFlipRight cStringUsingEncoding:NSASCIIStringEncoding];
    uint32_t len = (uint32_t)strlen(buf);
    [appMLI produceData:(uint8_t*)buf length:len];
}




@end
