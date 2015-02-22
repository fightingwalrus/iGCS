//
//  GCSCraftMixins.m
//  iGCS
//
//  Created by Andrew Brown on 1/28/15.
//
//

#import "GCSCraftMixins.h"
#import "MavLinkUtility.h"
#import <objc/runtime.h>

@implementation GCSCraftMixins

-(void)updateWithHeartbeat:(GCSHeartbeat *)heartbeat {
    // this is needed because we expect the model state to have
    // already changed by the time NSNotifications are
    // dispatch so the model properties must be updated
    // before the notifications are sent out.
    GCSHeartbeat *lastHeartbeat = [(id)self heartbeat];
    [(id)self setHeartbeat:heartbeat];

    // Order of notifications matter to GCSSpeechManager
    // and we want to hear arming status followed by the flight mode.
    [GCSCraftNotifications didArmedStatusChangeFromLastHeartbeat:lastHeartbeat
                                                 andNewHeartbeat:[(id)self heartbeat]];

    [GCSCraftNotifications didNavModeChangeFromLastHeartbeat:lastHeartbeat
                                             andNewHeartbeat:[(id)self heartbeat]];

}

- (NSString *)currentModeName {
    return [MavLinkUtility mavCustomModeToString:[(id)self heartbeat]];
}

- (BOOL)isArmed {
    return ([(id)self heartbeat].isArmed);
}

// class lifecycle
- (void)dealloc {
    [[(id)self notificationCenter] removeObserver:self];
}

@end
