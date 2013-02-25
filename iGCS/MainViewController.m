//
//  MainViewController.m
//  iGCS
//
//  Created by Claudio Natoli on 5/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "AppDelegate.h" // For TestFlight control

#import "MainViewController.h"

// Include before CommsViewController etc, as they
// import MavLinkTools with MAVLINK_SEPARATE_HELPERS defined
#import "MavLinkTools.h"

#import "CommsViewController.h"
#import "GCSMapViewController.h"
#import "WaypointsViewController.h"

#import "WaypointsHolder.h"

#import "GaugeViewCommon.h"


@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {    
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
#if DO_NSLOG
    if ([self isViewLoaded]) {
        NSLog(@"\tMainViewController::didReceiveMemoryWarning: view is still loaded");
    } else {
        NSLog(@"\tMainViewController::didReceiveMemoryWarning: view is NOT loaded");
    }
#endif
}

RscMgr *g_rscMgr = NULL;

- (void)awakeFromNib   
{
    // Get the views for convenience
    gcsMapVC   = [[self viewControllers] objectAtIndex:0];
    commsVC    = [[self viewControllers] objectAtIndex:1];
    waypointVC = [[self viewControllers] objectAtIndex:2];

    // Start the Redpark Serial Cable Manager
    rscMgr = [[RscMgr alloc] init]; 
    [rscMgr setDelegate:self];  // FIXME: figure out best place to make this call to avoid commsVC "missing" (resetting) the initial cableConnected message when starting up with the cable already connected
    g_rscMgr = rscMgr;
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Access view of all controllers to force load
    for (id controller in [self viewControllers]) {
        [controller view];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

#pragma mark -

#pragma mark RSC delegate
- (void) cableConnected:(NSString *)protocol
{   
    /*
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"cableConnected" 
                                                    message:@"connecting..." delegate:nil 
                                                    cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    */
     
    // Configure the serial connection
    [rscMgr setBaud:57600];
    [rscMgr setDataSize:SERIAL_DATABITS_8];
    [rscMgr setParity:SERIAL_PARITY_NONE];
    [rscMgr setStopBits:1];
        
    // Now open the serial communication session using the
    // serial port configuration options we've already set.
    // However, the baud rate, data size, parity, etc....
    // can be changed after calling open if needed.
    [rscMgr open];     

    cableConnected = true;
    [commsVC setCableConnectionStatus: cableConnected];
}


- (void) cableDisconnected
{
    cableConnected = false;
    [commsVC setCableConnectionStatus:cableConnected];
}


- (void) portStatusChanged
{
}

- (void) issueReadWaypointsRequest {

#if 0
    // Debug - add a couple fake waypoints when requested
    mavlink_waypoint_t waypoint;
    waypoint.command = 0;
    WaypointsHolder *zz = [[WaypointsHolder alloc] initWithExpectedCount:2];
    [zz addWaypoint:waypoint];
    [zz addWaypoint:waypoint];
    [waypointVC updateWaypoints: zz];
#endif
    mavlink_msg_mission_ack_send(MAVLINK_COMM_0, msg.sysid, msg.compid, 0); // send ACK just in case...

    // Start Read MAV waypoint protocol transaction
    mavlink_msg_mission_request_list_send(MAVLINK_COMM_0, msg.sysid, msg.compid);
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
        [gcsMapVC   updateWaypoints: newWaypoints];
        [waypointVC updateWaypoints: newWaypoints];
    } else {
        mavlink_msg_mission_request_send(MAVLINK_COMM_0, msg.sysid, msg.compid, [waypoints numWaypoints]);
    }
}

mavlink_message_t msg;
mavlink_status_t status;
mavlink_heartbeat_t heartbeat;

WaypointsHolder *newWaypoints;

- (void) readBytesAvailable:(UInt32)numBytes
{
    @autoreleasepool {
        
        // Read the available bytes out of the serial cable manager
        uint8_t buf[numBytes];
        int n = [rscMgr read:(uint8_t*)&buf Length:numBytes];
        
        // Notify the comms view of receipt of n bytes
        [commsVC bytesReceived: n];
        
        // Pass each byte to the MAVLINK parser
        for (unsigned int i = 0; i < n; i++) {
            if (mavlink_parse_char(MAVLINK_COMM_0, buf[i], &msg, &status)) {
                // We completed a packet, so...
                switch (msg.msgid) {
                    case MAVLINK_MSG_ID_HEARTBEAT:
                        heartbeatOnlyCount = [NSNumber numberWithInt:[heartbeatOnlyCount intValue] + 1];
                        //If we haven't gotten anything but heartbeats in 5 seconds re-request the messages
                        if([heartbeatOnlyCount intValue] > 5)
                        {
                            mavLinkInitialized = false;
                        }
                        if (!mavLinkInitialized) {
                            TESTFLIGHT_CHECKPOINT(@"FIRST HEARTBEAT");
                            mavLinkInitialized = true;

                            // Decode the heartbeat message
                            mavlink_msg_heartbeat_decode(&msg, &heartbeat);
                            mavlink_system.sysid = msg.sysid;
                            mavlink_system.compid = msg.compid;
                            
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
                        if ([newWaypoints allWaypointsReceivedP]) {
                            mavlink_waypoint_t waypoint = [newWaypoints getWaypoint:(z % [newWaypoints numWaypoints])];
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
                        mavlink_mission_count_t count;
                        mavlink_msg_mission_count_decode(&msg, &count);
                        
                        newWaypoints = [[WaypointsHolder alloc] initWithExpectedCount:count.count];
                        [self requestNextWaypointOrACK:newWaypoints];
                    }
                        break;
                     
                    case MAVLINK_MSG_ID_MISSION_ITEM:
                    {
                        mavlink_mission_item_t waypoint;
                        mavlink_msg_mission_item_decode(&msg, &waypoint);
                        
                        [newWaypoints addWaypoint:waypoint];
                        [self requestNextWaypointOrACK:newWaypoints];
                    }
                        break;
                        
                    case MAVLINK_MSG_ID_GLOBAL_POSITION_INT:
                    case MAVLINK_MSG_ID_ATTITUDE:
                    case MAVLINK_MSG_ID_VFR_HUD:
                        break;

                    default:
                    {
                        //If we get any other message than heartbeat, we are getting the messages we requested
                        heartbeatOnlyCount = [NSNumber numberWithInt:0];
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
                [gcsMapVC handlePacket:&msg];
                [commsVC  handlePacket:&msg];
                [waypointVC handlePacket:&msg];
#endif
            }
        }
    }
}

static void send_uart_bytes(mavlink_channel_t chan, uint8_t *buffer, uint16_t len)
{
#if DO_NSLOG
    NSLog(@"send_uart_bytes: sending %hu chars", len);
#endif
    int n = [g_rscMgr write:buffer Length:len];
#if DO_NSLOG
    if (n == len)    
        NSLog(@"send_uart_bytes: output %d chars", n);
    else
        NSLog(@"send_uart_bytes: FAILED (only %d sent)", n);
#endif
}

@end
