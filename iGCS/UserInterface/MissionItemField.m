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

- (id)initWithLabel:(NSString*)_label units:(GCSMissionItemUnit)_units andType:(MissionItemFieldType)_fieldType
{
    if ((self = [super init])) {
        label     = _label;
        units     = _units;
        fieldType = _fieldType;
    }
    return self;
}

- (id)initWithLabel:(NSString*)_label andType:(MissionItemFieldType)_fieldType
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
        case kPARAM_Z: val = item.z;      break;
        case kPARAM_1: val = item.param1; break;
        case kPARAM_2: val = item.param2; break;
        case kPARAM_3: val = item.param3; break;
        case kPARAM_4: val = item.param4; break;
        default:
            assert(false);
            break;
    }
    return [NSString stringWithFormat:@"%0.2f", val];
}

- (void)setValue:(float)val inMissionItem:(mavlink_mission_item_t*)item {
    switch (fieldType) {
        case kPARAM_Z: item->z      = val; break;
        case kPARAM_1: item->param1 = val; break;
        case kPARAM_2: item->param2 = val; break;
        case kPARAM_3: item->param3 = val; break;
        case kPARAM_4: item->param4 = val; break;
        default:
            assert(false);
            break;
    }
}

@end

