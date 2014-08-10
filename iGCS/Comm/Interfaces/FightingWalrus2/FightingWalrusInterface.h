//
//  FightingWalrusInterface.h
//  iGCS
//
//  Created by Andrew Brown on 9/22/13.
//
//

#import "CommInterface.h"
#import <ExternalAccessory/ExternalAccessory.h>

@interface FightingWalrusInterface : CommInterface <EAAccessoryDelegate, NSStreamDelegate>

@property (nonatomic, strong, readwrite) EAAccessory *selectedAccessory;
@property (nonatomic, copy) NSString *protocolString;
@property (strong) NSMutableData *writeDataBuffer;

+(FightingWalrusInterface*)createWithProtocolString:(NSString *) protocolString;

- (void)setupControllerForAccessory:(EAAccessory *)accessory withProtocolString:(NSString *)protocolString;
- (BOOL)openSession;
- (void)closeSession;
- (void)writeData:(NSData *)data;
- (BOOL)isAccessoryConnected;

@end

extern NSString * const GCSProtocolStringTelemetry;
extern NSString * const GCSProtocolStringConfig;
extern NSString * const GCSProtocolStringUpdate;

