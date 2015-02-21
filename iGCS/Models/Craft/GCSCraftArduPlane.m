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
#import "GCSCraftMixins.h"
#import "Mixin.h"

@implementation GCSCraftArduPlane

@synthesize craftType  = _craftType;
@synthesize autoMode   = _autoMode;
@synthesize guidedMode = _guidedMode;
@synthesize setModeBeforeGuidedItems  = _setModeBeforeGuidedItems;
@synthesize icon = _icon;

- (id<GCSCraftModel>) init:(GCSHeartbeat *)heartbeat {
    self = [super init];
    if (self) {
        _heartbeat = heartbeat;
        
        _craftType   = ArduPlane;
        _autoMode    = APMPlaneAuto;
        _guidedMode  = APMPlaneGuided;
        _setModeBeforeGuidedItems = NO;
        _icon = [UIImage imageNamed:@"plane-icon-128.png"];

        // set heartbeat to nil when app goes into background so all
        // events fire again on app launch and telemetry reconnect
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearHearbeat)
                                                     name:UIApplicationDidEnterBackgroundNotification object:nil];

    }

    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self mixinFrom:[GCSCraftMixins class]];
    });
}

- (void)clearHearbeat {
    self.heartbeat = nil;
}

#pragma mark -  External API
- (BOOL) isInAutoMode {
    return self.heartbeat.customMode == APMPlaneAuto;
}

- (BOOL) isInGuidedMode {
    return self.heartbeat.customMode == APMPlaneGuided;
}


@end
