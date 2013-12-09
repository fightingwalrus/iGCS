//
//  MavLinkUtility.m
//  iGCS
//
//  Created by Claudio Natoli on 21/07/13.
//
//

#import "MavLinkUtility.h"

@implementation MavLinkUtility


NSMutableDictionary *_missionItemMetadata;

+ (void) initialize {
    if (self == [MavLinkUtility class]) {
        // Define the list of mission item meta-data
        _missionItemMetadata = [NSMutableDictionary dictionary];
        
        // NAV mission items
        [_missionItemMetadata setObject:@[[[MissionItemField alloc] initWithLabel:@"Altitude"
                                                                            andUnits:GCSItemUnitMetres
                                                                          andFieldType:GCSItemParamZ]]
                                 forKey:@(MAV_CMD_NAV_WAYPOINT)];
        [_missionItemMetadata setObject:@[[[MissionItemField alloc] initWithLabel:@"Altitude"
                                                                            andUnits:GCSItemUnitMetres
                                                                          andFieldType:GCSItemParamZ]]
                                 forKey:@(MAV_CMD_NAV_LOITER_UNLIM)];
        [_missionItemMetadata setObject:@[[[MissionItemField alloc] initWithLabel:@"Altitude"
                                                                            andUnits:GCSItemUnitMetres
                                                                          andFieldType:GCSItemParamZ],
                                          [[MissionItemField alloc] initWithLabel:@"# Turns"
                                                                          andFieldType:GCSItemParam1]]
                                 forKey:@(MAV_CMD_NAV_LOITER_TURNS)];
        [_missionItemMetadata setObject:@[[[MissionItemField alloc] initWithLabel:@"Altitude"
                                                                            andUnits:GCSItemUnitMetres
                                                                          andFieldType:GCSItemParamZ],
                                          // FIXME: test this - older docs say (seconds*10), code suggests it is in seconds
                                          [[MissionItemField alloc] initWithLabel:@"Time"
                                                                            andUnits:GCSItemUnitSeconds
                                                                          andFieldType:GCSItemParam1]]
                                 forKey:@(MAV_CMD_NAV_LOITER_TIME)];
        [_missionItemMetadata setObject:@[[[MissionItemField alloc] initWithLabel:@"Altitude"
                                                                            andUnits:GCSItemUnitMetres
                                                                          andFieldType:GCSItemParamZ]]
                                 forKey:@(MAV_CMD_NAV_RETURN_TO_LAUNCH)];
        [_missionItemMetadata setObject:@[[[MissionItemField alloc] initWithLabel:@"Altitude"
                                                                            andUnits:GCSItemUnitMetres
                                                                          andFieldType:GCSItemParamZ]]
                                 forKey:@(MAV_CMD_NAV_LAND)];
        [_missionItemMetadata setObject:@[[[MissionItemField alloc] initWithLabel:@"Altitude"
                                                                            andUnits:GCSItemUnitMetres
                                                                          andFieldType:GCSItemParamZ],
                                          [[MissionItemField alloc] initWithLabel:@"Takeoff Pitch"
                                                                            andUnits:GCSItemUnitDegrees
                                                                          andFieldType:GCSItemParam1]]
                                 forKey:@(MAV_CMD_NAV_TAKEOFF)];
        
        // Conditional CMD mission items
        [_missionItemMetadata setObject:@[[[MissionItemField alloc] initWithLabel:@"Time"
                                                                            andUnits:GCSItemUnitSeconds
                                                                          andFieldType:GCSItemParam3]]
                                 forKey:@(MAV_CMD_CONDITION_DELAY)];
        [_missionItemMetadata setObject:@[[[MissionItemField alloc] initWithLabel:@"Rate"
                                                                            andUnits:GCSItemUnitCentimetresPerSecond
                                                                          andFieldType:GCSItemParam1],
                                          [[MissionItemField alloc] initWithLabel:@"Final Altitude"
                                                                            andUnits:GCSItemUnitMetres
                                                                          andFieldType:GCSItemParam2]]
                                 forKey:@(MAV_CMD_CONDITION_CHANGE_ALT)];
        [_missionItemMetadata setObject:@[[[MissionItemField alloc] initWithLabel:@"Distance"
                                                                            andUnits:GCSItemUnitMetres
                                                                          andFieldType:GCSItemParam3]]
                                 forKey:@(MAV_CMD_CONDITION_DISTANCE)];
        
        // DO CMD mission items
        [_missionItemMetadata setObject:@[[[MissionItemField alloc] initWithLabel:@"Index" andFieldType:GCSItemParam1],
                                          [[MissionItemField alloc] initWithLabel:@"Repeat Count" andFieldType:GCSItemParam3]]
                                 forKey:@(MAV_CMD_DO_JUMP)];
        [_missionItemMetadata setObject:@[[[MissionItemField alloc] initWithLabel:@"Speed type"
                                                                          andFieldType:GCSItemParam1],
                                          [[MissionItemField alloc] initWithLabel:@"Speed"
                                                                            andUnits:GCSItemUnitMetresPerSecond
                                                                          andFieldType:GCSItemParam2],
                                          [[MissionItemField alloc] initWithLabel:@"Throttle (%)"
                                                                          andFieldType:GCSItemParam3]]
                                 forKey:@(MAV_CMD_DO_CHANGE_SPEED)];
        
        /* FIXME: review implementation of do_set_home - appears that lat/lon/alt are from x/y/z a(nd not param2/3/4 as per earlier doc)
         [_missionItemMetadata setObject:@[
         [[MissionItemField alloc] initWithLabel:@"Use current" andFieldType:GCSItemParam1],
         [[MissionItemField alloc] initWithLabel:@"Altitude"    andFieldType:GCSItemParam2],
         [[MissionItemField alloc] initWithLabel:@"Latitude"    andFieldType:GCSItemParam3],
         [[MissionItemField alloc] initWithLabel:@"Longitude"   andFieldType:GCSItemParam4]]
         forKey:@(MAV_CMD_DO_SET_HOME)];
         */
        
        /*
         [_missionItemMetadata setObject:@[
         [[MissionItemField alloc] initWithLabel:@"Param #" andFieldType:GCSItemParam1],
         [[MissionItemField alloc] initWithLabel:@"Param Value" andFieldType:GCSItemParam2]]
         forKey:@(MAV_CMD_DO_SET_PARAMETER)];
         */
        [_missionItemMetadata setObject:@[[[MissionItemField alloc] initWithLabel:@"Relay #" andFieldType:GCSItemParam1],
                                          [[MissionItemField alloc] initWithLabel:@"On/Off" andFieldType:GCSItemParam2]]
                                 forKey:@(MAV_CMD_DO_SET_RELAY)];
        [_missionItemMetadata setObject:@[[[MissionItemField alloc] initWithLabel:@"Relay #"
                                                                          andFieldType:GCSItemParam1],
                                          [[MissionItemField alloc] initWithLabel:@"Cycle count"
                                                                          andFieldType:GCSItemParam2],
                                          [[MissionItemField alloc] initWithLabel:@"Cycle time"
                                                                            andUnits:GCSItemUnitSeconds
                                                                          andFieldType:GCSItemParam3]]
                                 forKey:@(MAV_CMD_DO_REPEAT_RELAY)];
        
        [_missionItemMetadata setObject:@[[[MissionItemField alloc] initWithLabel:@"Servo # (5-8)" andFieldType:GCSItemParam1],
                                          [[MissionItemField alloc] initWithLabel:@"On/Off" andFieldType:GCSItemParam2]]
                                 forKey:@(MAV_CMD_DO_SET_SERVO)];
        
        [_missionItemMetadata setObject:@[[[MissionItemField alloc] initWithLabel:@"Servo # (5-8)"
                                                                          andFieldType:GCSItemParam1],
                                          [[MissionItemField alloc] initWithLabel:@"Cycle count"
                                                                          andFieldType:GCSItemParam2],
                                          [[MissionItemField alloc] initWithLabel:@"Cycle time"
                                                                            andUnits:GCSItemUnitSeconds
                                                                          andFieldType:GCSItemParam3]]
                                 forKey:@(MAV_CMD_DO_REPEAT_SERVO)];
    }
}

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

