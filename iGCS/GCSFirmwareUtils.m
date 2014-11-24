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
NSString * const GCSFirmwareVersionInBundle = @"1.0.6";
NSString * const GCSCompanyName = @"Fighting Walrus, LLC";

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

+(BOOL)isSupportedAccessoryWithAccessory:(EAAccessory *)accessory {
    NSCharacterSet *charactersToRemove = [[NSCharacterSet alphanumericCharacterSet] invertedSet];

    NSString *accessoryManufactuer = [[[accessory.manufacturer componentsSeparatedByCharactersInSet:charactersToRemove]
                                      componentsJoinedByString:@""] lowercaseString];

    NSString *companyName = [[[GCSCompanyName componentsSeparatedByCharactersInSet:charactersToRemove]
                             componentsJoinedByString:@""] lowercaseString];

    return [accessoryManufactuer isEqualToString:companyName];
}

@end
