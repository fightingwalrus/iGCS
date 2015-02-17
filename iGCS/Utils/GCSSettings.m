//
//  GCSSettings.m
//  iGCS
//
//  Created by David Leskowicz on 2/14/15.
//
//

#import "GCSSettings.h"
#import "FileUtils.h"
#import "GCSDatamanager.h"

@implementation GCSSettings

static NSString* const altitudeKey = @"altitudeKey";
static NSString* const radiusKey = @"radiusKey";
static NSString* const ceilingKey = @"ceilingKey";
static NSString* const unitKey = @"unitKey";


- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeDouble:self.altitude forKey:altitudeKey];
    [encoder encodeDouble:self.radius forKey:radiusKey];
    [encoder encodeDouble:self.ceiling forKey:ceilingKey];
    [encoder encodeInteger:self.unitType forKey:unitKey];
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    self = [self init];
    if (self) {
        _altitude = [decoder decodeDoubleForKey:altitudeKey];
        _radius = [decoder decodeDoubleForKey:radiusKey];
        _ceiling = [decoder decodeDoubleForKey:ceilingKey];
        _unitType = [decoder decodeIntegerForKey:unitKey];
    }
    
    return self;
}





@end
