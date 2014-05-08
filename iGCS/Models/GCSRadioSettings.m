//
//  GCSRadioSettings.m
//  iGCS
//
//  Created by Andrew Brown on 5/7/14.
//
//

#import "GCSRadioSettings.h"

@implementation GCSRadioSettings
-(NSString *)description {
    NSMutableDictionary *mutableDict = [[NSMutableDictionary alloc] init];
    mutableDict[@"radioVersion"] = self.radioVersion ?: @"";
    mutableDict[@"boadType"] = self.boadType ?: @"";
    mutableDict[@"boadFrequency"] = self.boadFrequency ?: @"";
    mutableDict[@"boadVersion"] = self.boadVersion ?: @"";
    mutableDict[@"tdmTimingReport"] = self.tdmTimingReport ?: @"";
    mutableDict[@"serialSpeed"] = @(self.serialSpeed);
    mutableDict[@"airSpeed"] = @(self.airSpeed);
    mutableDict[@"netId"] = @(self.netId);
    mutableDict[@"transmitterPower"] = @(self.transmitterPower);
    mutableDict[@"isECCenabled"] = (self.isECCenabled) ? @"YES": @"NO";
    mutableDict[@"isMavlinkEnabled"] = (self.isMavlinkEnabled) ? @"YES": @"NO";
    mutableDict[@"isOppResendEnabled"] = (self.isOppResendEnabled) ? @"YES": @"NO";
    mutableDict[@"minFrequency"] = @(self.minFrequency);
    mutableDict[@"maxFrequency"] = @(self.maxFrequency);
    mutableDict[@"numberOfChannels"] = @(self.numberOfChannels);
    mutableDict[@"dutyCycle"] = @(self.dutyCycle);
    mutableDict[@"isListenBeforeTalkRSSIEnabled"] =(self.isListenBeforeTalkRSSIEnabled) ? @"YES": @"NO";
    return [mutableDict description];
}
    
@end

