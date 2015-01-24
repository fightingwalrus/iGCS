//
//  GCSCraftArduPlane.m
//  iGCS
//
//  Created by Claudio Natoli on 24/01/2015.
//
//

#import "GCSCraftArduPlane.h"

@implementation GCSCraftArduPlane

- (id<GCSCraftModel>) init:(mavlink_heartbeat_t)heartbeat {
    self = [super init];
    if (self) {
        _heartbeat = heartbeat;
    }
    return self;
}

- (void) update:(mavlink_heartbeat_t)heartbeat {
    self.heartbeat = heartbeat;
}

- (GCSCraftType) craftType {
    return ArduPlane;
}

- (uint32_t) autoMode {
    return APMPlaneAuto;
}

- (uint32_t) guidedMode {
    return APMPlaneGuided;
}

- (BOOL) setModeBeforeGuidedItems {
    return NO;
}

@end
