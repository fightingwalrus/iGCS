//
//  GCSCraftEventDispatcher.m
//  iGCS
//
//  Created by Andrew Brown on 1/25/15.
//
//

#import "GCSCraftNotifications.h"
#import "GCSCraftModes.h"

NSString * const GCSCraftNotificationsCraftCustomModeDidChange = @"GCSCraftNotificationsCraftCustomModeDidChange";

@implementation GCSCraftNotifications

+ (void)didNavModeChangeFromLastHeartbeat:(mavlink_heartbeat_t) lastHeartbeat
                      andCurrentHeartbeat:(mavlink_heartbeat_t) currentHeartbeat {

    if (lastHeartbeat.custom_mode == currentHeartbeat.custom_mode) return;

    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter]postNotificationName:GCSCraftNotificationsCraftCustomModeDidChange
                                                           object:nil];
    });
}

@end
