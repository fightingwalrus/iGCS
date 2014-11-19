//
//  WaypointHelper.m
//  iGCS
//
//  Created by Claudio Natoli on 1/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WaypointHelper.h"

@implementation WaypointHelper

+ (NSDictionary*) commandIDToStringDict {
    static dispatch_once_t once;
    static NSDictionary *cmdIDToStringDict = nil;
    
    dispatch_once(&once, ^{
        cmdIDToStringDict = @{@0: @"Home",
                             // Remainder taken from enum MAV_CMD in mavlink-include/common/common.h
                             //
                             @16: @"Waypoint", /* Navigate to waypoint. |Hold time in decimal seconds. (ignored by fixed wing, time to stay at waypoint for rotary wing)| Acceptance radius in meters (if the sphere with this radius is hit, the waypoint counts as reached)| 0 to pass through the WP, if > 0 radius in meters to pass by WP. Positive value for clockwise orbit, negative value for counter-clockwise orbit. Allows trajectory control.| Desired yaw angle at waypoint (rotary wing)| Latitude| Longitude| Altitude|  */
                             @17: @"Loiter (unlimited)", /* Loiter around this waypoint an unlimited amount of time |Empty| Empty| Radius around waypoint, in meters. If positive loiter clockwise, else counter-clockwise| Desired yaw angle.| Latitude| Longitude| Altitude|  */
                             @18: @"Loiter (# turns)", /* Loiter around this waypoint for X turns |Turns| Empty| Radius around waypoint, in meters. If positive loiter clockwise, else counter-clockwise| Desired yaw angle.| Latitude| Longitude| Altitude|  */
                             @19: @"Loiter (timed)", /* Loiter around this waypoint for X seconds |Seconds (decimal)| Empty| Radius around waypoint, in meters. If positive loiter clockwise, else counter-clockwise| Desired yaw angle.| Latitude| Longitude| Altitude|  */
                             @20: @"RTL", /* Return to launch location |Empty| Empty| Empty| Empty| Empty| Empty| Empty|  */
                             @21: @"Land", /* Land at location |Empty| Empty| Empty| Desired yaw angle.| Latitude| Longitude| Altitude|  */
                             @22: @"Takeoff", /* Takeoff from ground / hand |Minimum pitch (if airspeed sensor present), desired pitch without sensor| Empty| Empty| Yaw angle (if magnetometer present), ignored without magnetometer| Latitude| Longitude| Altitude|  */
                             @80: @"ROI", /* Sets the region of interest (ROI) for a sensor set or the
                                           vehicle itself. This can then be used by the vehicles control
                                           system to control the vehicle attitude and the attitude of various
                                           sensors such as cameras. |Region of intereset mode. (see MAV_ROI enum)| Waypoint index/ target ID. (see MAV_ROI enum)| ROI index (allows a vehicle to manage multiple ROI's)| Empty| x the location of the fixed ROI (see MAV_FRAME)| y| z|  */
                             @81: @"PATHPLANNING", /* Control autonomous path planning on the MAV. |0: Disable local obstacle avoidance / local path planning (without resetting map), 1: Enable local path planning, 2: Enable and reset local path planning| 0: Disable full path planning (without resetting map), 1: Enable, 2: Enable and reset map/occupancy grid, 3: Enable and reset planned route, but not occupancy grid| Empty| Yaw angle at goal, in compass degrees, [0..360]| Latitude/X of goal| Longitude/Y of goal| Altitude/Z of goal|  */
                             @95: @"LAST", /* NOP - This command is only used to mark the upper limit of the NAV/ACTION commands in the enumeration |Empty| Empty| Empty| Empty| Empty| Empty| Empty|  */
                             @112: @"COND Delay", /* Delay mission state machine. |Delay in seconds (decimal)| Empty| Empty| Empty| Empty| Empty| Empty|  */
                             @113: @"COND Change Alt.", /* Ascend/descend at rate.  Delay mission state machine until desired altitude reached. |Descent / Ascend rate (m/s)| Empty| Empty| Empty| Empty| Empty| Finish Altitude|  */
                             @114: @"COND Distance", /* Delay mission state machine until within desired distance of next NAV point. |Distance (meters)| Empty| Empty| Empty| Empty| Empty| Empty|  */
                             @115: @"COND_YAW", /* Reach a certain target angle. |target angle: [0-360, 0 is north| speed during yaw change:[deg per second]| direction: negative: counter clockwise, positive: clockwise [-1,1]| relative offset or absolute angle: [ 1,0]| Empty| Empty| Empty|  */
                             @159: @"COND_LAST", /* NOP - This command is only used to mark the upper limit of the CONDITION commands in the enumeration |Empty| Empty| Empty| Empty| Empty| Empty| Empty|  */
                             @176: @"DO_SET_MODE", /* Set system mode. |Mode, as defined by ENUM MAV_MODE| Empty| Empty| Empty| Empty| Empty| Empty|  */
                             @177: @"DO Jump", /* Jump to the desired command in the mission list.  Repeat this action only the specified number of times |Sequence number| Repeat count| Empty| Empty| Empty| Empty| Empty|  */
                             @178: @"DO Change Speed", /* Change speed and/or throttle set points. |Speed type (0=Airspeed, 1=Ground Speed)| Speed  (m/s, -1 indicates no change)| Throttle  ( Percent, -1 indicates no change)| Empty| Empty| Empty| Empty|  */
                             @179: @"DO Set Home", /* Changes the home location either to the current location or a specified location. |Use current (1=use current location, 0=use specified location)| Empty| Empty| Empty| Latitude| Longitude| Altitude|  */
                             @180: @"DO_SET_PARAMETER", /* Set a system parameter.  Caution!  Use of this command requires knowledge of the numeric enumeration value of the parameter. |Parameter number| Parameter value| Empty| Empty| Empty| Empty| Empty|  */
                             @181: @"DO Set Relay", /* Set a relay to a condition. |Relay number| Setting (1=on, 0=off, others possible depending on system hardware)| Empty| Empty| Empty| Empty| Empty|  */
                             @182: @"DO Repeat Relay", /* Cycle a relay on and off for a desired number of cyles with a desired period. |Relay number| Cycle count| Cycle time (seconds, decimal)| Empty| Empty| Empty| Empty|  */
                             @183: @"DO Set Servo", /* Set a servo to a desired PWM value. |Servo number| PWM (microseconds, 1000 to 2000 typical)| Empty| Empty| Empty| Empty| Empty|  */
                             @184: @"DO Repeat Servo", /* Cycle a between its nominal setting and a desired PWM for a desired number of cycles with a desired period. |Servo number| PWM (microseconds, 1000 to 2000 typical)| Cycle count| Cycle time (seconds)| Empty| Empty| Empty|  */
                             @200: @"DO_CONTROL_VIDEO", /* Control onboard camera system. |Camera ID (-1 for all)| Transmission: 0: disabled, 1: enabled compressed, 2: enabled raw| Transmission mode: 0: video stream, >0: single images every n seconds (decimal)| Recording: 0: disabled, 1: enabled compressed, 2: enabled raw| Empty| Empty| Empty|  */
                             @240: @"DO_LAST", /* NOP - This command is only used to mark the upper limit of the DO commands in the enumeration |Empty| Empty| Empty| Empty| Empty| Empty| Empty|  */
                             @241: @"PREFLIGHT_CALIBRATION", /* Trigger calibration. This command will be only accepted if in pre-flight mode. |Gyro calibration: 0: no, 1: yes| Magnetometer calibration: 0: no, 1: yes| Ground pressure: 0: no, 1: yes| Radio calibration: 0: no, 1: yes| Empty| Empty| Empty|  */
                             @245: @"PREFLIGHT_STORAGE", /* Request storage of different parameter values and logs. This command will be only accepted if in pre-flight mode. |Parameter storage: 0: READ FROM FLASH/EEPROM, 1: WRITE CURRENT TO FLASH/EEPROM| Mission storage: 0: READ FROM FLASH/EEPROM, 1: WRITE CURRENT TO FLASH/EEPROM| Reserved| Reserved| Empty| Empty| Empty|  */
                             @246: @"ENUM_END"};
    });

    return cmdIDToStringDict;
}

+ (NSString*) commandIDToString:(uint8_t)cmdID {
    NSString *str = [WaypointHelper commandIDToStringDict][@(cmdID)];
    return str ?: [NSString stringWithFormat:@"Unknown<%d>", cmdID];
}

+ (NSString*) navWaypointToDetailString:(mavlink_mission_item_t)waypoint {
    NSString *str = [NSString stringWithFormat:@"Alt: %0.2fm\n", waypoint.z];
    switch (waypoint.command) {
        case MAV_CMD_NAV_WAYPOINT:
        case MAV_CMD_NAV_LOITER_UNLIM:
            break;
            
        case MAV_CMD_NAV_LOITER_TURNS:
            str = [str stringByAppendingFormat:@"\nNum Turns: %ld\n", (long)waypoint.param1];
            break;
            
        case MAV_CMD_NAV_LOITER_TIME:
            str = [str stringByAppendingFormat:@"Time: %0.2fs\n", waypoint.param1];
            break;
            
    }
    return str;
}

+ (BOOL) isNavCommand:(mavlink_mission_item_t)waypoint {
    return (waypoint.command < MAV_CMD_NAV_LAST);
}

@end
