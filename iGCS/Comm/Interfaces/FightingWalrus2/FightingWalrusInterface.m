//
//  FightingWalrusInterface.m
//  iGCS
//
//  Created by Andrew Brown on 9/22/13.
//
//

#import "FightingWalrusInterface.h"
#import "GCSFWRFirmwareInterface.h"
#import "GCSFirmwareUtils.h"
#import "DebugLogger.h"

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
        [DebugLogger console:@"FightingWalrusInterface: Starting accessory session.."];
        [fightingWalrusInterface openSession];
        [DebugLogger console:@"FightingWalrusInterface: Ready."];

        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [fightingWalrusInterface notifyIfFirmwareUpdateNeeded];
        });

        return fightingWalrusInterface;
    } else {
        [DebugLogger console:@"FightingWalrusInterface: No accessory found."];
        return nil;
    }
}

#pragma mark Public Methods

- (id)initWithProtocolString:(NSString *) protocolString {
    if (self = [super init]) {
        // Custom initialization
        _writeDataBuffer = [[NSMutableData alloc] init];
        _accessoryList = [[NSMutableArray alloc] initWithArray:[[EAAccessoryManager sharedAccessoryManager] connectedAccessories]];
        _supportedAccessoryProtocols = @[GCSProtocolStringTelemetry, GCSProtocolStringConfig, GCSProtocolStringUpdate];
        _enabledAccessoryProtocol = protocolString;
        //HACK Testing ping pong connect/disconnect
        _doubleTab = @YES;

        NSLog(@"accessory count: %lu", (unsigned long)[_accessoryList count]);
        if ([self.accessoryList count]) {
            for(EAAccessory *currentAccessory in _accessoryList) {
                BOOL comparison = [currentAccessory.manufacturer isEqualToString:@"Fighting Walrus LLC"];
                if(comparison){
                    self.selectedAccessory = currentAccessory;
                    NSLog(@"Manufacturer of our device is %@",_selectedAccessory.manufacturer);
                    break;
                }
            }

            NSArray *protocolStrings = [self.selectedAccessory protocolStrings];
            self.protocolString = [self enabledProtocolFromProtocolStrings:protocolStrings];
            NSLog(@"protocolString: %@", self.protocolString);
        }
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessoryConnected:)
                                                 name:EAAccessoryDidConnectNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessoryDisconnected:)
                                                 name:EAAccessoryDidDisconnectNotification object:nil];

    [[EAAccessoryManager sharedAccessoryManager] registerForLocalNotifications];

    return self;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (EAAccessory *)selectedAccessory {
    if (_selectedAccessory == nil) {
        self.accessoryList = [[NSMutableArray alloc] initWithArray:[[EAAccessoryManager sharedAccessoryManager] connectedAccessories]];
        NSLog(@"accessory count: %lu", (unsigned long)[self.accessoryList count]);
        if ([self.accessoryList count]) {
            _selectedAccessory = [self.accessoryList objectAtIndex:0];
            NSArray *protocolStrings = [self.selectedAccessory protocolStrings];
            self.protocolString = [self enabledProtocolFromProtocolStrings:protocolStrings];;
        }
    }
    return _selectedAccessory;
}

- (void)setupControllerForAccessory:(EAAccessory *)accessory withProtocolString:(NSString *)protocolString {
	NSLog(@"FightingWalrusInterface: setupControllerForAccessory:");
    self.selectedAccessory = accessory;
    self.protocolString = [protocolString copy];
}

