//
//  GCSCraftModel.h
//  iGCS
//
//  Created by Andrew Brown on 1/22/15.
//
//

#import <Foundation/Foundation.h>
#import "mavlink.h"

@interface GCSCraftModel : NSObject
@property (atomic, assign) mavlink_heartbeat_t heartbeat;
@property (nonatomic, readonly) uint32_t customMode; //< A bitfield for use for autopilot-specific flags.
@property (nonatomic, readonly) uint8_t type; // MAV_TYPE ENUM
@property (nonatomic, readonly) uint8_t autopilot; // MAV_AUTOPILOT ENUM
@property (nonatomic, readonly) uint8_t baseMode; // MAV_MODE_FLAGS ENUM
@property (nonatomic, readonly) uint8_t systemStatus; // MAV_STATE

@end