//
//  GCSCraftArduCopter.m
//  iGCS
//
//  Created by Claudio Natoli on 24/01/2015.
//
//

#import "GCSCraftArduCopter.h"

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
        _icon = [UIImage imageNamed:@"quad-icon-248.png"];
    }
    return self;
}

- (void) update:(mavlink_heartbeat_t)heartbeat {
    self.heartbeat = heartbeat;
}

- (BOOL) isInAutoMode {
    return self.heartbeat.custom_mode == APMCopterAuto;
}

- (BOOL) isInGuidedMode {
    return self.heartbeat.custom_mode == APMCopterGuided;
}

@end
