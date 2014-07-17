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

    NSData *firmware = [FileUtils dataFromFileInMainBundleWithName:@"walrus.bin"];
    NSUInteger firmwareLength = [firmware length];

    //Magic token
    const unsigned char *magicToken = 0xAA/0xBB/0xCC/0xDD;


    // init crc
    __block uLong crc = crc32(0L, Z_NULL, 0);

    [firmware enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        crc = crc32(crc, bytes, (uInt)byteRange.length);
    }];

    [self produceData:magicToken length:4];
    [self produceData:(uint8_t*)firmwareLength length:sizeof(firmwareLength)];
    [self produceData:(uint8_t*)crc length:4];

    void *buf = NULL;
    [firmware getBytes:buf length:firmware.length];
    [self produceData:buf length:firmware.length];
}

@end
