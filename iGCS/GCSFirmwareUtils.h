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
+(void)resetFirmwareVersionInUserDefaults;
@end

extern NSString * const GCSFirmwareUtilsFwrFirmwareNeedsUpdated;
extern NSString * const GCSCurrentFirmwareFileName;
extern NSString * const GCSFirmwareVersionInBundle;
extern NSString * const GCSFirmwareVersionInBundleKey;