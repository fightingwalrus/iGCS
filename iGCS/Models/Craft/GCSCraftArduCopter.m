//
//  GCSCraftArduCopter.m
//  iGCS
//
//  Created by Claudio Natoli on 24/01/2015.
//
//

#import "GCSCraftArduCopter.h"
#import "GCSCraftNotifications.h"
#import "MavLinkUtility.h"

@implementation GCSCraftArduCopter

@synthesize craftType  = _craftType;
@synthesize autoMode   = _autoMode;
@synthesize guidedMode = _guidedMode;
@synthesize setModeBeforeGuidedItems  = _setModeBeforeGuidedItems;
@synthesize icon = _icon;

- (id<GCSCraftModel>) init:(mavlink_heartbeat_t)heartbeat {
    self = [super init];
    if (self) {
        _heartbeat = heartbeat;
        
        _craftType   = ArduCopter;
        _autoMode    = APMCopterAuto;
        _guidedMode  = APMCopterGuided;
        _setModeBeforeGuidedItems = YES; // For 3.2+
        _icon = [UIImage imageNamed:@"quad-icon.png"];
    }

    return self;
}

- (void) updateWithHeartbeat:(mavlink_heartbeat_t)heartbeat {
    
    // this is needed because we expect the model state to have
    // already changed by the time NSNotifications are
    // dispatch so the model properties must be updated
    // before the notifications are sent out.
    mavlink_heartbeat_t lastHeartbeat = self.heartbeat;
    self.heartbeat = heartbeat;

    [GCSCraftNotifications didNavModeChangeFromLastHeartbeat:lastHeartbeat
                                             andNewHeartbeat:self.heartbeat];
    
}

- (BOOL) isInAutoMode {
    return self.heartbeat.custom_mode == APMCopterAuto;
}

- (BOOL) isInGuidedMode {
    return self.heartbeat.custom_mode == APMCopterGuided;
}

- (NSString *) currentModeName {
    return [MavLinkUtility mavCustomModeToString:self.heartbeat];
}

@end
