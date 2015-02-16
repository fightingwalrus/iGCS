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
                      andNewHeartbeat:(mavlink_heartbeat_t) newHeartbeat;

+ (void)didMavModeChangeFromLastHeartbeat:(mavlink_heartbeat_t) lastHeartbeat
                          andNewHeartbeat:(mavlink_heartbeat_t) newHeartbeat;

@end

extern NSString * const GCSCraftNotificationsCraftCustomModeDidChange;
extern NSString * const GCSCraftNotificationsCraftMavModeDidChange;