//
//  GCSCraftMixins.m
//  iGCS
//
//  Created by Andrew Brown on 1/28/15.
//
//

#import "GCSCraftMixins.h"
#import <objc/runtime.h>

@implementation GCSCraftMixins

+ (void) addMixinsToModel:(id<GCSCraftModel>)craftModel {

    // updateWithHeartbeat:
    class_addMethod([craftModel class],
                    @selector(updateWithHeartbeat:),
                    (IMP)updateWithHeartbeatIMP,
                    "v@^^{mavlink_heartbeat_t}");
}

@end

#pragma common methods to be injected into Craft model instances
void updateWithHeartbeatIMP (id self, SEL _cmd, mavlink_heartbeat_t heartbeat) {
    // this is needed because we expect the model state to have
    // already changed by the time NSNotifications are
    // dispatch so the model properties must be updated
    // before the notifications are sent out.
    mavlink_heartbeat_t lastHeartbeat = [self heartbeat];
    [self setHeartbeat:heartbeat];

    [GCSCraftNotifications didNavModeChangeFromLastHeartbeat:lastHeartbeat
                                             andNewHeartbeat:[self heartbeat]];
}