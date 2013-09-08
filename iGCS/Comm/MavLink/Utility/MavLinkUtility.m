//
//  MavLinkUtility.m
//  iGCS
//
//  Created by Claudio Natoli on 21/07/13.
//
//

#import "MavLinkUtility.h"

@implementation MavLinkUtility

+ (NSString*) mavModeEnumToString:(enum MAV_MODE)mode {
    NSString *str = [NSString stringWithFormat:@""];
    if (mode & MAV_MODE_FLAG_TEST_ENABLED)          str = [str stringByAppendingString:@"Test "];
    if (mode & MAV_MODE_FLAG_AUTO_ENABLED)          str = [str stringByAppendingString:@"Auto "];
    if (mode & MAV_MODE_FLAG_GUIDED_ENABLED)        str = [str stringByAppendingString:@"Guided "];
    if (mode & MAV_MODE_FLAG_STABILIZE_ENABLED)     str = [str stringByAppendingString:@"Stabilize "];
    if (mode & MAV_MODE_FLAG_HIL_ENABLED)           str = [str stringByAppendingString:@"HIL "];
    if (mode & MAV_MODE_FLAG_MANUAL_INPUT_ENABLED)  str = [str stringByAppendingString:@"Manual "];
    if (mode & MAV_MODE_FLAG_CUSTOM_MODE_ENABLED)   str = [str stringByAppendingString:@"Custom "];
    if (!(mode & MAV_MODE_FLAG_SAFETY_ARMED))       str = [str stringByAppendingString:@"(Disarmed)"];
    return str;
}

+ (NSString*) mavStateEnumToString:(enum MAV_STATE)state {
    switch (state) {
        case MAV_STATE_UNINIT:      return @"Uninitialized";
        case MAV_STATE_BOOT:        return @"Boot";
        case MAV_STATE_CALIBRATING: return @"Calibrating";
        case MAV_STATE_STANDBY:     return @"Standby";
        case MAV_STATE_ACTIVE:      return @"Active";
        case MAV_STATE_CRITICAL:    return @"Critical";
        case MAV_STATE_EMERGENCY:   return @"Emergency";
        case MAV_STATE_POWEROFF:    return @"Power Off";
        case MAV_STATE_ENUM_END:    break;
    }
    return [NSString stringWithFormat:@"MAV_STATE (%d)", state];
}

+ (NSString*) mavCustomModeToString:(int)customMode {
    switch (customMode) {
        case MANUAL:        return @"Manual";
        case CIRCLE:        return @"Circle";
        case STABILIZE:     return @"Stabilize";
        case FLY_BY_WIRE_A: return @"FBW_A";
        case FLY_BY_WIRE_B: return @"FBW_B";
        case FLY_BY_WIRE_C: return @"FBW_C";
        case AUTO:          return @"Auto";
        case RTL:           return @"RTL";
        case LOITER:        return @"Loiter";
        case TAKEOFF:       return @"Takeoff";
        case LAND:          return @"Land";
        case GUIDED:        return @"Guided";
        case INITIALISING:  return @"Initialising";
            
    }
    return [NSString stringWithFormat:@"CUSTOM_MODE (%d)", customMode];
}

@end
