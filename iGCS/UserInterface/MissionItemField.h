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

typedef NS_ENUM(NSInteger, GCSMissionItemUnit) {
    GCSItemUnitNone,
    GCSItemUnitDegrees,
    GCSItemUnitSeconds,
    GCSItemUnitMetres,
    GCSItemUnitMetresPerSecond,
    GCSItemUnitCentimetresPerSecond
};

@interface MissionItemField : NSObject

@property (readonly) NSString            *label;
@property (readonly) GCSMissionItemUnit  units;
@property (readonly) MissionItemFieldType fieldType;

- (id)initWithLabel:(NSString*)_label andType:(MissionItemFieldType)_fieldType;
- (id)initWithLabel:(NSString*)_label units:(GCSMissionItemUnit)_units andType:(MissionItemFieldType)_fieldType;

- (NSString*)unitsToString;
- (NSString*)valueToString:(mavlink_mission_item_t)mission_item;
- (void)setValue:(float)val inMissionItem:(mavlink_mission_item_t*)mission_item;

@end
