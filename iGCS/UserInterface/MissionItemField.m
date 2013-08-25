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

- (id)initWithLabel:(NSString*)_label units:(MissionItemUnits)_units andType:(MissionItemFieldType)_fieldType
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
    return [self initWithLabel:_label units:kUNIT_NONE andType:_fieldType];
}

- (NSString*)unitsToString
{
    switch (units) {
        case kUNIT_NONE: return @"";
        case kUNIT_DEG:  return @"degrees";
        case kUNIT_S:    return @"s";
        case kUNIT_M:    return @"m";
        case kUNIT_M_S:  return @"m/s";
        case kUNIT_CM_S: return @"cm/s";
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

@end

