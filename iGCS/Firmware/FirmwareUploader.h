//
//  FirmwareUploader.h
//  iGCS
//
//  Created by Claudio Natoli on 14/05/2014.
//
//

#import <Foundation/Foundation.h>
#import "SiKFirmware.h"

@interface FirmwareUploader : NSObject

+ (BOOL) uploadFirmware:(SiKFirmware*)fw  port:(NSInteger)port baud:(NSInteger)baud resetToDefault:(BOOL)resetToDefaults;

@end
