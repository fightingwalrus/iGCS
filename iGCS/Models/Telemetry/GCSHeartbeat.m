//
//  GCSHeartbeatModel.m
//  iGCS
//
//  Created by Andrew Brown on 2/20/15.
//
//

#import "GCSHeartbeat.h"

@interface GCSHeartbeat ()
@property (nonatomic, assign) mavlink_heartbeat_t heartbeat;
- (instancetype)initWithHeartbeat:(mavlink_heartbeat_t) heartbeat;
@end

@implementation GCSHeartbeat

+ (GCSHeartbeat *)heartbeatFromMavlinkHeartbeat:(mavlink_heartbeat_t)heartbeat {
    GCSHeartbeat *aHeartbeat = [[GCSHeartbeat alloc] initWithHeartbeat:heartbeat];
    return aHeartbeat;
}

- (instancetype)initWithHeartbeat:(mavlink_heartbeat_t) heartbeat {
    self = [super init];
    if (self) {
        _heartbeat = heartbeat;
    }
    return self;
}

#pragma mark - properties backed by MAVLink heartbeat struct
- (uint32_t)customMode {
    return self.heartbeat.custom_mode;
}

- (uint8_t)mavType {
    return self.heartbeat.type;
}

- (uint8_t)autopilot {
    return self.heartbeat.autopilot;
}

- (uint8_t)baseMode {
    return self.heartbeat.base_mode;
}

- (uint8_t)systemStatus {
    return self.heartbeat.base_mode;
}

- (uint8_t)telemetryVersion {
    return self.heartbeat.mavlink_version;
}

#pragma mark - compound properties
-(BOOL)isArmed {
    return (self.heartbeat.base_mode & MAV_MODE_FLAG_SAFETY_ARMED);
}

@end
