//
//  FirmwareUploader.m
//  iGCS
//
//  Objective-C re-mplementation of the SiK Firmware uploader.py https://github.com/tridge/SiK/blob/master/Firmware/tools/uploader.py
//
//  Created by Claudio Natoli on 14/05/2014.
//
//

#import "SiKFirmwareUploader.h"

@interface BootLoader : NSObject
@property (nonatomic) BYTE identifier;
@property (nonatomic) BYTE frequency;
- (instancetype) initWithIdentifier: (uint8_t)identity andFrequency:(uint8_t)freq NS_DESIGNATED_INITIALIZER;
@end

@implementation BootLoader : NSObject
- (instancetype) initWithIdentifier: (uint8_t)identifier andFrequency:(uint8_t)frequency {
    self = [super init];
    if (self) {
        _identifier = identifier;
        _frequency  = frequency;
    }
    return self;
}
@end


typedef NS_ENUM(BYTE, FWUCommandResponse) {
 	FWU_NOP         = 0x00,
	FWU_OK          = 0x10,
	FWU_FAILED		= 0x11,
	FWU_INSYNC		= 0x12,
	FWU_EOC         = 0x20,
	FWU_GET_SYNC    = 0x21,
	FWU_GET_DEVICE	= 0x22,
	FWU_CHIP_ERASE	= 0x23,
	FWU_LOAD_ADDRESS = 0x24,
	FWU_PROG_FLASH	= 0x25,
	FWU_READ_FLASH	= 0x26,
	FWU_PROG_MULTI	= 0x27,
	FWU_READ_MULTI	= 0x28,
	FWU_PARAM_ERASE	= 0x29,
	FWU_REBOOT		= 0x30
};

#define PROG_MULTI_MAX  32
#define READ_MULTI_MAX 255


@interface SiKFirmwareUploader () // Hide port property in class extension
@property (nonatomic, readonly) id<SikFirmwareUploaderPort> port;
@end

@implementation SiKFirmwareUploader

- (instancetype) initWithPort: (id<SikFirmwareUploaderPort>)port {
    self = [super init];
    if (self) {
        _port = port;
    }
    return self;
}

- (BOOL) getSync {
    FWUCommandResponse e = [self.port recv];
    if (e != FWU_INSYNC)
        @throw([NSException exceptionWithName:NSPortReceiveException
                                       reason:[NSString stringWithFormat:@"unexpected 0x%x instead of INSYNC", e]
                                     userInfo:nil]);
    
    e = [self.port recv];
    if (e != FWU_OK)
        @throw([NSException exceptionWithName:NSPortReceiveException
                                       reason:[NSString stringWithFormat:@"unexpected 0x%x instead of OK", e]
                                     userInfo:nil]);
    
    return YES;
}


- (BOOL) sendCommand:(FWUCommandResponse)c withData:(NSData*)data andGetSync:(BOOL)sync {
    // Send the command
    [self.port send:c];
    
    // Send any data
    for (NSUInteger i = 0; data && i < [data length]; i++) {
        [self.port send:((BYTE*)data.bytes)[i]];
    }
    
    // Send the EOC and optionally re-sync
    [self.port send:FWU_EOC];
    return (sync ? [self getSync] : YES);
}

- (BOOL) sendCommand:(FWUCommandResponse)c withGetSync:(BOOL)sync {
    return [self sendCommand:c withData:nil andGetSync:sync];
}


// attempt to get back into sync with the bootloader
- (BOOL) sync {
    // send a stream of ignored bytes longer than the longest possible conversation
    // that we might still have in progress
    for (NSUInteger i = 0; i < (PROG_MULTI_MAX + 2); i++) {
        [self.port send:FWU_NOP];
    }
    [self.port flushInput];
    
    return [self sendCommand:FWU_GET_SYNC withGetSync:YES];
}


// send the CHIP_ERASE command and wait for the bootloader to become ready
- (void) eraseWithReset:(BOOL) resetToDefaults {
    [self sendCommand:FWU_CHIP_ERASE withGetSync:YES];
    if (resetToDefaults) {
        [self sendCommand:FWU_PARAM_ERASE withGetSync:YES];
    }
}

// send a LOAD_ADDRESS command
- (void) setAddress:(uint16_t)address {
    BYTE data[2] = {address & 0xff, address >> 8};
    [self sendCommand:FWU_LOAD_ADDRESS
             withData:[NSData dataWithBytes:data length:2]
           andGetSync:YES];
}

// send a PROG_FLASH command to program one byte
- (void) program:(BYTE)b {
    [self sendCommand:FWU_PROG_FLASH
             withData:[NSData dataWithBytes:&b length:1]
           andGetSync:YES];
}

