//
//  GCSFirmwareUtils.m
//  iGCS
//
//  Created by Andrew Brown on 7/18/14.
//
//

#import "GCSFirmwareUtils.h"

NSString * const GCSFirmwareUtilsFwrFirmwareNeedsUpdated = @"com.fightingwalrus.firmwareutils.fwrfirmware.needsupdate";
NSString * const GCSFirmwareVersionInBundleKey = @"GCSFirmwareVersionInBundleKey";
NSString * const GCSFwrFirmwareFileName = @"walrus.bin";
NSString * const GCSFirmwareVersionInBundle = @"0.0.5";

@implementation GCSFirmwareUtils

+(BOOL)isFirmwareUpdateNeededWithFirmwareRevision:(NSString *) firmwareRevision {
    NSString *lastUpdatedVersion = [[NSUserDefaults standardUserDefaults] objectForKey:GCSFirmwareVersionInBundleKey];

    // see if we just performed a successful update but have yet to dissconnect the device
    if ([lastUpdatedVersion compare:firmwareRevision options:NSNumericSearch] == NSOrderedDescending) {
        return NO;
    } else {
        // if not then check the bundle version against the current device firmware version
        return ([GCSFirmwareVersionInBundle compare:firmwareRevision options:NSNumericSearch] == NSOrderedDescending);
    }
}

+(void)notifyFwrFirmwareUpateNeeded {
    [[NSNotificationCenter defaultCenter] postNotificationName:GCSFirmwareUtilsFwrFirmwareNeedsUpdated object:nil];
}

+(void)resetFirmwareVersionInUserDefaults {
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:GCSFirmwareVersionInBundleKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
