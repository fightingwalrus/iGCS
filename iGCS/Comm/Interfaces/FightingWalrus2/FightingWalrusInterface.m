//
//  FightingWalrusInterface.m
//  iGCS
//
//  Created by Andrew Brown on 9/22/13.
//
//

#import "FightingWalrusInterface.h"
#import "GCSAccessoryFirmwareInterface.h"
#import "GCSAccessoryFirmwareUtils.h"

NSString * const GCSProtocolStringTelemetry = @"com.fightingwalrus.telemetry";
NSString * const GCSProtocolStringConfig = @"com.fightingwalrus.config";
NSString * const GCSProtocolStringUpdate = @"com.fightingwalrus.update";

@interface FightingWalrusInterface ()
@property (nonatomic, strong) NSMutableArray *accessoryList;
@property (nonatomic, strong) EASession *session;
@property (nonatomic, strong) NSString *enabledAccessoryProtocol;
@property (nonatomic, strong) NSArray *supportedAccessoryProtocols;
@end

@implementation FightingWalrusInterface

+(FightingWalrusInterface*)createWithProtocolString:(NSString *) protocolString {
    FightingWalrusInterface *fightingWalrusInterface = [[FightingWalrusInterface alloc] initWithProtocolString:protocolString];

    if (fightingWalrusInterface.selectedAccessory) {
        [fightingWalrusInterface openSession];

        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [fightingWalrusInterface notifyIfFirmwareUpdateNeeded];
        });

        return fightingWalrusInterface;
    } else {
        return nil;
    }
}

#pragma mark Public Methods

- (instancetype)initWithProtocolString:(NSString *) protocolString {
    if (self = [super init]) {
        // Custom initialization
        _writeDataBuffer = [[NSMutableData alloc] init];
        _accessoryList = [[NSMutableArray alloc] initWithArray:[[EAAccessoryManager sharedAccessoryManager] connectedAccessories]];
        _supportedAccessoryProtocols = @[GCSProtocolStringTelemetry, GCSProtocolStringConfig, GCSProtocolStringUpdate];
        _enabledAccessoryProtocol = protocolString;

        DDLogInfo(@"accessory count: %lu", (unsigned long)[_accessoryList count]);
        if ([self.accessoryList count]) {
            for(EAAccessory *currentAccessory in _accessoryList) {
                BOOL comparison = [GCSAccessoryFirmwareUtils isAccessorySupportedWithAccessory:currentAccessory];
                if(comparison){
                    self.selectedAccessory = currentAccessory;
                    DDLogDebug(@"Manufacturer of our device is %@",_selectedAccessory.manufacturer);
                    break;
                }
            }

            NSArray *protocolStrings = [self.selectedAccessory protocolStrings];
            self.protocolString = [self enabledProtocolFromProtocolStrings:protocolStrings];
            DDLogDebug(@"protocolString: %@", self.protocolString);
        }
    }

    return self;
}

- (EAAccessory *)selectedAccessory {
    if (!_selectedAccessory) {
        self.accessoryList = [[NSMutableArray alloc] initWithArray:[[EAAccessoryManager sharedAccessoryManager] connectedAccessories]];
        if ([self.accessoryList count]) {
            _selectedAccessory = (self.accessoryList)[0];
            NSArray *protocolStrings = [self.selectedAccessory protocolStrings];
            self.protocolString = [self enabledProtocolFromProtocolStrings:protocolStrings];;
        }
    }
    return _selectedAccessory;
}

- (void)setupControllerForAccessory:(EAAccessory *)accessory withProtocolString:(NSString *)protocolString {
	DDLogInfo(@"FightingWalrusInterface: setupControllerForAccessory:");
    self.selectedAccessory = accessory;
    self.protocolString = [protocolString copy];
}

