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
NSString * const GCSCraftNotificationsCraftArmedStatusDidChange = @"GCSCraftNotificationsCraftArmedStatusDidChange";

@implementation GCSCraftNotifications

+ (void)didNavModeChangeFromLastHeartbeat:(GCSHeartbeat *) lastHeartbeat
                      andNewHeartbeat:(GCSHeartbeat *) newHeartbeat {


    if (lastHeartbeat && lastHeartbeat.customMode == newHeartbeat.customMode) return;

    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter]postNotificationName:GCSCraftNotificationsCraftCustomModeDidChange
                                                           object:nil];
    });
}

+ (void)didArmedStatusChangeFromLastHeartbeat:(GCSHeartbeat *) lastHeartbeat
                              andNewHeartbeat:(GCSHeartbeat *) newHeartbeat {


    // if lastHeartbeat is not nil AND the armings status has not changes return
    if (lastHeartbeat && (lastHeartbeat.isArmed) == (newHeartbeat.isArmed)) {
        return;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter]postNotificationName:GCSCraftNotificationsCraftArmedStatusDidChange
                                                           object:nil];
    });
}

@end
