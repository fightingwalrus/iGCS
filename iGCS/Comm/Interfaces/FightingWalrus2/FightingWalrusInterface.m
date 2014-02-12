//
//  FightingWalrusInterface.m
//  iGCS
//
//  Created by Andrew Brown on 9/22/13.
//
//

#import "FightingWalrusInterface.h"
#import "DebugLogger.h"

NSString * const GCSProtocolStringTelemetry = @"com.fightingwalrus.igcs";
NSString * const GCSProtocolStringConfig = @"com.fightingwalrus.config";

@implementation FightingWalrusInterface
+(FightingWalrusInterface*)createWithProtocolString:(NSString *) protocolString {
    FightingWalrusInterface *fightingWalrusInterface = [[FightingWalrusInterface alloc] initWithProtocolString:protocolString];

    if (fightingWalrusInterface.selectedAccessory) {
        [DebugLogger console:@"FightingWalrusInterface: Starting accessory session.."];
        [fightingWalrusInterface openSession];
        [DebugLogger console:@"FightingWalrusInterface: Ready."];
        return fightingWalrusInterface;
    } else {
        [DebugLogger console:@"FightingWalrusInterface: No accessory found."];
        return nil;
    }
}

-(void)consumeData:(uint8_t *)bytes length:(int)length {
    [DebugLogger console:@"FightingWalrusInterface: consumeData (stubbed)."];

    NSData *dataToStream = [NSData dataWithBytes:bytes length:length];
    [self writeData:dataToStream];

}

#pragma mark Internal

- (void)writeDataFromBufferToStream {
    NSLog(@"FightingWalrusInterface: writeDataFromBufferToStream");
    while (([[_session outputStream] hasSpaceAvailable]) && ([_writeDataBuffer length] > 0)) {
        NSInteger bytesWritten = [[_session outputStream] write:[_writeDataBuffer bytes] maxLength:[_writeDataBuffer length]];
        
        NSLog(@"[%d] bytes in buffer - wrote [%d] bytes", [_writeDataBuffer length], bytesWritten);
        if (bytesWritten == -1) {
            NSLog(@"write error");
            break;
        } else if (bytesWritten > 0) {
            [_writeDataBuffer replaceBytesInRange:NSMakeRange(0, bytesWritten) withBytes:NULL length:0];
        }
    }
}


#define EAD_INPUT_BUFFER_SIZE 128

- (void)readDataFromStreamToBuffer {
    NSLog(@"FightingWalrusInterface: readDataFromStreamToBuffer");
    uint8_t buf[EAD_INPUT_BUFFER_SIZE];
    while ([[_session inputStream] hasBytesAvailable]) {
        NSInteger bytesRead = [[_session inputStream] read:buf maxLength:EAD_INPUT_BUFFER_SIZE];
        NSLog(@"read %d bytes from input stream", bytesRead);

        [self produceData:buf length:bytesRead];
    }
}


#pragma mark Public Methods

- (id)initWithProtocolString:(NSString *) protocolString {
    if (self = [super init]) {
        // Custom initialization
        _writeDataBuffer = [[NSMutableData alloc] init];
        _accessoryList = [[NSMutableArray alloc] initWithArray:[[EAAccessoryManager sharedAccessoryManager] connectedAccessories]];
        _supportedAccessoryProtocols = @[GCSProtocolStringTelemetry, GCSProtocolStringConfig];
        _enabledAccessoryProtocol = protocolString;
        //HACK Testing ping pong connect/disconnect
        _doubleTab = @YES;

        NSLog(@"accessory count: %d", [_accessoryList count]);
        if ([_accessoryList count]) {
            for(EAAccessory *currentAccessory in _accessoryList) {
                BOOL comparison = [currentAccessory.manufacturer isEqualToString:@"Fighting Walrus LLC"];
                if(comparison){
                    _selectedAccessory = currentAccessory;
                    NSLog(@"Manufacturer of our device is %@",_selectedAccessory.manufacturer);
                    break;
                }
            }

            NSArray *protocolStrings = [_selectedAccessory protocolStrings];
            self.protocolString = [self enabledProtocolFromProtocolStrings:protocolStrings];
        }
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessoryConnected:) name:EAAccessoryDidConnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessoryDisconnected:) name:EAAccessoryDidDisconnectNotification object:nil];

    [[EAAccessoryManager sharedAccessoryManager] registerForLocalNotifications];

    return self;
}

- (EAAccessory *)selectedAccessory
{
    if (_selectedAccessory == nil) {
        _accessoryList = [[NSMutableArray alloc] initWithArray:[[EAAccessoryManager sharedAccessoryManager] connectedAccessories]];
        NSLog(@"accessory count: %d", [_accessoryList count]);
        if ([_accessoryList count]) {
            _selectedAccessory = [_accessoryList objectAtIndex:0];
            NSArray *protocolStrings = [_selectedAccessory protocolStrings];
            self.protocolString = [self enabledProtocolFromProtocolStrings:protocolStrings];;
        }
    }
    return _selectedAccessory;
}

- (void)setupControllerForAccessory:(EAAccessory *)accessory withProtocolString:(NSString *)protocolString
{
	NSLog(@"FightingWalrusInterface: setupControllerForAccessory:");
    _selectedAccessory = accessory;
    _protocolString = [protocolString copy];
}

- (BOOL)openSession
{
	if (_session == nil) {
        NSLog(@"FightingWalrusInterface: openSession");
        [_selectedAccessory setDelegate:self];
        _session = [[EASession alloc] initWithAccessory:[self selectedAccessory] forProtocol:_protocolString];

        if (_session) {
            [[_session inputStream] setDelegate:self];
            [[_session inputStream] scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            [[_session inputStream] open];
            
            [[_session outputStream] setDelegate:self];
            [[_session outputStream] scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            [[_session outputStream] open];
            NSLog(@"opened the session");
        } else{
            NSLog(@"creating session failed");
        }
    }

    return (_session != nil);
}

- (void)closeSession {
	NSLog(@"FightingWalrusInterface: closeSession");
    [[_session inputStream] close];
    [[_session inputStream] removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [[_session inputStream] setDelegate:nil];
    [[_session outputStream] close];
    [[_session outputStream] removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [[_session outputStream] setDelegate:nil];
    
    _session = nil;
	NSLog(@"closed the session");
}

- (void)writeData:(NSData *)data {
    [_writeDataBuffer appendData:data];
    [self writeDataFromBufferToStream];
}

- (BOOL)isAccessoryConnected {
	NSLog(@"FightingWalrusInterface: isAccessoryConnected");
	if (_selectedAccessory && [_selectedAccessory isConnected]) {
        return YES;
    } else {
        return NO;
    }
}


#pragma mark -
#pragma mark EAAccessoryDelegate

- (void)accessoryDidDisconnect:(EAAccessory *)accessory {
	NSLog(@"FightingWalrusInterface: accessoryDidDisconnect:");
    // do something ...
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

    if (![self isAccessoryConnected]){
		[self closeSession];
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

@end
