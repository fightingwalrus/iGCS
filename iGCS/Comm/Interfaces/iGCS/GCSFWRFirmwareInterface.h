//
//  GCSFWRFirmwareUpdateInterface.h
//  iGCS
//
//  Created by Andrew Brown on 7/16/14.
//
//

#import "CommInterface.h"

@interface GCSFWRFirmwareInterface : CommInterface
-(void)updateFwrFirmware;
@end

extern NSString * const GCSFirmewareIntefaceFirmwareUpdateSuccess;
extern NSString * const GCSFirmewareIntefaceFirmwareUpdateFail;