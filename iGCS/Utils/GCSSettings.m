//
//  GCSSettings.m
//  iGCS
//
//  Created by David Leskowicz on 2/14/15.
//
//

#import "GCSSettings.h"
#import "GCSDatamanager.h"

@implementation GCSSettings

static NSString* const altitudeKey = @"altitudeKey";
static NSString* const radiusKey = @"radiusKey";
static NSString* const ceilingKey = @"ceilingKey";
static NSString* const unitKey = @"unitKey";
static NSString* const audioAlertKey = @"audioAlertKey"; // 0 = off, 1 = on

- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeDouble:self.altitude forKey:altitudeKey];
    [encoder encodeDouble:self.radius forKey:radiusKey];
    [encoder encodeDouble:self.ceiling forKey:ceilingKey];
    [encoder encodeInteger:self.unitType forKey:unitKey];
    [encoder encodeBool:self.audioAlertStatus forKey:audioAlertKey];
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    self = [self init];
    if (self) {
        _altitude = [decoder decodeDoubleForKey:altitudeKey];
        _radius = [decoder decodeDoubleForKey:radiusKey];
        _ceiling = [decoder decodeDoubleForKey:ceilingKey];
        _unitType = [decoder decodeIntegerForKey:unitKey];
        _audioAlertStatus = [decoder decodeBoolForKey:audioAlertKey];
    }
    return self;
}

@end
