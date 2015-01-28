//
//  GCSCraftArduPlane.m
//  iGCS
//
//  Created by Claudio Natoli on 24/01/2015.
//
//

#import "GCSCraftArduPlane.h"
#import "GCSCraftNotifications.h"
#import "MavLinkUtility.h"

@implementation GCSCraftArduPlane

@synthesize craftType  = _craftType;
@synthesize autoMode   = _autoMode;
@synthesize guidedMode = _guidedMode;
@synthesize setModeBeforeGuidedItems  = _setModeBeforeGuidedItems;
@synthesize icon = _icon;

- (id<GCSCraftModel>) init:(mavlink_heartbeat_t)heartbeat {
    self = [super init];
    if (self) {
        _heartbeat = heartbeat;
        
        _craftType   = ArduPlane;
        _autoMode    = APMPlaneAuto;
        _guidedMode  = APMPlaneGuided;
        _setModeBeforeGuidedItems = NO;
        _icon = [UIImage imageNamed:@"plane-icon.png"];

    }
    return self;
}

- (void) updateWithHeartbeat:(mavlink_heartbeat_t)newHeartbeat {

    [GCSCraftNotifications didNavModeChangeFromLastHeartbeat:self.heartbeat
                                         andNewHeartbeat:newHeartbeat];

    self.heartbeat = newHeartbeat;
}

- (BOOL) isInAutoMode {
    return self.heartbeat.custom_mode == APMPlaneAuto;
}

- (BOOL) isInGuidedMode {
    return self.heartbeat.custom_mode == APMPlaneGuided;
}

- (NSString *) currentModeName {
    return [MavLinkUtility mavCustomModeToString:self.heartbeat];
}

@end
