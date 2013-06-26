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
@synthesize fieldType;

- (id)initWithLabel:(NSString*)_label andType:(MissionItemFieldType)_fieldType
{
    if ((self = [super init])) {
        label       = _label;
        fieldType   = _fieldType;
    }
    return self;
}

@end