- (BOOL)openSession {
	if (!self.session) {
        DDLogInfo(@"FightingWalrusInterface: openSession");
        [self.selectedAccessory setDelegate:self];
        self.session = [[EASession alloc] initWithAccessory:[self selectedAccessory] forProtocol:_protocolString];

        if (self.session) {
            [[self.session inputStream] setDelegate:self];
            [[self.session inputStream] scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            [[self.session inputStream] open];
            
            [[self.session outputStream] setDelegate:self];
            [[self.session outputStream] scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            [[self.session outputStream] open];
            DDLogInfo(@"opened the session");
        } else{
            DDLogError(@"creating session failed");
        }
    }

    return (self.session != nil);
}

- (void)closeSession {
	DDLogInfo(@"FightingWalrusInterface: closeSession");
    [[self.session inputStream] close];
    [[self.session inputStream] removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [[self.session inputStream] setDelegate:nil];
    [[self.session outputStream] close];
    [[self.session outputStream] removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [[self.session outputStream] setDelegate:nil];
    
    self.session = nil;
	DDLogInfo(@"closed the session");
}

-(void)close {
    [self closeSession];
}

- (void)writeData:(NSData *)data {
    [self.writeDataBuffer appendData:data];
    [self writeDataFromBufferToStream];
}

- (BOOL)isAccessoryConnected {
    DDLogDebug(@"FightingWalrusInterface: isAccessoryConnected");
    return (self.selectedAccessory && [self.selectedAccessory isConnected]);
}


#pragma mark -
#pragma mark EAAccessoryDelegate

- (void)accessoryDidDisconnect:(EAAccessory *)accessory {
	DDLogInfo(@"FightingWalrusInterface: accessoryDidDisconnect:");
    [self closeSession];
}


#pragma mark -
#pragma mark NSStreamDelegateEventExtensions

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
	DDLogVerbose(@"FightingWalrusInterface :handleEvent:");
    switch (eventCode) {
        case NSStreamEventNone:
            DDLogVerbose(@"stream %@ event none", aStream);
            break;
        case NSStreamEventOpenCompleted:
            DDLogVerbose(@"stream %@ event open completed", aStream);
            break;
        case NSStreamEventHasBytesAvailable:
            DDLogVerbose(@"stream %@ event bytes available", aStream);
            [self readDataFromStreamToBuffer];
            break;
        case NSStreamEventHasSpaceAvailable:
            DDLogVerbose(@"stream %@ event space available", aStream);
            [self writeDataFromBufferToStream];
            break;
        case NSStreamEventErrorOccurred:
            DDLogVerbose(@"stream %@ event error", aStream);
            break;
        case NSStreamEventEndEncountered:
            DDLogVerbose(@"stream %@ event end encountered", aStream);
            break;
        default:
            break;
    }
}

#pragma mark -
#pragma mark NSNotifications

- (void)accessoryConnected:(NSNotification *)notification {
    DDLogInfo(@"FightingWalrusInterface: accessoryConnected: notification Name: %@",notification.name);
    DDLogInfo(@"Notification: %@",notification.userInfo);
    if (![self isAccessoryConnected]) {
            EAAccessory *a = [self selectedAccessory];
            [self setupControllerForAccessory:a withProtocolString:_protocolString];
            [self openSession];
    }
}

- (void)accessoryDisconnected:(NSNotification *)notification {
    DDLogInfo(@"FightingWalrusInterface: accessoryDisconnected: notification Name: %@",notification.name);
}

#pragma mark - dissconnect session
-(void)configureAndOpenAccessory {
    if (![self isAccessoryConnected]) {
        EAAccessory *a = [self selectedAccessory];
        [self setupControllerForAccessory:a withProtocolString:self.protocolString];
        [self openSession];
    }
}

-(void)disconnectSession {
    [GCSAccessoryFirmwareUtils setAwaitingPostUpgradeDisconnect:NO];
    if (![self isAccessoryConnected]){
		[self closeSession];
    }
}

#pragma mark -
#pragma mark - CommInterfaceProtocol

-(void)consumeData:(const uint8_t *)bytes length:(NSUInteger)length {
    NSData *dataToStream = [NSData dataWithBytes:bytes length:length];
    [self writeData:dataToStream];
}

#pragma mark - Internal
- (void)writeDataFromBufferToStream {
    DDLogVerbose(@"FightingWalrusInterface: writeDataFromBufferToStream");
    while (([[self.session outputStream] hasSpaceAvailable]) && ([_writeDataBuffer length] > 0)) {
        NSInteger bytesWritten = [[_session outputStream] write:[_writeDataBuffer bytes] maxLength:[_writeDataBuffer length]];

        DDLogVerbose(@"[%lu] bytes in buffer - wrote [%ld] bytes", (unsigned long)[_writeDataBuffer length], (long)bytesWritten);
        if (bytesWritten == -1) {
            DDLogError(@"write error");
            break;
        } else if (bytesWritten > 0) {
            [self.writeDataBuffer replaceBytesInRange:NSMakeRange(0, bytesWritten) withBytes:NULL length:0];
        }
    }
}


#define EAD_INPUT_BUFFER_SIZE 256

- (void)readDataFromStreamToBuffer {
    DDLogVerbose(@"FightingWalrusInterface: readDataFromStreamToBuffer");
    uint8_t buf[EAD_INPUT_BUFFER_SIZE];
    while ([[self.session inputStream] hasBytesAvailable]) {
        NSInteger bytesRead = [[self.session inputStream] read:buf maxLength:EAD_INPUT_BUFFER_SIZE];
        DDLogVerbose(@"read %ld bytes from input stream", (long)bytesRead);
        if (bytesRead < 0) {
            DDLogError(@"read error");
            return;
        }
        [self produceData:buf length:bytesRead];
    }
}

#pragma mark -
#pragma mark Helpers

-(NSString *)enabledProtocolFromProtocolStrings:(NSArray *) protocols {
    BOOL isSupported = [_supportedAccessoryProtocols containsObject:_enabledAccessoryProtocol];
    if (!isSupported) {
        return nil;
    }

    NSInteger idx = [protocols indexOfObject:_enabledAccessoryProtocol];

    if (idx == NSNotFound) {
        return nil;
    }

    return protocols[idx];
}

-(void)notifyIfFirmwareUpdateNeeded {
    // check if we need to update fwr firmware
    if ([GCSAccessoryFirmwareUtils isFirmwareUpdateNeededWithFirmwareRevision:self.selectedAccessory.firmwareRevision]) {
        [GCSAccessoryFirmwareUtils notifyOfFirmwareUpateNeededWithModelNumber:self.selectedAccessory.modelNumber];
    }
}

@end
