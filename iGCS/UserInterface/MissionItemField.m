//
//  MissionItemField.m
//  iGCS
//
//  Created by Claudio Natoli on 11/05/13.
//
//

#import "MissionItemField.h"

@implementation MissionItemField

- (id)initWithLabel:(NSString*)aLabel andUnits:(GCSMissionItemUnit)units andFieldType:(GCSMissionItemParamField)fieldType {
    if ((self = [super init])) {
        _label     = aLabel;
        _units     = units;
        _fieldType = fieldType;
    }
    return self;
}

- (id)initWithLabel:(NSString*)aLabel andFieldType:(GCSMissionItemParamField)fieldType {
    return [self initWithLabel:aLabel andUnits:GCSItemUnitNone andFieldType:fieldType];
}

- (NSString*)unitsToString {
    switch (_units) {
        case GCSItemUnitNone:                 return @"";
        case GCSItemUnitDegrees:              return @"degrees";
        case GCSItemUnitSeconds:              return @"s";
        case GCSItemUnitMetres:               return @"m";
        case GCSItemUnitMetresPerSecond:      return @"m/s";
        case GCSItemUnitCentimetresPerSecond: return @"cm/s";
        default:
            assert(false);
            break;
    }
}

- (NSString*)valueToString:(mavlink_mission_item_t)item {
    float val;
    switch (_fieldType) {
        case GCSItemParamZ: val = item.z;      break;
        case GCSItemParam1: val = item.param1; break;
        case GCSItemParam2: val = item.param2; break;
        case GCSItemParam3: val = item.param3; break;
        case GCSItemParam4: val = item.param4; break;
        default:
            assert(false);
            break;
    }
    return [NSString stringWithFormat:@"%0.2f", val];
}

- (void)setValue:(float)val inMissionItem:(mavlink_mission_item_t*)item {
    switch (_fieldType) {
        case GCSItemParamZ: item->z      = val; break;
        case GCSItemParam1: item->param1 = val; break;
        case GCSItemParam2: item->param2 = val; break;
        case GCSItemParam3: item->param3 = val; break;
        case GCSItemParam4: item->param4 = val; break;
        default:
            assert(false);
            break;
    }
}

@end

