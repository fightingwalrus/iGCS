//
//  GCSCraftEventDispatcher.h
//  iGCS
//
//  Created by Andrew Brown on 1/25/15.
//
//

#import <Foundation/Foundation.h>
#import "GCSHeartbeat.h"

@interface GCSCraftNotifications : NSObject

+ (void)didNavModeChangeFromLastHeartbeat:(GCSHeartbeat *) lastHeartbeat
                      andNewHeartbeat:(GCSHeartbeat *) newHeartbeat;

+ (void)didArmedStatusChangeFromLastHeartbeat:(GCSHeartbeat*) lastHeartbeat
                              andNewHeartbeat:(GCSHeartbeat*) newHeartbeat;

@end

extern NSString * const GCSCraftNotificationsCraftCustomModeDidChange;
extern NSString * const GCSCraftNotificationsCraftArmedStatusDidChange;