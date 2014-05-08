//
//  iCGCRadioConfig.m
//  iGCS
//
//  Created by Andrew Brown on 9/5/13.
//
//

#import "iGCSRadioConfig.h"

@implementation NSMutableArray (Queue)
-(id)gcs_pop{
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
    GCSSikAT *_privateSikAt;
}

 -(void)sendATCommand:(NSString *)atCommand;
@end

@implementation iGCSRadioConfig

-(id) init {
    self = [super init];
    if (self) {
        // public
        _sikAt = [[GCSSikAT alloc] init];
        _privateSikAt = [[GCSSikAT alloc] init];
        _localRadioSettings = [[GCSRadioSettings alloc] init];
        _remoteRadioSettings = [[GCSRadioSettings alloc] init];
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
        [self updateModelWithKey:_previousHayesResponse andValue:currentString];
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

    __weak iGCSRadioConfig *weakSelf = self;
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

    if (_commandQueue.count == 0) {
        NSLog(@"_currentSettings: %@", _currentSettings);
        NSLog(@"localSettings: %@", _localRadioSettings);
        NSLog(@"remoteRadioSettings: %@", _remoteRadioSettings);
        [_queueTimer invalidate];
        _queueTimer = nil;

        return;
    }

    @synchronized(self) {
        if (_hayesResponseState == HayesEnd) {
            void(^ hayesCommand)() = [_commandQueue gcs_pop];
            hayesCommand();
        }
    }
}

// brute force
-(void)updateModelWithKey:(NSString *)key andValue:(id) value {
    _privateSikAt.hayesMode = AT;
    // local radio settings
    if ([key isEqualToString:tShowLocalRadioVersion]) {
        _localRadioSettings.radioVersion = value;

    }else if ([key isEqualToString:tShowLocalBoardType]) {
        _localRadioSettings.boadType = value;

    }else if ([key isEqualToString:tShowLocalBoardFrequency]) {
        _localRadioSettings.boadFrequency = value;

    }else if ([key isEqualToString:tShowLocalBoardVersion]) {
        _localRadioSettings.boadVersion = value;

    }else if ([key isEqualToString:tShowLocalTDMTimingReport]) {
        _localRadioSettings.tdmTimingReport = value;

    }else if ([key isEqualToString:tShowLocalRSSISignalReport]) {
        _localRadioSettings.RSSIReport = value;

    }else if ([key isEqualToString:[_privateSikAt showRadioParamCommand:SerialSpeed]]) {
        _localRadioSettings.serialSpeed = [value integerValue];

    }else if ([key isEqualToString:[_privateSikAt showRadioParamCommand:AirSpeed]]) {
        _localRadioSettings.airSpeed = [value integerValue];

    }else if ([key isEqualToString:[_privateSikAt showRadioParamCommand:NetId]]) {
        _localRadioSettings.netId = [value integerValue];

    }else if ([key isEqualToString:[_privateSikAt showRadioParamCommand:TxPower]]) {
        _localRadioSettings.transmitterPower = [value integerValue];

    }else if ([key isEqualToString:[_privateSikAt showRadioParamCommand:EnableECC]]) {
        _localRadioSettings.isECCenabled = [value boolValue];

    } else if ([key isEqualToString:[_privateSikAt showRadioParamCommand:MavLink]]) {
        _localRadioSettings.isMavlinkEnabled = [value boolValue];

    } else if ([key isEqualToString:[_privateSikAt showRadioParamCommand:OppResend]]) {
        _localRadioSettings.isOppResendEnabled = [value boolValue];

    }else if ([key isEqualToString:[_privateSikAt showRadioParamCommand:MinFrequency]]) {
        _localRadioSettings.minFrequency = [value integerValue];

    }else if ([key isEqualToString:[_privateSikAt showRadioParamCommand:MaxFrequency]]) {
        _localRadioSettings.maxFrequency = [value integerValue];

    }else if ([key isEqualToString:[_privateSikAt showRadioParamCommand:NumberOfChannels]]) {
        _localRadioSettings.numberOfChannels = [value integerValue];

    }else if ([key isEqualToString:[_privateSikAt showRadioParamCommand:DutyCycle]]) {
        _localRadioSettings.dutyCycle = [value integerValue];

    } else if ([key isEqualToString:[_privateSikAt showRadioParamCommand:LbtRssi]]) {
        _localRadioSettings.isListenBeforeTalkRSSIEnabled = value;

    }

    // remote radio settings
    _privateSikAt.hayesMode = RT;
    if ([key isEqualToString:tShowRemoteRadioVersion]) {
        _remoteRadioSettings.radioVersion = value;

    }else if ([key isEqualToString:tShowRemoteBoardType]) {
        _remoteRadioSettings.boadType = value;

    }else if ([key isEqualToString:tShowRemoteBoardFrequency]) {
        _remoteRadioSettings.boadFrequency = value;

    }else if ([key isEqualToString:tShowRemoteBoardVersion]) {
        _remoteRadioSettings.boadVersion = value;

    }else if ([key isEqualToString:tShowRemoteTDMTimingReport]) {
        _remoteRadioSettings.tdmTimingReport = value;

    }else if ([key isEqualToString:tShowRemoteRSSISignalReport]) {
        _remoteRadioSettings.RSSIReport = value;

    }else if ([key isEqualToString:[_privateSikAt showRadioParamCommand:SerialSpeed]]) {
        _remoteRadioSettings.serialSpeed = [value integerValue];

    }else if ([key isEqualToString:[_privateSikAt showRadioParamCommand:AirSpeed]]) {
        _remoteRadioSettings.airSpeed = [value integerValue];

    }else if ([key isEqualToString:[_privateSikAt showRadioParamCommand:NetId]]) {
        _remoteRadioSettings.netId = [value integerValue];

    }else if ([key isEqualToString:[_privateSikAt showRadioParamCommand:TxPower]]) {
        _remoteRadioSettings.transmitterPower = [value integerValue];

    }else if ([key isEqualToString:[_privateSikAt showRadioParamCommand:EnableECC]]) {
        _remoteRadioSettings.isECCenabled = [value boolValue];

    } else if ([key isEqualToString:[_privateSikAt showRadioParamCommand:MavLink]]) {
        _remoteRadioSettings.isMavlinkEnabled = [value boolValue];

    } else if ([key isEqualToString:[_privateSikAt showRadioParamCommand:OppResend]]) {
        _remoteRadioSettings.isOppResendEnabled = [value boolValue];

    }else if ([key isEqualToString:[_privateSikAt showRadioParamCommand:MinFrequency]]) {
        _remoteRadioSettings.minFrequency = [value integerValue];

    }else if ([key isEqualToString:[_privateSikAt showRadioParamCommand:MaxFrequency]]) {
        _remoteRadioSettings.maxFrequency = [value integerValue];

    }else if ([key isEqualToString:[_privateSikAt showRadioParamCommand:NumberOfChannels]]) {
        _remoteRadioSettings.numberOfChannels = [value integerValue];

    }else if ([key isEqualToString:[_privateSikAt showRadioParamCommand:DutyCycle]]) {
        _remoteRadioSettings.dutyCycle = [value integerValue];

    } else if ([key isEqualToString:[_privateSikAt showRadioParamCommand:LbtRssi]]) {
        _remoteRadioSettings.isListenBeforeTalkRSSIEnabled = value;
        
    }

}

@end
