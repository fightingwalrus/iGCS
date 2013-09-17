//
//  MissionItemField.h
//  iGCS
//
//  Created by Claudio Natoli on 11/05/13.
//
//

#import <Foundation/Foundation.h>
#import "MavLinkPacketHandler.h"

typedef NS_ENUM(NSInteger, GCSMissionItemParamField) {
    GCSItemParamZ,
    GCSItemParam1,
    GCSItemParam2,
    GCSItemParam3,
    GCSItemParam4
};

typedef NS_ENUM(NSInteger, GCSMissionItemUnit) {
    GCSItemUnitNone,
    GCSItemUnitDegrees,
    GCSItemUnitSeconds,
    GCSItemUnitMetres,
    GCSItemUnitMetresPerSecond,
    GCSItemUnitCentimetresPerSecond
};

@interface MissionItemField : NSObject

@property (readonly) NSString               *label;
@property (readonly) GCSMissionItemUnit      units;
@property (readonly) GCSMissionItemParamField fieldType;

- (id)initWithLabel:(NSString*)_label andType:(GCSMissionItemParamField)_fieldType;
- (id)initWithLabel:(NSString*)_label units:(GCSMissionItemUnit)_units andType:(GCSMissionItemParamField)_fieldType;

- (NSString*)unitsToString;
- (NSString*)valueToString:(mavlink_mission_item_t)mission_item;
- (void)setValue:(float)val inMissionItem:(mavlink_mission_item_t*)mission_item;

@end
