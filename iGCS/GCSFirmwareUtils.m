//
//  GCSFirmwareUtils.m
//  iGCS
//
//  Created by Andrew Brown on 7/18/14.
//
//

#import "GCSFirmwareUtils.h"

NSString * const GCSFirmwareUtilsFwrFirmwareNeedsUpdated = @"com.fightingwalrus.firmwareutils.fwrfrimware.needsupdate";
NSString * const GCSFwrFirmwareFileName = @"walrus.bin";
float const GCSCurrentFirmwareVersion = 0.05;

@implementation GCSFirmwareUtils

+(BOOL)isFirmwareUpdateNeededWithFirmwareRevision:(NSString *) firmwareRevision {
    float deviceFirmwareRevision = [firmwareRevision floatValue];
    return (GCSCurrentFirmwareVersion > deviceFirmwareRevision) ? YES: NO;
}

+(void)notifyFwrFirmwareUpateNeeded {
    [[NSNotificationCenter defaultCenter] postNotificationName:GCSFirmwareUtilsFwrFirmwareNeedsUpdated object:nil];
}

@end
