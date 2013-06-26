//
//  MissionItemField.h
//  iGCS
//
//  Created by Claudio Natoli on 11/05/13.
//
//

#import <Foundation/Foundation.h>

typedef enum {
    kPARAM_Z,
    kPARAM_1,
    kPARAM_2,
    kPARAM_3,
    kPARAM_4
} MissionItemFieldType;

@interface MissionItemField : NSObject

@property (readonly) NSString *label;
@property (readonly) MissionItemFieldType fieldType;

- (id)initWithLabel:(NSString*)_label andType:(MissionItemFieldType)_fieldType;

@end
