//
//  GCSMissionItemModel.m
//  iGCS
//
//  Created by BRYAN GALUSHA on 2/16/15.
//
//

#import "GCSMissionItemModel.h"


@implementation GCSMissionItemModel


/*
float param1; ///< PARAM1, see MAV_CMD enum
float param2; ///< PARAM2, see MAV_CMD enum
float param3; ///< PARAM3, see MAV_CMD enum
float param4; ///< PARAM4, see MAV_CMD enum
float x; ///< PARAM5 / local: x position, global: latitude
float y; ///< PARAM6 / y position: global: longitude
float z; ///< PARAM7 / z position: global: altitude (relative or absolute, depending on frame.
uint16_t seq; ///< Sequence
uint16_t command; ///< The scheduled action for the MISSION. see MAV_CMD in common.xml MAVLink specs
uint8_t target_system; ///< System ID
uint8_t target_component; ///< Component ID
uint8_t frame; ///< The coordinate system of the MISSION. see MAV_FRAME in mavlink_types.h
uint8_t current; ///< false:0, true:1
uint8_t autocontinue; ///< autocontinue to next wp
} mavlink_mission_item_t;
 */

-(void)missionItemFromMavlink:(mavlink_mission_item_t) mavMissionItem {
    _param1 = [NSNumber numberWithFloat:mavMissionItem.param1];
    _param2 = [NSNumber numberWithFloat:mavMissionItem.param2];
    _param3 = [NSNumber numberWithFloat:mavMissionItem.param3];
    _param4 = [NSNumber numberWithFloat:mavMissionItem.param4];
    _x = [NSNumber numberWithFloat:mavMissionItem.x];
    _y = [NSNumber numberWithFloat:mavMissionItem.y];
    _z = [NSNumber numberWithFloat:mavMissionItem.z];
    _seq = [NSNumber numberWithUnsignedInteger:mavMissionItem.seq];
    _command = [NSNumber numberWithUnsignedInteger:mavMissionItem.command];
    _target_system = [NSNumber numberWithUnsignedInteger:mavMissionItem.target_system];
    _target_component = [NSNumber numberWithUnsignedInteger:mavMissionItem.target_component];
    _frame = [NSNumber numberWithUnsignedInteger:mavMissionItem.frame];
    _current = [NSNumber numberWithBool:mavMissionItem.current];
    _autocontinue = [NSNumber numberWithUnsignedInteger:mavMissionItem.autocontinue];
        
}


-(mavlink_mission_item_t)missionItemToMavlink {
    mavlink_mission_item_t missionItem;
    missionItem.param1 = [_param1 floatValue];
    missionItem.param2 = [_param2 floatValue];
    missionItem.param3 = [_param3 floatValue];
    missionItem.param4 = [_param4 floatValue];
    missionItem.x = [_x floatValue];
    missionItem.y = [_y floatValue];
    missionItem.z = [_z floatValue];
    missionItem.seq = [_seq unsignedIntegerValue];
    missionItem.command = [_command unsignedIntegerValue];
    missionItem.target_system = [_target_system unsignedIntegerValue];
    missionItem.target_component = [_target_component unsignedIntegerValue];
    missionItem.frame = [_frame unsignedIntegerValue];
    missionItem.current = [_current unsignedIntegerValue];
    missionItem.autocontinue = [_autocontinue unsignedIntegerValue];

    return missionItem;
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _param1 = [decoder decodeObjectForKey:@"param1"];
    _param2 = [decoder decodeObjectForKey:@"param2"];
    _param3 = [decoder decodeObjectForKey:@"param3"];
    _param4 = [decoder decodeObjectForKey:@"param4"];
    _x = [decoder decodeObjectForKey:@"x"];
    _y = [decoder decodeObjectForKey:@"y"];
    _z = [decoder decodeObjectForKey:@"z"];
    _seq = [decoder decodeObjectForKey:@"seq"];
    _command = [decoder decodeObjectForKey:@"command"];
    _target_system = [decoder decodeObjectForKey:@"target_system"];
    _target_component = [decoder decodeObjectForKey:@"target_component"];
    _frame = [decoder decodeObjectForKey:@"frame"];
    _current = [decoder decodeObjectForKey:@"current"];
    _autocontinue = [decoder decodeObjectForKey:@"autocontinue"];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.param1 forKey:@"param1"];
    [encoder encodeObject:self.param2 forKey:@"param2"];
    [encoder encodeObject:self.param1 forKey:@"param3"];
    [encoder encodeObject:self.param1 forKey:@"param4"];
    [encoder encodeObject:self.x forKey:@"x"];
    [encoder encodeObject:self.y forKey:@"y"];
    [encoder encodeObject:self.z forKey:@"z"];
    [encoder encodeObject:self.seq forKey:@"seq"];
    [encoder encodeObject:self.command forKey:@"command"];
    [encoder encodeObject:self.target_system forKey:@"target_system"];
    [encoder encodeObject:self.target_component forKey:@"target_component"];
    [encoder encodeObject:self.frame forKey:@"frame"];
    [encoder encodeObject:self.current forKey:@"current"];
    [encoder encodeObject:self.autocontinue forKey:@"autocontinue"];

}


//-(void)setP





@end
