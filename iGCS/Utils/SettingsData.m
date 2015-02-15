//
//  SettingsData.m
//  iGCS
//
//  Created by David Leskowicz on 2/14/15.
//
//

#import "SettingsData.h"
#import "FileUtils.h"

@implementation SettingsData

static NSString* const altitudeKey = @"altitudeKey";
static NSString* const radiusKey = @"radiusKey";
static NSString* const ceilingKey = @"ceilingKey";
static NSString* const unitKey = @"unitKey";


- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeDouble:self.altitude forKey:altitudeKey];
    [encoder encodeDouble:self.radius forKey:radiusKey];
    [encoder encodeDouble:self.ceiling forKey:ceilingKey];
    [encoder encodeDouble:self.unitType forKey:unitKey];
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    self = [self init];
    if (self) {
        _altitude = [decoder decodeDoubleForKey:altitudeKey];
        _radius = [decoder decodeDoubleForKey:radiusKey];
        _ceiling = [decoder decodeDoubleForKey:ceilingKey];
        _unitType = [decoder decodeDoubleForKey:unitKey];
    }
    
    return self;
}


+(instancetype)loadInstance {
    NSData *decodedData = [NSData dataWithContentsOfFile:[SettingsData filePath]];
    if (decodedData) {
        SettingsData *progData = [NSKeyedUnarchiver unarchiveObjectWithData:decodedData];
        return progData;
    }
    
    return [[SettingsData alloc] init];
}


- (void) save {
    NSData* encodeData = [NSKeyedArchiver archivedDataWithRootObject:self];
    [encodeData writeToFile:[SettingsData filePath] atomically:YES];
}


+(NSString*)filePath
{
    static NSString* filePath = nil;
    if (!filePath) {
        filePath =
        [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
         stringByAppendingPathComponent:@"settingsdata"];
    }
    return filePath;
}


+(instancetype)sharedSettingsData {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
        sharedInstance = [self loadInstance];
    });
    
    return sharedInstance;
}



-(void) resetDefaults {
    self.altitude = 100;
    self.radius = 100;
    self.ceiling = 100;
    self.unitType = metric;
}


@end
