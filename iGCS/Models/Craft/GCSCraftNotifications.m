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
                      andNewHeartbeat:(mavlink_heartbeat_t) newHeartbeat {

    if (lastHeartbeat.custom_mode == newHeartbeat.custom_mode) return;

    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter]postNotificationName:GCSCraftNotificationsCraftCustomModeDidChange
                                                           object:nil];
    });
}

@end
