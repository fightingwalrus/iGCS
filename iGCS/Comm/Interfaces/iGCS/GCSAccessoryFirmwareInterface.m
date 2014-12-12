//
//  GCSFWRFirmwareUpdateInterface.m
//  iGCS
//
//  Created by Andrew Brown on 7/16/14.
//
//

#import "GCSAccessoryFirmwareInterface.h"
#import  "GCSAccessoryFirmwareUtils.h"
#import "FileUtils.h"
#import <zlib.h>
#import "CommController.h"

NSString * const GCSAccessoryFirmwareUpdateSuccess = @"com.fightingwalrus.fwrfirmware.updatesuccess";
NSString * const GCSAccessoryFirmwareUpdateFail = @"com.fightingwalrus.fwrfirmware.updatefail";

@implementation GCSAccessoryFirmwareInterface

-(void)consumeData:(const uint8_t*)bytes length:(NSUInteger)length {

    NSData *data = [NSData dataWithBytes:bytes length:length];
    NSString *response = [[NSString alloc] initWithData:data
                                                 encoding:NSASCIIStringEncoding];

    NSAssert([response isEqualToString:@"SUCCESS"] || [response isEqualToString:@"FAIL"],
             @"Response from firmware update attempt must be either SUCCESS or FAIL");

    if ([response rangeOfString:@"SUCCESS"].location != NSNotFound) {
        DDLogInfo(@"FWR Firmware updaded successfully");

        NSArray * connectedAccessories = [EAAccessoryManager sharedAccessoryManager].connectedAccessories;
        EAAccessory *supportedConnectedAccessory;
        for (EAAccessory *accessory in connectedAccessories) {
            if ([GCSAccessoryFirmwareUtils isAccessorySupportedWithAccessory:accessory]) {
                supportedConnectedAccessory = accessory;
                break;
            }
        }

        [GCSAccessoryFirmwareUtils setAwaitingPostUpgradeDisconnect:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:GCSAccessoryFirmwareUpdateSuccess
                                                            object:supportedConnectedAccessory];

    }else if ([response rangeOfString:@"FAIL"].location !=NSNotFound) {
        DDLogWarn(@"FWR Firmware failed to update");
        [[NSNotificationCenter defaultCenter] postNotificationName:GCSAccessoryFirmwareUpdateFail object:nil];
    }
}

-(void) close {
    DDLogDebug(@"GCSAccessoryFirmwareInterface.close is a noop");
}

-(void)updateFirmware {
    DDLogDebug(@"updateFwrFirmware");
    NSData *firmware = [FileUtils dataFromFileInMainBundleWithName:@"walrus.bin"];

    if (!firmware) {
        [[NSNotificationCenter defaultCenter] postNotificationName:GCSAccessoryFirmwareUpdateFail object:nil];
        return;
    }

    const unsigned char magicToken[4] = {0xAA,0xBB,0xCC,0xDD};

    // init crc
    __block uLong crc = crc32(0L, Z_NULL, 0);

    [firmware enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        crc = crc32(crc, bytes, (uInt)byteRange.length);
    }];

    // turn our crc long to char
    unsigned char digest[4];
    digest[0] = (crc >> 24) & 0xFF;
    digest[1] = (crc >> 16) & 0xFF;
    digest[2] = (crc >> 8) & 0xFF;
    digest[3] = crc & 0xFF;

    DDLogVerbose(@"crc: %lu", crc);

    NSUInteger firmwareLength = [firmware length];

    [self produceData:magicToken length:4];
    [self produceData:(uint8_t*)(UInt32)&firmwareLength length:sizeof((UInt32)firmwareLength)];
    [self produceData:(uint8_t*)digest length:4];

    unsigned char buf[firmwareLength];
    [firmware getBytes:buf length:firmwareLength];
    [self produceData:buf length:firmwareLength];
}

@end