+ (NSString*) mavCustomModeToString:(mavlink_heartbeat_t) heartbeat {

    // ArduPlane Auto Pilot Modes
    NSString *modeName;
    if (heartbeat.autopilot == MAV_AUTOPILOT_ARDUPILOTMEGA && heartbeat.type == MAV_TYPE_FIXED_WING) {
        static NSDictionary *ardupilotmegaFixedwing;
        if (!ardupilotmegaFixedwing) {
            ardupilotmegaFixedwing = @{@(MANUAL): @"Manual",
                                       @(CIRCLE): @"Circle",
                                       @(STABILIZE): @"Stabilize",
                                       @(FLY_BY_WIRE_A): @"FBW_A",
                                       @(FLY_BY_WIRE_B): @"FBW_B",
                                       @(FLY_BY_WIRE_C): @"FBW_C",
                                       @(AUTO): @"Auto",
                                       @(RTL): @"RTL",
                                       @(LOITER): @"Loiter",
                                       @(TAKEOFF): @"Takeoff",
                                       @(LAND): @"Land",
                                       @(GUIDED): @"Guided",
                                       @(INITIALISING): @"Initialising"};
        }
        modeName = ardupilotmegaFixedwing[@(heartbeat.custom_mode)];
        if (modeName) {
            return modeName;
        }
    }

    // ArduCopter Auto Pilot Modes
    if (heartbeat.autopilot == MAV_AUTOPILOT_ARDUPILOTMEGA && heartbeat.type == MAV_TYPE_QUADROTOR) {
        static NSDictionary *ardupilotmegaQuadrotor;
        if (!ardupilotmegaQuadrotor) {
            ardupilotmegaQuadrotor = @{@(Stabilize): @"Stabilize",
                                     @(Acro): @"Acro",
                                     @(AltHold): @"AltHold",
                                     @(Auto): @"Auto",
                                     @(Guided): @"Guided",
                                     @(Loiter): @"Loiter",
                                     @(Rtl): @"RTL",
                                     @(Circle): @"Circle",
                                     @(Position): @"Position",
                                     @(Land): @"Land",
                                     @(OfLoiter): @"OfLoiter",
                                     @(Drift): @"Drift",
                                     @(Sport): @"Sport"};
        }
        modeName = ardupilotmegaQuadrotor[@(heartbeat.custom_mode)];
        if (modeName) {
            return modeName;
        }
    }

   return [NSString stringWithFormat:@"CUSTOM_MODE (%d)", heartbeat.custom_mode];
}


+ (NSArray*) supportedMissionItemTypes {
    return [[_missionItemMetadata allKeys] sortedArrayUsingSelector: @selector(compare:)];
}

+ (NSArray*) missionItemMetadataWith:(uint16_t)command {
    return _missionItemMetadata[@(command)];
}

@end
