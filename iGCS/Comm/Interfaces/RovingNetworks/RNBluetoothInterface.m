//
//  RNBluetoothInterface.m
//  iGCS
//
//  Created by Andrew Aarestad on 2/27/13.
//
//

#import "RNBluetoothInterface.h"

@implementation RNBluetoothInterface

+(RNBluetoothInterface*)create {
    RNBluetoothInterface *rn = [[RNBluetoothInterface alloc] init];
    
    if (rn.selectedAccessory) {
        [rn openSession];
        return rn;
    } else {
        return nil;
    }
}

-(void)consumeData:(const uint8_t *)bytes length:(int)length {
    NSData *dataToStream = [NSData dataWithBytes:bytes length:length];
    [self writeData:dataToStream];
    
}

#pragma mark Internal

- (void)writeDataFromBufferToStream {
	DDLogVerbose(@"RNBluetoothInterface::writeDataFromBufferToStream");
    while (([[_session outputStream] hasSpaceAvailable]) && ([_writeDataBuffer length] > 0)) {
        NSInteger bytesWritten = [[_session outputStream] write:[_writeDataBuffer bytes] maxLength:[_writeDataBuffer length]];
		
		DDLogVerbose(@"[%lu] bytes in buffer - wrote [%ld] bytes", (unsigned long)[_writeDataBuffer length], (long)bytesWritten);
        if (bytesWritten == -1) {
            DDLogError(@"write error");
            break;
        } else if (bytesWritten > 0) {
            [_writeDataBuffer replaceBytesInRange:NSMakeRange(0, bytesWritten) withBytes:NULL length:0];
        }
    }
}


#define EAD_INPUT_BUFFER_SIZE 128

- (void)readDataFromStreamToBuffer {
	DDLogVerbose(@"RNBluetoothInterface::readDataFromStreamToBuffer");
	uint8_t buf[EAD_INPUT_BUFFER_SIZE];
	while ([[_session inputStream] hasBytesAvailable]) {
		NSInteger bytesRead = [[_session inputStream] read:buf maxLength:EAD_INPUT_BUFFER_SIZE];
		DDLogVerbose(@"read %ld bytes from input stream", (long)bytesRead);
        [self produceData:buf length:bytesRead];
	}
}


#pragma mark Public Methods



- (id)init {
    if (self = [super init]) {
        // Custom initialization
        _writeDataBuffer = [[NSMutableData alloc] init];
		_accessoryList = [[NSMutableArray alloc] initWithArray:[[EAAccessoryManager sharedAccessoryManager] connectedAccessories]];
		DDLogInfo(@"accessory count: %lu", (unsigned long)[_accessoryList count]);
		if ([_accessoryList count]) {
            for(EAAccessory *currentAccessory in _accessoryList) {
                BOOL comparison = [currentAccessory.manufacturer isEqualToString:@"Roving Networks"];
                if(comparison) {
                    _selectedAccessory = currentAccessory;
                    DDLogDebug(@"Manufacturer of our device is %@",_selectedAccessory.manufacturer);
                    break;
                }
            }
			NSArray *protocolStrings = [_selectedAccessory protocolStrings];
			self.protocolString = [protocolStrings objectAtIndex:0];
		}
	}

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessoryConnected:) name:EAAccessoryDidConnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessoryDisconnected:) name:EAAccessoryDidDisconnectNotification object:nil];
    [[EAAccessoryManager sharedAccessoryManager] registerForLocalNotifications];
    
    return self;
}

- (EAAccessory *)selectedAccessory {
	if (_selectedAccessory == nil) {
		_accessoryList = [[NSMutableArray alloc] initWithArray:[[EAAccessoryManager sharedAccessoryManager] connectedAccessories]];
		if ([_accessoryList count]) {
			_selectedAccessory = [_accessoryList objectAtIndex:0];
			NSArray *protocolStrings = [_selectedAccessory protocolStrings];
			self.protocolString = [protocolStrings objectAtIndex:0];
		}
	}
	return _selectedAccessory;
}

- (void)setupControllerForAccessory:(EAAccessory *)accessory withProtocolString:(NSString *)protocolString {
	DDLogInfo(@"RNBluetoothInterface::setupControllerForAccessory:");
    _selectedAccessory = accessory;
    _protocolString = [protocolString copy];
}

- (BOOL)openSession {
	if (_session == nil) {
		DDLogInfo(@"RNBluetoothInterface::openSession");
		[_selectedAccessory setDelegate:self];
		_session = [[EASession alloc] initWithAccessory:[self selectedAccessory] forProtocol:_protocolString];
        
		if (_session) {
			[[_session inputStream] setDelegate:self];
			[[_session inputStream] scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
			[[_session inputStream] open];
            
			[[_session outputStream] setDelegate:self];
			[[_session outputStream] scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
			[[_session outputStream] open];
			DDLogInfo(@"opened the session");
		}
		else {
			DDLogError(@"creating session failed");
		}
	}
    
    return (_session != nil);
}

- (void)closeSession {
	DDLogInfo(@"RNBluetoothInterface::closeSession");
    [[_session inputStream] close];
    [[_session inputStream] removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [[_session inputStream] setDelegate:nil];
    [[_session outputStream] close];
    [[_session outputStream] removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [[_session outputStream] setDelegate:nil];
    
    _session = nil;
	DDLogInfo(@"closed the session");
}

- (void)writeData:(NSData *)data {
	DDLogVerbose(@"RNBluetoothInterface::writeData:");
    [_writeDataBuffer appendData:data];
    [self writeDataFromBufferToStream];
}

- (BOOL)isAccessoryConnected {
	DDLogDebug(@"RNBluetoothInterface::isAccessoryConnected");
	return (_selectedAccessory && [_selectedAccessory isConnected]);
}


#pragma mark -
#pragma mark EAAccessoryDelegate

- (void)accessoryDidDisconnect:(EAAccessory *)accessory {
	DDLogInfo(@"RNBluetoothInterface::accessoryDidDisconnect:");
    // do something ...
}


#pragma mark -
#pragma mark NSStreamDelegateEventExtensions

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
	DDLogVerbose(@"RNBluetoothInterface::handleEvent:");
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
            DDLogError(@"stream %@ event error", aStream);
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
	DDLogInfo(@"RNBluetoothInterface::accessoryConnected");
	if (![self isAccessoryConnected]) {
		EAAccessory *a = [self selectedAccessory];
		[self setupControllerForAccessory:a withProtocolString:_protocolString];
		[self closeSession];
		[self openSession];
	}
}

- (void)accessoryDisconnected:(NSNotification *)notification {
	DDLogInfo(@"RNBluetoothInterface::accessoryDisconnected");
	if (![self isAccessoryConnected]) {
		EAAccessory *a = [self selectedAccessory];
		[self setupControllerForAccessory:a withProtocolString:_protocolString];
		[self closeSession];
		[self openSession];
	}
}

@end
