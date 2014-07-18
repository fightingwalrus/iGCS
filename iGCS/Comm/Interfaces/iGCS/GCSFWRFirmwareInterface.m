//
//  GCSFWRFirmwareUpdateInterface.m
//  iGCS
//
//  Created by Andrew Brown on 7/16/14.
//
//

#import "GCSFWRFirmwareInterface.h"
#import "FileUtils.h"
#import <zlib.h>

@implementation GCSFWRFirmwareInterface

-(void)consumeData:(const uint8_t*)bytes length:(int)length {
    NSData *data = [NSData dataWithBytes:bytes length:length];
    NSString *string = [[NSString alloc] initWithData:data
                                                 encoding:NSASCIIStringEncoding];

    NSLog(@"GCSFWRFirmwareInterface.consumeData: %@", string);

}

-(void)updateFwrFirmware {
    NSLog(@"updateFwrFirmware");
    NSData *firmware = [FileUtils dataFromFileInMainBundleWithName:@"walrus.bin"];
    NSUInteger firmwareLength = [firmware length];

    //Magic token
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

    NSLog(@"crc: %lu", crc);
    [self produceData:magicToken length:4];
    
    [self produceData:(uint8_t*)(UInt32)&firmwareLength length:sizeof((UInt32)firmwareLength)];
    [self produceData:(uint8_t*)digest length:4];

    unsigned char buf[firmwareLength];
    [firmware getBytes:buf length:firmwareLength];
    [self produceData:buf length:firmwareLength];
}

@end
