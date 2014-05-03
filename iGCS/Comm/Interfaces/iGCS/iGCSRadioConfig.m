//
//  iCGCRadioConfig.m
//  iGCS
//
//  Created by Andrew Brown on 9/5/13.
//
//

#import "iGCSRadioConfig.h"

@implementation NSMutableArray (Queue)
-(id)pop{
    id anObject = [self lastObject];
    [self removeLastObject];
    return anObject;
}
@end

@interface iGCSRadioConfig () {
    NSTimer *_timer;
    NSTimer *_queueTimer;
    NSMutableString *_buffer;
    NSMutableArray *_possibleCommands;
    NSMutableDictionary *_currentSettings;
    NSString *_previousHayesResponse;

    // Queue of selectors of commands to perform
    NSMutableArray *_commandQueue;
}

 -(void)sendATCommand:(NSString *)atCommand;
@end

@implementation iGCSRadioConfig

-(id) init {
    self = [super init];
    if (self) {
        // public
        _sikAt = [[GCSSikAT alloc] init];
        _buffer = [[NSMutableString alloc] init];
        _possibleCommands = [[NSMutableArray alloc] init];
        _currentSettings = [[NSMutableDictionary alloc] init];
        _hayesResponseState = HayesEnd;
        _commandQueue = [[NSMutableArray alloc] init];
    }
    return self;
}

// receiveBytes processes bytes forwarded from another interface
-(void)consumeData:(uint8_t*)bytes length:(int)length {
    NSLog(@"iGCSRadioConfig consumeData");
    NSData *data = [NSData dataWithBytes:bytes length:length];
    NSString *aString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    NSLog(@"raw: %@", aString);

    NSString *currentString = [aString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    if (_hayesResponseState == HayesStart) {
        if ([_possibleCommands containsObject:currentString]) {
            _hayesResponseState = HayesCommand;
            _previousHayesResponse = currentString;
        }
    } else if (_hayesResponseState == HayesCommand && _previousHayesResponse) {
        _currentSettings[_previousHayesResponse] = currentString;
        _hayesResponseState = HayesEnd;
        _previousHayesResponse = nil;
    }
}

-(void)produceData:(uint8_t*)bytes length:(int)length {
    NSLog(@"iGCSRadioConfig produceData");
    NSLog(@"%@",_buffer);
    [super produceData:bytes length:length];
}

-(void) close {
    NSLog(@"iGCSRadioClose: close is a noop");
}


#pragma public mark - send commands

-(void)loadSettings {
    [_commandQueue removeAllObjects];

    __weak id weakSelf = self;
    [_commandQueue addObject:^(){[weakSelf radioVersion];}];
    [_commandQueue addObject:^(){[weakSelf boadType];}];
    [_commandQueue addObject:^(){[weakSelf RSSIReport];}];

    if (!_queueTimer) {
        _queueTimer = [NSTimer scheduledTimerWithTimeInterval:0.25f target:self selector:@selector(dispatchCommandFromQueue) userInfo:nil repeats:YES];
    }
}


// read only
-(void)radioVersion {
    [self sendATCommand:_sikAt.showRadioVersionCommand];
}

-(void)boadType {
    [self sendATCommand:_sikAt.showBoardTypeCommand];
}

-(void)RSSIReport {
    [self sendATCommand:_sikAt.showRSSISignalReport];
}

// read/Write
-(void)netId {
    [self sendATCommand:_sikAt.showNetIDCommand];
}

-(void)setNetId:(NSInteger) netId {
    [self sendATCommand:[_sikAt setNetIdCommandWithNetId:netId]];
}

-(void)enableRSSIDebug {
    [self sendATCommand:[_sikAt enableRSSIDebugCommand]];
}

-(void)disableDebug {
    [self sendATCommand:[_sikAt disableDebugCommand]];
}

-(void)save {
    [self sendATCommand:[_sikAt writeCurrentParamsToEEPROMCommand]];
}

#pragma mark - private
-(void)sendATCommand:(NSString *)atCommand {
    if (_hayesResponseState != HayesEnd) {
        NSLog(@"Waiting for previous response. Can't send command: %@", atCommand);
        return;
    }
    _timer = [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(hayesResponseTimeout) userInfo:nil repeats:NO];

    _hayesResponseState = HayesStart;
    [_possibleCommands addObject:atCommand];
    NSString *command = [NSString stringWithFormat:@"\r\n%@\r\n", atCommand];
    const char* buf;
    buf = [command cStringUsingEncoding:NSASCIIStringEncoding];
    uint32_t len = (uint32_t)strlen(buf);
    [self produceData:buf length:len];
}

-(void)hayesResponseTimeout {
    @synchronized(_previousHayesResponse) {
        [_timer invalidate];
        _timer = nil;
        _previousHayesResponse = nil;
        _hayesResponseState = HayesEnd;
    }
}

-(void) dispatchCommandFromQueue {
    if (_hayesResponseState == HayesEnd) {
        void(^ hayesCommand)() = [_commandQueue pop];
        hayesCommand();
    }

    if (_commandQueue.count < 1) {
        [_queueTimer invalidate];
        _queueTimer = nil;
        NSLog(@"%@", _currentSettings);
    }
}
@end
