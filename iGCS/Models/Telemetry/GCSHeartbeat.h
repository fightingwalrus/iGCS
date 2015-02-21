//
//  GCSHeartbeatModel.h
//  iGCS
//
//  Created by Andrew Brown on 2/20/15.
//
//

#import <Foundation/Foundation.h>
#import "mavlink.h"

@interface GCSHeartbeat : NSObject
+(GCSHeartbeat *) heartbeatFromMavlinkHeartbeat:(mavlink_heartbeat_t)heartbeat;
// basic pass through properties from backing struct
@property (nonatomic, readonly) uint32_t customMode;
@property (nonatomic, readonly) uint8_t mavType;
@property (nonatomic, readonly) uint8_t autopilot;
@property (nonatomic, readonly) uint8_t baseMode;
@property (nonatomic, readonly) uint8_t systemStatus;
@property (nonatomic, readonly) uint8_t telemetryVersion;
@property (nonatomic, readonly) BOOL isArmed;
@end