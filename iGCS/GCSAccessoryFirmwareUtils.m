//
//  GCSFirmwareUtils.m
//  iGCS
//
//  Created by Andrew Brown on 7/18/14.
//
//

#import "GCSAccessoryFirmwareUtils.h"

NSString * const GCSAccessoryFirmwareNeedsUpdated = @"com.fightingwalrus.accessoryfirmwareutils.firmware.needsupdated";
NSString * const GCSAccessoryCurrentFirmwareFileName = @"walrus.bin";
NSString * const GCSAccessoryFirmwareVersionInBundle = @"1.0.8";
NSString * const GCSAccessoryCompanyName = @"Fighting Walrus, LLC";

static BOOL _awaitingPostUpgradeDisconnect;

@implementation GCSAccessoryFirmwareUtils

+(BOOL)isFirmwareUpdateNeededWithFirmwareRevision:(NSString *) firmwareRevision {
        return (![self awaitingPostUpgradeDisconnect] &&
                [GCSAccessoryFirmwareVersionInBundle compare:firmwareRevision options:NSNumericSearch] == NSOrderedDescending);
}

+(void)notifyOfFirmwareUpateNeededWithModelNumber:(NSString *) modelNumber {
    dispatch_async(dispatch_get_main_queue(),^{
         [[NSNotificationCenter defaultCenter] postNotificationName:GCSAccessoryFirmwareNeedsUpdated object:modelNumber];
    });
}

+(BOOL)awaitingPostUpgradeDisconnect {
    return _awaitingPostUpgradeDisconnect;
}

+(void)setAwaitingPostUpgradeDisconnect:(BOOL)value {
    _awaitingPostUpgradeDisconnect = value;
}

+(BOOL)isAccessorySupportedWithAccessory:(EAAccessory *)accessory {
    NSCharacterSet *nonAlphaCharacterSet = [[NSCharacterSet alphanumericCharacterSet] invertedSet];

    NSString *accessoryManufactuer = [[[accessory.manufacturer componentsSeparatedByCharactersInSet:nonAlphaCharacterSet]
                                      componentsJoinedByString:@""] lowercaseString];

    NSString *companyName = [[[GCSAccessoryCompanyName componentsSeparatedByCharactersInSet:nonAlphaCharacterSet]
                             componentsJoinedByString:@""] lowercaseString];

    return [accessoryManufactuer isEqualToString:companyName];
}

@end
