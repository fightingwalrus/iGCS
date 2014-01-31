//
//  GCSSidebarController.m
//  iGCS
//
//  Created by Claudio Natoli on 31/01/2014.
//
//

#import "GCSSidebarController.h"

@interface GCSSidebarController ()

@end

@implementation GCSSidebarController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

// Forced clear background as per suggestion: http://stackoverflow.com/questions/18878258/uitableviewcell-show-white-background-and-cannot-be-modified-on-ios7
// Unclear why the cell clear color set in IB is not respected.
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell setBackgroundColor:[UIColor clearColor]];
}

- (void) handlePacket:(mavlink_message_t*)msg {
    switch (msg->msgid) {
            
        // GPS section
        case MAVLINK_MSG_ID_GPS_RAW_INT:
        {
            mavlink_gps_raw_int_t gpsRawIntPkt;
            mavlink_msg_gps_raw_int_decode(msg, &gpsRawIntPkt);
            [_numSatellitesLabel setText:[NSString stringWithFormat:@"%d", gpsRawIntPkt.satellites_visible]];
            [_gpsFixTypeLabel    setText: (gpsRawIntPkt.fix_type == 3) ? @"3D" : ((gpsRawIntPkt.fix_type == 2) ? @"2D" : @"No fix")];
        }
            break;

        case MAVLINK_MSG_ID_GPS_STATUS:
        {
            mavlink_gps_status_t gpsStatus;
            mavlink_msg_gps_status_decode(msg, &gpsStatus);
            [_numSatellitesLabel setText:[NSString stringWithFormat:@"%d", gpsStatus.satellites_visible]];
        }
            break;
    

        // System section
        case MAVLINK_MSG_ID_ATTITUDE:
        {
            mavlink_attitude_t attitudePkt;
            mavlink_msg_attitude_decode(msg, &attitudePkt);
            [_sysUptimeLabel  setText:[NSString stringWithFormat:@"%0.1f s", attitudePkt.time_boot_ms/1000.0f]];
        }
            break;
            
        case MAVLINK_MSG_ID_HWSTATUS:
        {
            mavlink_hwstatus_t hwStatus;
            mavlink_msg_hwstatus_decode(msg, &hwStatus);
            [_sysVoltageLabel setText:[NSString stringWithFormat:@"%0.2fV", hwStatus.Vcc/1000.f]];
        }
            break;
            
        case MAVLINK_MSG_ID_MEMINFO:
        {
            mavlink_meminfo_t memFree;
            mavlink_msg_meminfo_decode(msg, &memFree);
            [_sysMemFreeLabel setText:[NSString stringWithFormat:@"%0.1fkB", memFree.freemem/1024.0f]];
        }
            break;
    }
}

@end