// send a PROG_MULTI command to write a collection of bytes
- (void) programMulti:(NSData*)data {
    NSUInteger n = data.length;
    assert(n < 256);
    
    // Add the length of data to the front of data
    BYTE b = n;
    NSMutableData *lenPrefixedData = [NSMutableData dataWithCapacity:(n + 1)];
    [lenPrefixedData appendBytes:&b length:1];
    [lenPrefixedData appendData:data];
    
    [self sendCommand:FWU_PROG_MULTI
             withData:lenPrefixedData
           andGetSync:YES];
}

// verify a byte in flash
- (BOOL) verify:(BYTE)b {
    [self.port send:FWU_READ_FLASH];
    [self.port send:FWU_EOC];
    if ([self.port recv] != b) {
        return NO;
    }
    [self getSync];
    return YES;
}

// verify multiple bytes in flash
- (BOOL) verifyMulti:(NSData*)data {
    NSUInteger n = data.length;
    assert(n < 256);
    
    // Request n bytes
    BYTE b = n;
    [self sendCommand:FWU_READ_MULTI
             withData:[NSData dataWithBytes:&b length:1]
           andGetSync:NO];

    // Read and check n bytes
    for (NSUInteger i = 0; i < n; i++) {
        if ([self.port recv] != ((BYTE*)data.bytes)[i]) {
            return NO;
        }
    }
    
    [self getSync];
    return YES;
}


// send the reboot command
// Note: from the reference implementation, it appears that EOC and getSync are not required for a reboot
- (void) reboot {
    [self.port send:FWU_REBOOT];
}

typedef void (^FWUChunkFn)(NSUInteger, NSData*);

- (void) operateOverFW:(SiKFirmware*)fw inChunksOf:(NSUInteger)chunkSize withFn:(FWUChunkFn)fn {
    for (AddressDataPair *adp in [fw sortedAddressDataPairs]) {
        assert(adp.address < 65536);
        
        // Set the address
        [self setAddress:(uint16_t)adp.address];
        
        // For each address, call the fn with chunks of size chunkSize
        NSUInteger n = adp.data.length;
        for (NSUInteger i = 0; i < n; i += chunkSize) {
            NSUInteger len = MIN(n - i, chunkSize);
            NSData *chunk = [adp.data subdataWithRange:NSMakeRange(i, len)];
            
            fn(adp.address, chunk);
        }
    }
}

- (void) programFW:(SiKFirmware*)fw {
    FWUChunkFn fn = ^void(NSUInteger address, NSData *chunk) {
        [self programMulti:chunk];
    };
    [self operateOverFW:fw inChunksOf:PROG_MULTI_MAX withFn:fn];
}

- (void) verifyFW:(SiKFirmware*)fw {
    FWUChunkFn fn = ^void(NSUInteger address, NSData *chunk) {
        if (![self verifyMulti:chunk]) {
            @throw([NSException exceptionWithName:NSGenericException
                                           reason:[NSString stringWithFormat:@"Verification failed in group at 0x%x", address]
                                         userInfo:nil]);
        }
    };
    [self operateOverFW:fw inChunksOf:READ_MULTI_MAX withFn:fn];
}

- (BOOL) autoSync {
    // TODO: implement me
    return NO;
}


- (BOOL) check {
    for (NSUInteger i = 0; i < 3; i++) {
        @try {
            if ([self sync]) {
                return YES;
            }
            [self autoSync];
        }
        @catch (NSException *exception) {
            [self autoSync];
        }
    }
    return NO;
}

- (BootLoader*) identify {
    [self sendCommand:FWU_GET_DEVICE withGetSync:NO];
    uint8_t ident = [self.port recv];
    uint8_t freq = [self.port recv];
    return [[BootLoader alloc] initWithIdentifier:ident andFrequency:freq];
}

- (void) upload:(SiKFirmware*)fw withResetToDefaults:(BOOL)resetToDefaults {
    [self eraseWithReset:resetToDefaults];
    [self programFW:fw];
    [self verifyFW:fw];
    [self reboot];
}


+ (BOOL) uploadFirmware:(SiKFirmware*)fw  port:(id<SikFirmwareUploaderPort>)port resetToDefault:(BOOL)resetToDefaults {
    // Construct the uploader
    SiKFirmwareUploader *uploader = [[SiKFirmwareUploader alloc] initWithPort:port];
    if (![uploader check]) {
        // TODO: output some status, or specific condition?
        return NO;
    }
    
    // TODO: output logging of identified boot loader
    BootLoader *bt = [uploader identify];
    
    // Perform the upload
    // TODO: trap exceptions, return NO/failure cases?
    [uploader upload:fw withResetToDefaults:resetToDefaults];
    return YES;
}

@end
