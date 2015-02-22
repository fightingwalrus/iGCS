//
//  GCSMissionModel.m
//  iGCS
//
//  Created by BRYAN GALUSHA on 2/16/15.
//
//

#import "GCSMissionModel.h"

@implementation GCSMissionModel

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    _missionItems = [decoder decodeObjectForKey:@"_missionItems"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.missionItems forKey:@"missionItems"];
}


@end
