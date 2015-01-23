//
//  GCSCraftModel.m
//  iGCS
//
//  Created by Andrew Brown on 1/22/15.
//
//

#import "GCSCraftModel.h"

@implementation GCSCraftModel

-(uint32_t) customMode {
    return self.heartbeat.custom_mode;
}

-(uint8_t) type {
    return self.heartbeat.type;
} // MAV_TYPE ENUM

-(uint8_t) autopilot {
    return self.heartbeat.autopilot;
} // MAV_AUTOPILOT ENUM

-(uint8_t) baseMode {
    return self.heartbeat.base_mode;
} // MAV_MODE_FLAGS ENUM

-(uint8_t) systemStatus {
    return self.heartbeat.system_status;
} // MAV_STATE

@end
