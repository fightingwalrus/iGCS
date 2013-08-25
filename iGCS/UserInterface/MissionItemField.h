//
//  MissionItemField.h
//  iGCS
//
//  Created by Claudio Natoli on 11/05/13.
//
//

#import <Foundation/Foundation.h>
#import "MavLinkPacketHandler.h"

typedef enum {
    kPARAM_Z,
    kPARAM_1,
    kPARAM_2,
    kPARAM_3,
    kPARAM_4
} MissionItemFieldType;

typedef enum {
    kUNIT_NONE,
    kUNIT_DEG,
    kUNIT_S,
    kUNIT_M,
    kUNIT_M_S,
    kUNIT_CM_S
} MissionItemUnits;

@interface MissionItemField : NSObject

@property (readonly) NSString         *label;
@property (readonly) MissionItemUnits  units;
@property (readonly) MissionItemFieldType fieldType;

- (id)initWithLabel:(NSString*)_label andType:(MissionItemFieldType)_fieldType;
- (id)initWithLabel:(NSString*)_label units:(MissionItemUnits)_units andType:(MissionItemFieldType)_fieldType;

- (NSString*)unitsToString;
- (NSString*)valueToString:(mavlink_mission_item_t)mission_item;
- (void)setValue:(float)val inMissionItem:(mavlink_mission_item_t*)mission_item;

@end
