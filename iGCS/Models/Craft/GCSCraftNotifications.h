//
//  GCSCraftEventDispatcher.h
//  iGCS
//
//  Created by Andrew Brown on 1/25/15.
//
//

#import <Foundation/Foundation.h>
#import "mavlink.h"

@interface GCSCraftNotifications : NSObject

+ (void)didNavModeChangeFromLastHeartbeat:(mavlink_heartbeat_t) lastHeartbeat
                      andCurrentHeartbeat:(mavlink_heartbeat_t) currentHeartbeat;

@end

extern NSString * const GCSCraftNotificationsCraftNavModeModeDidChanged;
