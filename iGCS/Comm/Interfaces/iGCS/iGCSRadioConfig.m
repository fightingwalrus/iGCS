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
//    NSLog(@"iGCSRadioConfig consumeData");
    NSData *data = [NSData dataWithBytes:bytes length:length];
    NSString *aString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
//    NSLog(@"raw: %@", aString);

    NSString *currentString = [aString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    [_buffer appendString:[NSString stringWithFormat:@"%@|", currentString]];

    if (_hayesResponseState == HayesStart) {
        if ([_possibleCommands containsObject:currentString]) {
            @synchronized(self) {
                _hayesResponseState = HayesCommand;
            }
            _previousHayesResponse = currentString;
        }
    } else if (_hayesResponseState == HayesCommand && _previousHayesResponse) {
        _currentSettings[_previousHayesResponse] = currentString;
        @synchronized(self) {
            _hayesResponseState = HayesEnd;
        }
        _previousHayesResponse = nil;
    }
}

-(void)produceData:(uint8_t*)bytes length:(int)length {
//    NSLog(@"iGCSRadioConfig produceData");
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
    [_commandQueue addObject:^(){[weakSelf boadFrequency];}];
    [_commandQueue addObject:^(){[weakSelf boadVersion];}];

//  TODO: need more logic to parse response from this command.
//  eepromParams are currently gathered one by one.
//  [_commandQueue addObject:^(){[weakSelf eepromParams];}];
    [_commandQueue addObject:^(){[weakSelf tdmTimingReport];}];

    [_commandQueue addObject:^(){[weakSelf RSSIReport];}];
    [_commandQueue addObject:^(){[weakSelf serialSpeed];}];
    [_commandQueue addObject:^(){[weakSelf airSpeed];}];
    [_commandQueue addObject:^(){[weakSelf netId];}];
    [_commandQueue addObject:^(){[weakSelf transmitPower];}];
    [_commandQueue addObject:^(){[weakSelf ecc];}];
    [_commandQueue addObject:^(){[weakSelf radioVersion];}];
    [_commandQueue addObject:^(){[weakSelf mavLink];}];
    [_commandQueue addObject:^(){[weakSelf oppResend];}];
    [_commandQueue addObject:^(){[weakSelf minFrequency];}];
    [_commandQueue addObject:^(){[weakSelf maxFrequency];}];
    [_commandQueue addObject:^(){[weakSelf numberOfChannels];}];
    [_commandQueue addObject:^(){[weakSelf dutyCycle];}];
    [_commandQueue addObject:^(){[weakSelf listenBeforeTalkRssi];}];

    if (!_queueTimer) {
        _queueTimer = [NSTimer scheduledTimerWithTimeInterval:0.25f target:self
                                                     selector:@selector(dispatchCommandFromQueue)
                                                     userInfo:nil repeats:YES];
    }
}


#pragma mark - read radio settings via AT/RT commands
-(void)radioVersion {
    [self sendATCommand:_sikAt.showRadioVersionCommand];
}

-(void)boadType {
    [self sendATCommand:_sikAt.showBoardTypeCommand];
}

-(void)boadFrequency {
    [self sendATCommand:_sikAt.showBoardFrequencyCommand];
}

-(void)boadVersion {
    [self sendATCommand:_sikAt.showBoardVersionCommand];
}

-(void)eepromParams {
    [self sendATCommand:_sikAt.showEEPROMParamsCommand];
}

-(void)tdmTimingReport {
    [self sendATCommand:_sikAt.showTDMTimingReport];
}

-(void)RSSIReport {
    [self sendATCommand:_sikAt.showRSSISignalReport];
}

-(void)serialSpeed {
    [self sendATCommand:[_sikAt showRadioParamCommand:SerialSpeed]];
}

-(void)airSpeed {
    [self sendATCommand:[_sikAt showRadioParamCommand:AirSpeed]];
}

-(void)netId {
    [self sendATCommand:[_sikAt showRadioParamCommand:NetId]];
}

-(void)transmitPower {
    [self sendATCommand:[_sikAt showRadioParamCommand:TxPower]];
}

-(void)ecc {
    [self sendATCommand:[_sikAt showRadioParamCommand:EnableECC]];
}

-(void)mavLink {
    [self sendATCommand:[_sikAt showRadioParamCommand:MavLink]];
}

-(void)oppResend {
    [self sendATCommand:[_sikAt showRadioParamCommand:OppResend]];
}

-(void)minFrequency {
    [self sendATCommand:[_sikAt showRadioParamCommand:MinFrequency]];
}

-(void)maxFrequency {
    [self sendATCommand:[_sikAt showRadioParamCommand:MaxFrequency]];
}

-(void)numberOfChannels {
    [self sendATCommand:[_sikAt showRadioParamCommand:NumberOfChannels]];
}

-(void)dutyCycle {
    [self sendATCommand:[_sikAt showRadioParamCommand:DutyCycle]];
}

-(void)listenBeforeTalkRssi {
    [self sendATCommand:[_sikAt showRadioParamCommand:LbtRssi]];
}

#pragma mark - write radio settings via AT/RT commands
-(void)setNetId:(NSInteger) aNetId {
    [self sendATCommand:[_sikAt setRadioParamCommand:NetId withValue:aNetId]];
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
    _timer = [NSTimer scheduledTimerWithTimeInterval:2.0f target:self
                                            selector:@selector(hayesResponseTimeout)
                                            userInfo:nil repeats:NO];

    @synchronized(self) {
        _hayesResponseState = HayesStart;
    }

    [_possibleCommands addObject:atCommand];
    NSString *command = [NSString stringWithFormat:@"\r\n%@\r\n", atCommand];
    const char* buf;
    buf = [command cStringUsingEncoding:NSASCIIStringEncoding];
    uint32_t len = (uint32_t)strlen(buf);
    [self produceData:buf length:len];
}

-(void)hayesResponseTimeout {
    @synchronized(self) {
        [_timer invalidate];
        _timer = nil;
        _previousHayesResponse = nil;
        _hayesResponseState = HayesEnd;
    }
}

-(void) dispatchCommandFromQueue {
    @synchronized(self) {
        if (_hayesResponseState == HayesEnd) {
            void(^ hayesCommand)() = [_commandQueue pop];
            hayesCommand();
        }
    }

    if (_commandQueue.count < 1) {
        [_queueTimer invalidate];
        _queueTimer = nil;
        NSLog(@"----buffer----");
        NSLog(@"%@", _buffer);

        NSLog(@"-----possible commands----");
        NSLog(@"%@", _possibleCommands);

        NSLog(@"-----current settings-----");
        NSLog(@"%@", _currentSettings);
    }
}
@end
