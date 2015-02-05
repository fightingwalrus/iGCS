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
#import "GCSCraftMixins.h"
#import "Mixin.h"

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

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self mixinFrom:[GCSCraftMixins class]];
    });
}

- (BOOL) isInAutoMode {
    return self.heartbeat.custom_mode == APMCopterAuto;
}

- (BOOL) isInGuidedMode {
    return self.heartbeat.custom_mode == APMCopterGuided;
}

@end
