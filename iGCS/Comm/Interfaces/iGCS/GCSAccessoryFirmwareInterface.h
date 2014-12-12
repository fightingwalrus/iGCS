//
//  GCSFWRFirmwareUpdateInterface.h
//  iGCS
//
//  Created by Andrew Brown on 7/16/14.
//
//

#import "CommInterface.h"

@interface GCSAccessoryFirmwareInterface : CommInterface
-(void)updateFirmware;
@end

extern NSString * const GCSAccessoryFirmwareUpdateSuccess;
extern NSString * const GCSAccessoryFirmwareUpdateFail;