- (BOOL)openSession {
	if (self.session == nil) {
        NSLog(@"FightingWalrusInterface: openSession");
        [self.selectedAccessory setDelegate:self];
        self.session = [[EASession alloc] initWithAccessory:[self selectedAccessory] forProtocol:_protocolString];

        if (self.session) {
            [[self.session inputStream] setDelegate:self];
            [[self.session inputStream] scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            [[self.session inputStream] open];
            
            [[self.session outputStream] setDelegate:self];
            [[self.session outputStream] scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            [[self.session outputStream] open];
            NSLog(@"opened the session");
        } else{
            NSLog(@"creating session failed");
        }
    }

    return (self.session != nil);
}

- (void)closeSession {
	NSLog(@"FightingWalrusInterface: closeSession");
    [[self.session inputStream] close];
    [[self.session inputStream] removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [[self.session inputStream] setDelegate:nil];
    [[self.session outputStream] close];
    [[self.session outputStream] removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [[self.session outputStream] setDelegate:nil];
    
    self.session = nil;
	NSLog(@"closed the session");
}

-(void)close {
    [self closeSession];
}

- (void)writeData:(NSData *)data {
    [self.writeDataBuffer appendData:data];
    [self writeDataFromBufferToStream];
}

- (BOOL)isAccessoryConnected {
    NSLog(@"FightingWalrusInterface: isAccessoryConnected");
    return (self.selectedAccessory && [self.selectedAccessory isConnected]);
}


#pragma mark -
#pragma mark EAAccessoryDelegate

- (void)accessoryDidDisconnect:(EAAccessory *)accessory {
	NSLog(@"FightingWalrusInterface: accessoryDidDisconnect:");
}


#pragma mark -
#pragma mark NSStreamDelegateEventExtensions

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
	NSLog(@"FightingWalrusInterface :handleEvent:");
    switch (eventCode) {
        case NSStreamEventNone:
            NSLog(@"stream %@ event none", aStream);
            break;
        case NSStreamEventOpenCompleted:
            NSLog(@"stream %@ event open completed", aStream);
            break;
        case NSStreamEventHasBytesAvailable:
            //NSLog(@"stream %@ event bytes available", aStream);
            [self readDataFromStreamToBuffer];
            break;
        case NSStreamEventHasSpaceAvailable:
            //NSLog(@"stream %@ event space available", aStream);
            [self writeDataFromBufferToStream];
            break;
        case NSStreamEventErrorOccurred:
            NSLog(@"stream %@ event error", aStream);
            break;
        case NSStreamEventEndEncountered:
            NSLog(@"stream %@ event end encountered", aStream);
            break;
        default:
            break;
    }
}

#pragma mark -
#pragma mark NSNotifications

- (void)accessoryConnected:(NSNotification *)notification {
	NSLog(@"FightingWalrusInterface: accessoryConnected");
    NSLog(@"FightingWalrusInterface: accessoryConnected: notification Name: %@",notification.name);
    NSLog(@"Notification: %@",notification.userInfo);
    
    if([_doubleTab boolValue]) {
        _doubleTab = @NO;
    } else {
        _doubleTab = @YES;
        if (![self isAccessoryConnected]) {
            EAAccessory *a = [self selectedAccessory];
            [self setupControllerForAccessory:a withProtocolString:_protocolString];
            [self openSession];
        }
    }
}

- (void)accessoryDisconnected:(NSNotification *)notification {
	NSLog(@"FightingWalrusInterface: accessoryDisconnected");
    NSLog(@"FightingWalrusInterface: accessoryDisconnected: notification Name: %@",notification.name);

    // When accessory disconnects reset the last firmware update
    // version written so that we don't bypass the firmware
    // version check on next reconnect. This should handle cases
    // where a new radio is connected that also needs a firmware
    // update. Should get this notification on next launch if
    // dissconect happened while in background.
    [GCSFirmwareUtils resetFirmwareVersionInUserDefaults];

    if (![self isAccessoryConnected]){
		[self closeSession];
    }
}

#pragma mark - CommInterfaceProtocol

-(void)consumeData:(const uint8_t *)bytes length:(int)length {
    [DebugLogger console:@"FightingWalrusInterface: consumeData (stubbed)."];

    NSData *dataToStream = [NSData dataWithBytes:bytes length:length];
    [self writeData:dataToStream];
    
}

#pragma mark - Internal
- (void)writeDataFromBufferToStream {
    NSLog(@"FightingWalrusInterface: writeDataFromBufferToStream");
    while (([[self.session outputStream] hasSpaceAvailable]) && ([_writeDataBuffer length] > 0)) {
        NSInteger bytesWritten = [[_session outputStream] write:[_writeDataBuffer bytes] maxLength:[_writeDataBuffer length]];

        NSLog(@"[%lu] bytes in buffer - wrote [%ld] bytes", (unsigned long)[_writeDataBuffer length], (long)bytesWritten);
        if (bytesWritten == -1) {
            NSLog(@"write error");
            break;
        } else if (bytesWritten > 0) {
            [self.writeDataBuffer replaceBytesInRange:NSMakeRange(0, bytesWritten) withBytes:NULL length:0];
        }
    }
}


#define EAD_INPUT_BUFFER_SIZE 128

- (void)readDataFromStreamToBuffer {
    NSLog(@"FightingWalrusInterface: readDataFromStreamToBuffer");
    uint8_t buf[EAD_INPUT_BUFFER_SIZE];
    while ([[self.session inputStream] hasBytesAvailable]) {
        NSInteger bytesRead = [[self.session inputStream] read:buf maxLength:EAD_INPUT_BUFFER_SIZE];
        NSLog(@"read %ld bytes from input stream", (long)bytesRead);

        [self produceData:buf length:(int)bytesRead];
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

    return [protocols objectAtIndex:idx];
}

-(void)notifyIfFirmwareUpdateNeeded {
    // check if we need to update fwr firmware

    if ([GCSFirmwareUtils isFirmwareUpdateNeededWithFirmwareRevision:self.selectedAccessory.firmwareRevision]) {
        [GCSFirmwareUtils notifyFwrFirmwareUpateNeeded];
    }
}

@end
