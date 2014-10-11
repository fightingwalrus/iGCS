//
//  GCSFirmwareUtils.m
//  iGCS
//
//  Created by Andrew Brown on 7/18/14.
//
//

#import "GCSFirmwareUtils.h"

NSString * const GCSFirmwareUtilsFwrFirmwareNeedsUpdated = @"com.fightingwalrus.firmwareutils.fwrfirmware.needsupdate";
NSString * const GCSFwrFirmwareFileName = @"walrus.bin";
NSString * const GCSFirmwareVersionInBundle = @"1.0";

static BOOL _awaitingPostUpgradeDisconnect;

@implementation GCSFirmwareUtils

+(BOOL)isFirmwareUpdateNeededWithFirmwareRevision:(NSString *) firmwareRevision {
        return (![self awaitingPostUpgradeDisconnect] &&
                [GCSFirmwareVersionInBundle compare:firmwareRevision options:NSNumericSearch] == NSOrderedDescending);
}

+(void)notifyFwrFirmwareUpateNeeded {
    [[NSNotificationCenter defaultCenter] postNotificationName:GCSFirmwareUtilsFwrFirmwareNeedsUpdated object:nil];
}

+(BOOL)awaitingPostUpgradeDisconnect {
    return _awaitingPostUpgradeDisconnect;
}

+(void)setAwaitingPostUpgradeDisconnect:(BOOL)value {
    _awaitingPostUpgradeDisconnect = value;
}

@end
