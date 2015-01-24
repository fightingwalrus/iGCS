//
//  GCSCraftArduCopter.m
//  iGCS
//
//  Created by Claudio Natoli on 24/01/2015.
//
//

#import "GCSCraftArduCopter.h"

@implementation GCSCraftArduCopter

@synthesize icon = _icon;

- (id<GCSCraftModel>) init:(mavlink_heartbeat_t)heartbeat {
    self = [super init];
    if (self) {
        _heartbeat = heartbeat;
        _icon = [UIImage imageNamed:@"quad-icon.png"];
    }
    return self;
}

- (void) update:(mavlink_heartbeat_t)heartbeat {
    self.heartbeat = heartbeat;
}

- (GCSCraftType) craftType {
    return ArduCopter;
}

- (uint32_t) autoMode {
    return APMCopterAuto;
}

- (uint32_t) guidedMode {
    return APMCopterGuided;
}

- (BOOL) setModeBeforeGuidedItems {
    return YES; // For 3.2+
}

- (BOOL) isInAutoMode {
    return self.heartbeat.custom_mode == APMCopterAuto;
}

- (BOOL) isInGuidedMode {
    return self.heartbeat.custom_mode == APMCopterGuided;
}

@end
