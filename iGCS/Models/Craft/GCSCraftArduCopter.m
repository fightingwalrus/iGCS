//
//  GCSCraftArduCopter.m
//  iGCS
//
//  Created by Claudio Natoli on 24/01/2015.
//
//

#import "GCSCraftArduCopter.h"
#import "GCSCraftNotifications.h"

@interface GCSCraftArduCopter ()
@property (nonatomic, assign) mavlink_heartbeat_t lastHeartbeat;
@property (nonatomic, strong) NSDictionary *customModeNames;
@end

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
        _customModeNames =  @{@(APMCopterStabilize): @"Stabilize",
                              @(APMCopterAcro): @"Acro",
                              @(APMCopterAltHold): @"AltHold",
                              @(APMCopterAuto): @"Auto",
                              @(APMCopterGuided): @"Guided",
                              @(APMCopterLoiter): @"Loiter",
                              @(APMCopterRtl): @"RTL",
                              @(APMCopterCircle): @"Circle",
                              @(APMCopterPosition): @"Position",
                              @(APMCopterLand): @"Land",
                              @(APMCopterOfLoiter): @"OfLoiter",
                              @(APMCopterDrift): @"Drift",
                              @(APMCopterSport): @"Sport"};

    }

    return self;
}

- (void) update:(mavlink_heartbeat_t)heartbeat {
    self.lastHeartbeat = self.heartbeat;
    self.heartbeat = heartbeat;

    [GCSCraftNotifications didNavModeChangeFromLastHeartbeat:self.lastHeartbeat
                                         andCurrentHeartbeat:self.heartbeat];
}

- (BOOL) isInAutoMode {
    return self.heartbeat.custom_mode == APMCopterAuto;
}

- (BOOL) isInGuidedMode {
    return self.heartbeat.custom_mode == APMCopterGuided;
}

- (NSString *) currentModeName {
    return self.customModeNames[@(self.heartbeat.custom_mode)];
}

@end
