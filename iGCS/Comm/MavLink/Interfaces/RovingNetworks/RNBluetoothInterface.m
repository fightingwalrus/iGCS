//
//  RNBluetoothInterface.m
//  iGCS
//
//  Created by Andrew Aarestad on 2/27/13.
//
//

#import "RNBluetoothInterface.h"

#import "DebugLogger.h"

@implementation RNBluetoothInterface



+(RNBluetoothInterface*)create
{
    RNBluetoothInterface *rn = [[RNBluetoothInterface alloc] init];
    
    
    
    if (rn.selectedAccessory)
    {
        
        [DebugLogger console:@"RovingNetworks: Starting accessory session.."];
        [rn openSession];
        [DebugLogger console:@"RovingNetworks: Ready."];
        return rn;
    }
    else
    {
        [DebugLogger console:@"RovingNetworks: No accessory found."];
        return nil;
    }
}







-(void)consumeData:(uint8_t *)bytes length:(int)length
{
    [DebugLogger console:@"RovingNetworks: consumeData (stubbed)."];
    
    NSData *dataToStream = [NSData dataWithBytes:bytes length:length];
    [self writeData:dataToStream];
    
}









#pragma mark Internal

- (void)writeDataFromBufferToStream
{
	NSLog(@"RNBluetoothInterface::writeDataFromBufferToStream");
    while (([[_session outputStream] hasSpaceAvailable]) && ([_writeDataBuffer length] > 0))
    {
        NSInteger bytesWritten = [[_session outputStream] write:[_writeDataBuffer bytes] maxLength:[_writeDataBuffer length]];
		
		NSLog(@"[%d] bytes in buffer - wrote [%d] bytes", [_writeDataBuffer length], bytesWritten);
        if (bytesWritten == -1)
        {
            NSLog(@"write error");
            break;
        }
        else if (bytesWritten > 0)
        {
            [_writeDataBuffer replaceBytesInRange:NSMakeRange(0, bytesWritten) withBytes:NULL length:0];
        }
    }
}


#define EAD_INPUT_BUFFER_SIZE 128

- (void)readDataFromStreamToBuffer
{
	//NSLog(@"RNBluetoothInterface::readDataFromStreamToBuffer");
	uint8_t buf[EAD_INPUT_BUFFER_SIZE];
	while ([[_session inputStream] hasBytesAvailable])
	{
		NSInteger bytesRead = [[_session inputStream] read:buf maxLength:EAD_INPUT_BUFFER_SIZE];
		NSLog(@"read %d bytes from input stream", bytesRead);
        

        [self produceData:buf length:bytesRead];
	}
}


#pragma mark Public Methods



- (id)init
{
    if (self = [super init])
	{
        // Custom initialization
        _writeDataBuffer = [[NSMutableData alloc] init];
		_accessoryList = [[NSMutableArray alloc] initWithArray:[[EAAccessoryManager sharedAccessoryManager] connectedAccessories]];
		NSLog(@"accessory count: %d", [_accessoryList count]);
		if ([_accessoryList count])
		{
            for(EAAccessory *currentAccessory in _accessoryList)
            {
                BOOL comparison = [currentAccessory.manufacturer isEqualToString:@"Roving Networks"];
                if(comparison)
                {
                    _selectedAccessory = currentAccessory;
                    NSLog(@"Manufacturer of our device is %@",_selectedAccessory.manufacturer);
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


- (EAAccessory *)selectedAccessory
{
	if (_selectedAccessory == nil)
	{
		_accessoryList = [[NSMutableArray alloc] initWithArray:[[EAAccessoryManager sharedAccessoryManager] connectedAccessories]];
		NSLog(@"accessory count: %d", [_accessoryList count]);
		if ([_accessoryList count])
		{
			_selectedAccessory = [_accessoryList objectAtIndex:0];
			NSArray *protocolStrings = [_selectedAccessory protocolStrings];
			self.protocolString = [protocolStrings objectAtIndex:0];
		}
	}
	return _selectedAccessory;
}




- (void)setupControllerForAccessory:(EAAccessory *)accessory withProtocolString:(NSString *)protocolString
{
	NSLog(@"RNBluetoothInterface::setupControllerForAccessory:");
    _selectedAccessory = accessory;
    _protocolString = [protocolString copy];
}


- (BOOL)openSession
{
	if (_session == nil)
	{
		NSLog(@"RNBluetoothInterface::openSession");
		[_selectedAccessory setDelegate:self];
		_session = [[EASession alloc] initWithAccessory:[self selectedAccessory] forProtocol:_protocolString];
        
		if (_session)
		{
			[[_session inputStream] setDelegate:self];
			[[_session inputStream] scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
			[[_session inputStream] open];
            
			[[_session outputStream] setDelegate:self];
			[[_session outputStream] scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
			[[_session outputStream] open];
			NSLog(@"opened the session");
		}
		else
		{
			NSLog(@"creating session failed");
		}
	}
    
    return (_session != nil);
}


- (void)closeSession
{
	NSLog(@"RNBluetoothInterface::closeSession");
    [[_session inputStream] close];
    [[_session inputStream] removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [[_session inputStream] setDelegate:nil];
    [[_session outputStream] close];
    [[_session outputStream] removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [[_session outputStream] setDelegate:nil];
    
    _session = nil;
	NSLog(@"closed the session");
}


- (void)writeData:(NSData *)data
{
	//NSLog(@"RNBluetoothInterface::writeData:");
    [_writeDataBuffer appendData:data];
    [self writeDataFromBufferToStream];
}


- (BOOL)isAccessoryConnected
{
	NSLog(@"RNBluetoothInterface::isAccessoryConnected");
	if (_selectedAccessory && [_selectedAccessory isConnected])
		return YES;
	else
		return NO;
}


#pragma mark -
#pragma mark EAAccessoryDelegate

- (void)accessoryDidDisconnect:(EAAccessory *)accessory
{
	NSLog(@"RNBluetoothInterface::accessoryDidDisconnect:");
    // do something ...
}


#pragma mark -
#pragma mark NSStreamDelegateEventExtensions

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
	NSLog(@"RNBluetoothInterface::handleEvent:");
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

- (void)accessoryConnected:(NSNotification *)notification
{
	NSLog(@"RNBluetoothInterface::accessoryConnected");
	if (![self isAccessoryConnected])
	{
		EAAccessory *a = [self selectedAccessory];
		[self setupControllerForAccessory:a withProtocolString:_protocolString];
		[self closeSession];
		[self openSession];
	}
}


- (void)accessoryDisconnected:(NSNotification *)notification
{
	NSLog(@"RNBluetoothInterface::accessoryDisconnected");
	if (![self isAccessoryConnected])
	{
		EAAccessory *a = [self selectedAccessory];
		[self setupControllerForAccessory:a withProtocolString:_protocolString];
		[self closeSession];
		[self openSession];
	}
}








@end
