//
//  FirmwareUploader.h
//  iGCS
//
//  Created by Claudio Natoli on 14/05/2014.
//
//

#import <Foundation/Foundation.h>

@class Firmware; // temp forward declaration

@interface FirmwareUploader : NSObject

+ (BOOL) uploadFirmware:(Firmware*)fw  port:(NSInteger)port baud:(NSInteger)baud resetToDefault:(BOOL)resetToDefaults;

@end
