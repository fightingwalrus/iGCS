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
    [encoder encodeInteger:self.altitude forKey:altitudeKey];
    [encoder encodeInteger:self.radius forKey:radiusKey];
    [encoder encodeInteger:self.ceiling forKey:ceilingKey];
    [encoder encodeInteger:self.unitType forKey:unitKey];
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    self = [self init];
    if (self) {
        _altitude = [decoder decodeIntegerForKey:altitudeKey];
        _radius = [decoder decodeIntegerForKey:radiusKey];
        _ceiling = [decoder decodeIntegerForKey:ceilingKey];
        _unitType = [decoder decodeIntegerForKey:unitKey];
    }
    
    return self;
}





@end
