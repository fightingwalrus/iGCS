//
//  GCSFirmwareUtils.h
//  iGCS
//
//  Created by Andrew Brown on 7/18/14.
//
//

#import <Foundation/Foundation.h>
#import <ExternalAccessory/ExternalAccessory.h>

@interface GCSAccessoryFirmwareUtils : NSObject
+(BOOL)isFirmwareUpdateNeededWithFirmwareRevision:(NSString *) firmwareRevision;
+(void)notifyOfFirmwareUpateNeededForAccessory:(EAAccessory *) accessory;
+(void)setAwaitingPostUpgradeDisconnect:(BOOL) value;
+(BOOL)isAccessorySupportedWithAccessory:(EAAccessory *) accessory;
@end

extern NSString * const GCSAccessoryFirmwareNeedsUpdated;
extern NSString * const GCSAccessoryCurrentFirmwareFileName;
extern NSString * const GCSAccessoryFirmwareVersionInBundle;
extern NSString * const GCSAccessoryCompanyName;