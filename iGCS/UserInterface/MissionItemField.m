//
//  MissionItemField.m
//  iGCS
//
//  Created by Claudio Natoli on 11/05/13.
//
//

#import "MissionItemField.h"

@implementation MissionItemField

@synthesize label;
@synthesize units;
@synthesize fieldType;

- (id)initWithLabel:(NSString*)_label units:(GCSMissionItemUnit)_units andType:(GCSMissionItemParamField)_fieldType
{
    if ((self = [super init])) {
        label     = _label;
        units     = _units;
        fieldType = _fieldType;
    }
    return self;
}

- (id)initWithLabel:(NSString*)_label andType:(GCSMissionItemParamField)_fieldType
{
    return [self initWithLabel:_label units:GCSItemUnitNone andType:_fieldType];
}

- (NSString*)unitsToString
{
    switch (units) {
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

- (NSString*)valueToString:(mavlink_mission_item_t)item
{
    float val;
    switch (fieldType) {
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
    switch (fieldType) {
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

