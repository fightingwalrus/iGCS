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
    }
}

@end
