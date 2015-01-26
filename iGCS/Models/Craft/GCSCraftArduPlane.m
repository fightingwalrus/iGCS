//
//  GCSCraftArduPlane.m
//  iGCS
//
//  Created by Claudio Natoli on 24/01/2015.
//
//

#import "GCSCraftArduPlane.h"
#import "GCSCraftNotifications.h"

@interface GCSCraftArduPlane ()
@property (nonatomic, assign) mavlink_heartbeat_t lastHeartbeat;
@property (nonatomic, strong) NSDictionary *customModeNames;
@end

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
        _customModeNames = @{@(APMPlaneManual): @"Manual",
                             @(APMPlaneCircle): @"Circle",
                             @(APMPlaneStabilize): @"Stabilize",
                             @(APMPlaneFlyByWireA): @"FBW_A",
                             @(APMPlaneFlyByWireB): @"FBW_B",
                             @(APMPlaneFlyByWireC): @"FBW_C",
                             @(APMPlaneAuto): @"Auto",
                             @(APMPlaneRtl): @"RTL",
                             @(APMPlaneLoiter): @"Loiter",
                             @(APMPlaneTakeoff): @"Takeoff",
                             @(APMPlaneLand): @"Land",
                             @(APMPlaneGuided): @"Guided",
                             @(APMPlaneInitialising): @"Initialising"};

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
    return self.heartbeat.custom_mode == APMPlaneAuto;
}

- (BOOL) isInGuidedMode {
    return self.heartbeat.custom_mode == APMPlaneGuided;
}

- (NSString *) currentModeName {
    return self.customModeNames[@(self.heartbeat.custom_mode)];
}

@end
