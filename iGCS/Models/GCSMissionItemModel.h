//
//  GCSMissionItemModel.h
//  iGCS
//
//  Created by BRYAN GALUSHA on 2/16/15.
//
//

#import <Foundation/Foundation.h>

@interface GCSMissionItemModel : NSObject <NSCoding>
/*
 
 typedef struct __mavlink_mission_item_t
 {
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

@property(nonatomic, strong) NSNumber *param1;
@property(nonatomic, strong) NSNumber *param2;
@property(nonatomic, strong) NSNumber *param3;
@property(nonatomic, strong) NSNumber *param4;
@property(nonatomic, strong) NSNumber *x;
@property(nonatomic, strong) NSNumber *y;
@property(nonatomic, strong) NSNumber *z;
@property(nonatomic, strong) NSNumber *seq;
@property(nonatomic, strong) NSNumber *command;
@property(nonatomic, strong) NSNumber *target_system;
@property(nonatomic, strong) NSNumber *target_component;
@property(nonatomic, strong) NSNumber *frame;
@property(nonatomic, strong) NSNumber *current;
@property(nonatomic, strong) NSNumber *autocontinue;

@end
