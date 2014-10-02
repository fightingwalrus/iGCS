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
        cmdIDToStringDict = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"Home", @0,
                             // Remainder taken from enum MAV_CMD in mavlink-include/common/common.h
                             //
                             @"Waypoint", @16, /* Navigate to waypoint. |Hold time in decimal seconds. (ignored by fixed wing, time to stay at waypoint for rotary wing)| Acceptance radius in meters (if the sphere with this radius is hit, the waypoint counts as reached)| 0 to pass through the WP, if > 0 radius in meters to pass by WP. Positive value for clockwise orbit, negative value for counter-clockwise orbit. Allows trajectory control.| Desired yaw angle at waypoint (rotary wing)| Latitude| Longitude| Altitude|  */
                             @"Loiter (unlimited)", @17, /* Loiter around this waypoint an unlimited amount of time |Empty| Empty| Radius around waypoint, in meters. If positive loiter clockwise, else counter-clockwise| Desired yaw angle.| Latitude| Longitude| Altitude|  */
                             @"Loiter (# turns)", @18, /* Loiter around this waypoint for X turns |Turns| Empty| Radius around waypoint, in meters. If positive loiter clockwise, else counter-clockwise| Desired yaw angle.| Latitude| Longitude| Altitude|  */
                             @"Loiter (timed)", @19, /* Loiter around this waypoint for X seconds |Seconds (decimal)| Empty| Radius around waypoint, in meters. If positive loiter clockwise, else counter-clockwise| Desired yaw angle.| Latitude| Longitude| Altitude|  */
                             @"RTL", @20, /* Return to launch location |Empty| Empty| Empty| Empty| Empty| Empty| Empty|  */
                             @"Land", @21, /* Land at location |Empty| Empty| Empty| Desired yaw angle.| Latitude| Longitude| Altitude|  */
                             @"Takeoff", @22, /* Takeoff from ground / hand |Minimum pitch (if airspeed sensor present), desired pitch without sensor| Empty| Empty| Yaw angle (if magnetometer present), ignored without magnetometer| Latitude| Longitude| Altitude|  */
                             @"ROI", @80, /* Sets the region of interest (ROI) for a sensor set or the
                                           vehicle itself. This can then be used by the vehicles control
                                           system to control the vehicle attitude and the attitude of various
                                           sensors such as cameras. |Region of intereset mode. (see MAV_ROI enum)| Waypoint index/ target ID. (see MAV_ROI enum)| ROI index (allows a vehicle to manage multiple ROI's)| Empty| x the location of the fixed ROI (see MAV_FRAME)| y| z|  */
                             @"PATHPLANNING", @81, /* Control autonomous path planning on the MAV. |0: Disable local obstacle avoidance / local path planning (without resetting map), 1: Enable local path planning, 2: Enable and reset local path planning| 0: Disable full path planning (without resetting map), 1: Enable, 2: Enable and reset map/occupancy grid, 3: Enable and reset planned route, but not occupancy grid| Empty| Yaw angle at goal, in compass degrees, [0..360]| Latitude/X of goal| Longitude/Y of goal| Altitude/Z of goal|  */
                             @"LAST", @95, /* NOP - This command is only used to mark the upper limit of the NAV/ACTION commands in the enumeration |Empty| Empty| Empty| Empty| Empty| Empty| Empty|  */
                             @"COND Delay", @112, /* Delay mission state machine. |Delay in seconds (decimal)| Empty| Empty| Empty| Empty| Empty| Empty|  */
                             @"COND Change Alt.", @113, /* Ascend/descend at rate.  Delay mission state machine until desired altitude reached. |Descent / Ascend rate (m/s)| Empty| Empty| Empty| Empty| Empty| Finish Altitude|  */
                             @"COND Distance", @114, /* Delay mission state machine until within desired distance of next NAV point. |Distance (meters)| Empty| Empty| Empty| Empty| Empty| Empty|  */
                             @"COND_YAW", @115, /* Reach a certain target angle. |target angle: [0-360, 0 is north| speed during yaw change:[deg per second]| direction: negative: counter clockwise, positive: clockwise [-1,1]| relative offset or absolute angle: [ 1,0]| Empty| Empty| Empty|  */
                             @"COND_LAST", @159, /* NOP - This command is only used to mark the upper limit of the CONDITION commands in the enumeration |Empty| Empty| Empty| Empty| Empty| Empty| Empty|  */
                             @"DO_SET_MODE", @176, /* Set system mode. |Mode, as defined by ENUM MAV_MODE| Empty| Empty| Empty| Empty| Empty| Empty|  */
                             @"DO Jump", @177, /* Jump to the desired command in the mission list.  Repeat this action only the specified number of times |Sequence number| Repeat count| Empty| Empty| Empty| Empty| Empty|  */
                             @"DO Change Speed", @178, /* Change speed and/or throttle set points. |Speed type (0=Airspeed, 1=Ground Speed)| Speed  (m/s, -1 indicates no change)| Throttle  ( Percent, -1 indicates no change)| Empty| Empty| Empty| Empty|  */
                             @"DO Set Home", @179, /* Changes the home location either to the current location or a specified location. |Use current (1=use current location, 0=use specified location)| Empty| Empty| Empty| Latitude| Longitude| Altitude|  */
                             @"DO_SET_PARAMETER", @180, /* Set a system parameter.  Caution!  Use of this command requires knowledge of the numeric enumeration value of the parameter. |Parameter number| Parameter value| Empty| Empty| Empty| Empty| Empty|  */
                             @"DO Set Relay", @181, /* Set a relay to a condition. |Relay number| Setting (1=on, 0=off, others possible depending on system hardware)| Empty| Empty| Empty| Empty| Empty|  */
                             @"DO Repeat Relay", @182, /* Cycle a relay on and off for a desired number of cyles with a desired period. |Relay number| Cycle count| Cycle time (seconds, decimal)| Empty| Empty| Empty| Empty|  */
                             @"DO Set Servo", @183, /* Set a servo to a desired PWM value. |Servo number| PWM (microseconds, 1000 to 2000 typical)| Empty| Empty| Empty| Empty| Empty|  */
                             @"DO Repeat Servo", @184, /* Cycle a between its nominal setting and a desired PWM for a desired number of cycles with a desired period. |Servo number| PWM (microseconds, 1000 to 2000 typical)| Cycle count| Cycle time (seconds)| Empty| Empty| Empty|  */
                             @"DO_CONTROL_VIDEO", @200, /* Control onboard camera system. |Camera ID (-1 for all)| Transmission: 0: disabled, 1: enabled compressed, 2: enabled raw| Transmission mode: 0: video stream, >0: single images every n seconds (decimal)| Recording: 0: disabled, 1: enabled compressed, 2: enabled raw| Empty| Empty| Empty|  */
                             @"DO_LAST", @240, /* NOP - This command is only used to mark the upper limit of the DO commands in the enumeration |Empty| Empty| Empty| Empty| Empty| Empty| Empty|  */
                             @"PREFLIGHT_CALIBRATION", @241, /* Trigger calibration. This command will be only accepted if in pre-flight mode. |Gyro calibration: 0: no, 1: yes| Magnetometer calibration: 0: no, 1: yes| Ground pressure: 0: no, 1: yes| Radio calibration: 0: no, 1: yes| Empty| Empty| Empty|  */
                             @"PREFLIGHT_STORAGE", @245, /* Request storage of different parameter values and logs. This command will be only accepted if in pre-flight mode. |Parameter storage: 0: READ FROM FLASH/EEPROM, 1: WRITE CURRENT TO FLASH/EEPROM| Mission storage: 0: READ FROM FLASH/EEPROM, 1: WRITE CURRENT TO FLASH/EEPROM| Reserved| Reserved| Empty| Empty| Empty|  */
                             @"ENUM_END", @246, /*  | */ 
                             nil];
    });

    return cmdIDToStringDict;
}

+ (NSString*) commandIDToString:(uint8_t)cmdID {
    NSString *str = [[WaypointHelper commandIDToStringDict] objectForKey:@(cmdID)];
    return str ?: [NSString stringWithFormat:@"Unknown<%d>", cmdID];
}

+ (NSString*) navWaypointToDetailString:(mavlink_mission_item_t)waypoint {
    NSString *str = [NSString stringWithFormat:@"Alt: %0.2fm\n", waypoint.z];
    switch (waypoint.command) {
        case MAV_CMD_NAV_WAYPOINT:
        case MAV_CMD_NAV_LOITER_UNLIM:
            break;
            
        case MAV_CMD_NAV_LOITER_TURNS:
            str = [str stringByAppendingFormat:@"\nNum Turns: %d\n", (int)waypoint.param1];
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
