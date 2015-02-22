//
//  GCSCraftArduCopter.m
//  iGCS
//
//  Created by Claudio Natoli on 24/01/2015.
//
//

#import "TelemetryManagers.h"
#import "GCSCraftArduCopter.h"
#import "GCSCraftNotifications.h"
#import "MavLinkUtility.h"
#import "GCSCraftMixins.h"
#import "Mixin.h"


@interface GCSCraftArduCopter ()
@property (nonatomic, strong) NSNotificationCenter *notificationCenter;
@property (nonatomic, strong) NSOperationQueue *craftQueue;
@end

@implementation GCSCraftArduCopter

@synthesize craftType  = _craftType;
@synthesize autoMode   = _autoMode;
@synthesize guidedMode = _guidedMode;
@synthesize setModeBeforeGuidedItems  = _setModeBeforeGuidedItems;
@synthesize icon = _icon;

- (id<GCSCraftModel>) init:(GCSHeartbeat*)heartbeat {
    self = [super init];
    if (self) {
        _heartbeat = heartbeat;
        
        _craftType   = ArduCopter;
        _autoMode    = APMCopterAuto;
        _guidedMode  = APMCopterGuided;
        _setModeBeforeGuidedItems = YES; // For 3.2+
        _icon = [UIImage imageNamed:@"quad-icon-128.png"];
        _notificationCenter = [NSNotificationCenter defaultCenter];

        // set heartbeat to nil when app goes into background so all
        // events fire again on app launch and telemetry reconnect
        __weak GCSCraftArduCopter *weakSelf = self;
        [self.notificationCenter addObserverForName:UIApplicationDidEnterBackgroundNotification
                                             object:nil
                                              queue:self.craftQueue
                                         usingBlock:^(NSNotification *note) {
                                             [weakSelf clearHearbeat];
                                         }];

        // set heartbeat to nil when app loses telemetry for a period of time
        [self.notificationCenter addObserverForName:GCSHeartbeatManagerHeartbeatWasLost
                                             object:nil
                                              queue:self.craftQueue
                                         usingBlock:^(NSNotification *note) {
                                             [weakSelf clearHearbeat];
                                         }];
    }

    return self;
}

- (void)dealloc {
    [self.notificationCenter removeObserver:self];
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
    return self.heartbeat.customMode == APMCopterAuto;
}

- (BOOL) isInGuidedMode {
    return self.heartbeat.customMode == APMCopterGuided;
}

@end
