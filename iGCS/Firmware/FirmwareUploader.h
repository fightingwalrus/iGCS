//
//  FirmwareUploader.h
//  iGCS
//
//  Created by Claudio Natoli on 14/05/2014.
//
//

#import <Foundation/Foundation.h>
#import "SiKFirmware.h"

typedef unsigned char BYTE;

@protocol FirmwareUploaderPort <NSObject>
- (BOOL) send:(BYTE)c;  // Send a single byte down the port
- (BYTE) recv;          // Receive a single byte from the port. Per reference implementation, should throw exception on "timeout"
- (void) flushInput;    // Flush the port
@end


@interface FirmwareUploader : NSObject
+ (BOOL) uploadFirmware:(SiKFirmware*)fw  port:(id<FirmwareUploaderPort>)port resetToDefault:(BOOL)resetToDefaults;
@end
