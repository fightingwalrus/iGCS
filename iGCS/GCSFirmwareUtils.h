//
//  GCSFirmwareUtils.h
//  iGCS
//
//  Created by Andrew Brown on 7/18/14.
//
//

#import <Foundation/Foundation.h>

@interface GCSFirmwareUtils : NSObject
+(BOOL)isFirmwareUpdateNeededWithFirmwareRevision:(NSString *) firmwareRevision;
+(void)notifyFwrFirmwareUpateNeeded;
+(void)setAwaitingPostUpgradeDisconnect:(BOOL)value;
@end

extern NSString * const GCSFirmwareUtilsFwrFirmwareNeedsUpdated;
extern NSString * const GCSCurrentFirmwareFileName;
extern NSString * const GCSFirmwareVersionInBundle;