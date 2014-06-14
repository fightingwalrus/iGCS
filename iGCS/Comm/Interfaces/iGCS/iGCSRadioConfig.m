//
//  iCGCRadioConfig.m
//  iGCS
//
//  Created by Andrew Brown on 9/5/13.
//
//

#import "iGCSRadioConfig.h"

NSString * const GCSRadioConfigCommandQueueHasEmptied = @"com.fightingwalrus.radioconfig.queue.emptied";
NSString * const GCSRadioConfigCommandBatchResponseTimeOut = @"com.fightingwalrus.radioconfig.commandbatch.timeout";
NSString * const GCSRadioConfigEnteredConfigMode = @"com.fightingwalrus.radioconfig.entered.configmode";

@implementation NSMutableArray (Queue)
-(id)gcs_pop{
    id anObject = [self lastObject];
    [self removeLastObject];
    return anObject;
}
@end

@interface iGCSRadioConfig ()

@property (nonatomic, strong) GCSSikAT *privateSikAt;
@property (strong) NSTimer *batchResponseTimer;
@property (strong) NSMutableString *buffer;
@property (strong) NSMutableArray *possibleCommands;
@property (strong) NSMutableDictionary *currentSettings;
@property (strong) NSString *previousHayesResponse;

// Queue of selectors of commands to perform
@property (strong) NSMutableArray *commandQueue;

-(void)sendATCommand:(NSString *)atCommand;
@end

@implementation iGCSRadioConfig

-(id) init {
    self = [super init];
    if (self) {
        // public
        _sikAt = [[GCSSikAT alloc] init];
        _localRadioSettings = [[GCSRadioSettings alloc] init];
        _remoteRadioSettings = [[GCSRadioSettings alloc] init];
        _hayesResponseState = HayesEnd;
        
        // private
        _privateSikAt = [[GCSSikAT alloc] init];
        _buffer = [[NSMutableString alloc] init];
        _possibleCommands = [[NSMutableArray alloc] init];
        _currentSettings = [[NSMutableDictionary alloc] init];
        _commandQueue = [[NSMutableArray alloc] init];
        _ATCommandTimeout = 0.5f;
        _RTCommandTimeout = 0.5f;

        // observe
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(commandQueueHasEmptied) name:GCSRadioConfigCommandQueueHasEmptied object:nil];
    }
    return self;
}

#pragma mark - CommInterfaceProtocol
// receiveBytes processes bytes forwarded from another interface
-(void)consumeData:(uint8_t*)bytes length:(int)length {
    NSData *data = [NSData dataWithBytes:bytes length:length];
    NSString *aString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];

    NSString *currentString = [aString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSLog(@"iGCSRadioConfig consumeData: %@", currentString);

    [self.buffer appendString:[NSString stringWithFormat:@"%@|", currentString]];
    if (self.hayesResponseState == HayesEnterConfigMode) {
        if ([self.possibleCommands containsObject:currentString]) {
            @synchronized(self) {
                self.hayesResponseState = HayesEnd;
            }

            if ([currentString isEqualToString:@"OK"]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:GCSRadioConfigEnteredConfigMode object:nil];
            }
        }
    } else if (self.hayesResponseState == HayesStart) {
        if ([self.possibleCommands containsObject:currentString]) {
            @synchronized(self) {
                self.hayesResponseState = HayesCommand;
            }
            self.previousHayesResponse = currentString;
            [self dispatchCommandFromQueue];
        }
    } else if (self.hayesResponseState == HayesCommand && self.previousHayesResponse) {
        [self updateModelWithKey:self.previousHayesResponse andValue:currentString];
        self.currentSettings[self.previousHayesResponse] = currentString;
        @synchronized(self) {
            _hayesResponseState = HayesEnd;
            [self dispatchCommandFromQueue];
        }
        self.previousHayesResponse = nil;

    }
}

-(void)produceData:(uint8_t*)bytes length:(int)length {
    NSLog(@"iGCSRadioConfig produceData");
    [super produceData:bytes length:length];
}

-(void) close {
    NSLog(@"iGCSRadioClose: close is a noop");
}

#pragma public mark - Dispatch command batches
-(void)exitConfigMode {
    [self prepareQueueForNewCommands];

    __weak iGCSRadioConfig *weakSelf = self;
    [self.commandQueue addObject:^(){[weakSelf exit];}];

    [self resetBatchTimeoutUsingCommandTimeout:2.0f];
    [self dispatchCommandFromQueue];
}

-(void)enterConfigMode {
    [self prepareQueueForNewCommands];

    __weak iGCSRadioConfig *weakSelf = self;
    [self.commandQueue addObject:^(){[weakSelf sendConfigModeCommand];}];

    [self resetBatchTimeoutUsingCommandTimeout:1.5f];
    [self dispatchCommandFromQueue];
}

-(void)loadSettings{
    [self prepareQueueForNewCommands];

    __weak iGCSRadioConfig *weakSelf = self;
//    [self.commandQueue addObject:^(){[weakSelf boadType];}];
//    [self.commandQueue addObject:^(){[weakSelf boadFrequency];}];
//    [self.commandQueue addObject:^(){[weakSelf boadVersion];}];

//  TODO: need more logic to parse response from this command.
//  eepromParams are currently gathered one by one.
//  [self.commandQueue addObject:^(){[weakSelf eepromParams];}];
//  [self.commandQueue addObject:^(){[weakSelf tdmTimingReport];}];
//
//  [self.commandQueue addObject:^(){[weakSelf RSSIReport];}];
    [self.commandQueue addObject:^(){[weakSelf serialSpeed];}];
    [self.commandQueue addObject:^(){[weakSelf airSpeed];}];
    [self.commandQueue addObject:^(){[weakSelf netId];}];
    [self.commandQueue addObject:^(){[weakSelf transmitPower];}];
//    [self.commandQueue addObject:^(){[weakSelf ecc];}];
    [self.commandQueue addObject:^(){[weakSelf radioVersion];}];
//    [self.commandQueue addObject:^(){[weakSelf mavLink];}];
//    [self.commandQueue addObject:^(){[weakSelf oppResend];}];
    [self.commandQueue addObject:^(){[weakSelf minFrequency];}];
    [self.commandQueue addObject:^(){[weakSelf maxFrequency];}];
//    [self.commandQueue addObject:^(){[weakSelf numberOfChannels];}];
//    [self.commandQueue addObject:^(){[weakSelf dutyCycle];}];
//    [self.commandQueue addObject:^(){[weakSelf listenBeforeTalkRssi];}];

    // Kick things off by sending a command from Queue.
    // Once we get a response back the next command will
    // be sent via the consume data method after we have
    // processed the previous response.
//    [self.commandQueue addObject:^(){[weakSelf save];}];
//    [self.commandQueue addObject:^(){[weakSelf setNetId:400];}];
//    [self.commandQueue addObject:^(){[weakSelf rebootRadio];}];

    [self.commandQueue addObject:^(){[weakSelf RSSIReport];}];
    [self.commandQueue addObject:^(){[weakSelf radioVersion];}];

    [self resetBatchResponseTimer];
    [self dispatchCommandFromQueue];
}

-(void)saveAndReset{
    [self prepareQueueForNewCommands];

    __weak iGCSRadioConfig *weakSelf;
    [self.commandQueue addObject:^(){[weakSelf save];}];
    [self.commandQueue addObject:^(){[weakSelf rebootRadio];}];

    [self resetBatchResponseTimer];
    [self dispatchCommandFromQueue];
}

#pragma mark - Queue, state and timer helpers
-(void)prepareQueueForNewCommands{
    [self.commandQueue removeAllObjects];
}

-(void)resetBatchResponseTimer {
    float commandTimeout = (self.sikAt.hayesMode == AT) ? self.ATCommandTimeout : self.RTCommandTimeout;
    [self resetBatchTimeoutUsingCommandTimeout:commandTimeout];
}

-(void)resetBatchTimeoutUsingCommandTimeout:(float) commandTimeout {
    // set a timeout for the batch
    if (self.batchResponseTimer) {
        [self.batchResponseTimer invalidate];
        self.batchResponseTimer = nil;
    }

    float batchTimeoutInterval = commandTimeout * self.commandQueue.count;

    NSLog(@"Set batch timeout of %f seconds for %ld %@ commands ",
          batchTimeoutInterval,
          (unsigned long)self.commandQueue.count,
          GCSSikHayesModeDescription[AT]);

    self.batchResponseTimer = [NSTimer scheduledTimerWithTimeInterval:batchTimeoutInterval target:self
                                                             selector:@selector(hayesBatchResponseTimeout)
                                                             userInfo:nil repeats:NO];
}

-(void)commandQueueHasEmptied {
    NSLog(@"commandQueueHasEmptied");
    if (_sikAt.hayesMode == RT) {
        _sikAt.hayesMode = AT;
        return;
    }

//    _sikAt.hayesMode = RT;
//    [self loadSettings];
}

#pragma mark - Read radio settings via AT/RT commands
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

#pragma mark - Write radio settings via AT/RT commands
-(void)setNetId:(NSInteger) aNetId {
    [self sendATCommand:[_sikAt setRadioParamCommand:NetId withValue:aNetId]];
}

-(void)enableRSSIDebug {
    [self sendATCommand:[_sikAt enableRSSIDebugCommand]];
}

-(void)disableDebug {
    [self sendATCommand:[_sikAt disableDebugCommand]];
}

-(void)rebootRadio {
    [self sendATCommand:[_sikAt rebootRadioCommand]];
}

-(void)save {
    [self sendATCommand:[_sikAt writeCurrentParamsToEEPROMCommand]];
}

-(void)exit {
    [self sendATCommand:[_sikAt exitATModeCommand]];
}


#pragma mark - Private

-(void)sendConfigModeCommand {
    if (_hayesResponseState != HayesEnd) {
        NSLog(@"Waiting for previous response. Can't send command: %@", @"+++");
        return;
    }

    @synchronized(self) {
        self.hayesResponseState = HayesEnterConfigMode;
    }

    [self.possibleCommands addObject:@"+++"];
    [self.possibleCommands addObject:@"OK"];

    const char* buf;

    // no trailing CRLF for +++ as with AT commands
    buf = [@"+++" cStringUsingEncoding:NSASCIIStringEncoding];
    uint32_t len = (uint32_t)strlen(buf);
    [self produceData:buf length:len];
}

-(void)sendATCommand:(NSString *)atCommand {
    if (_hayesResponseState != HayesEnd) {
        NSLog(@"Waiting for previous response. Can't send command: %@", atCommand);
        return;
    }

    @synchronized(self) {
        self.hayesResponseState = HayesStart;
    }

    [self.possibleCommands addObject:atCommand];
    NSString *command = [NSString stringWithFormat:@"\r\n%@\r\n", atCommand];
    const char* buf;
    buf = [command cStringUsingEncoding:NSASCIIStringEncoding];
    uint32_t len = (uint32_t)strlen(buf);
    [self produceData:buf length:len];
}

-(void)hayesBatchResponseTimeout {
    @synchronized(self) {
        NSLog(@"Timeout for command: %@", self.possibleCommands.lastObject);
        [self.batchResponseTimer invalidate];
        self.batchResponseTimer = nil;
        self.previousHayesResponse = nil;
        self.hayesResponseState = HayesEnd;
        [[NSNotificationCenter defaultCenter] postNotificationName:GCSRadioConfigCommandBatchResponseTimeOut object:self.possibleCommands.lastObject];
    }
}

-(void) dispatchCommandFromQueue {
    if (self.commandQueue.count == 0) {
        [self.batchResponseTimer invalidate];
        self.batchResponseTimer = nil;
        self.previousHayesResponse = nil;
        self.hayesResponseState = HayesEnd;

        NSLog(@"self.currentSettings: %@", self.currentSettings);
        NSLog(@"localSettings: %@", _localRadioSettings);
        NSLog(@"remoteRadioSettings: %@", _remoteRadioSettings);
        if (_sikAt.hayesMode == AT) {
            [[NSNotificationCenter defaultCenter] postNotificationName:GCSRadioConfigCommandQueueHasEmptied object:nil];
        }
        return;
    }

    @synchronized(self) {
        if (_hayesResponseState == HayesEnd) {
            void(^ hayesCommand)() = [self.commandQueue gcs_pop];
            hayesCommand();
        }
    }
}

// brute force
-(void)updateModelWithKey:(NSString *)key andValue:(id) value {
    self.privateSikAt.hayesMode = AT;
    // local radio settings
    if ([key isEqualToString:tShowLocalRadioVersion]) {
        [_localRadioSettings setRadioVersion:value];

    }else if ([key isEqualToString:tShowLocalBoardType]) {
        [_localRadioSettings setBoadType:value];

    }else if ([key isEqualToString:tShowLocalBoardFrequency]) {
        [_localRadioSettings setBoadFrequency:value];

    }else if ([key isEqualToString:tShowLocalBoardVersion]) {
        [_localRadioSettings setBoadVersion:value];

    }else if ([key isEqualToString:tShowLocalTDMTimingReport]) {
        [_localRadioSettings setTdmTimingReport:value];

    }else if ([key isEqualToString:tShowLocalRSSISignalReport]) {
        [_localRadioSettings setRSSIReport:value];

    }else if ([key isEqualToString:[self.privateSikAt showRadioParamCommand:SerialSpeed]]) {
        [_localRadioSettings setSerialSpeed:[value integerValue]];

    }else if ([key isEqualToString:[self.privateSikAt showRadioParamCommand:AirSpeed]]) {
        [_localRadioSettings setAirSpeed:[value integerValue]];

    }else if ([key isEqualToString:[self.privateSikAt showRadioParamCommand:NetId]]) {
        [_localRadioSettings setNetId:[value integerValue]];

    }else if ([key isEqualToString:[self.privateSikAt showRadioParamCommand:TxPower]]) {
        [_localRadioSettings setTransmitterPower:[value integerValue]];

    }else if ([key isEqualToString:[self.privateSikAt showRadioParamCommand:EnableECC]]) {
        [_localRadioSettings setIsECCenabled:[value boolValue]];

    } else if ([key isEqualToString:[self.privateSikAt showRadioParamCommand:MavLink]]) {
        [_localRadioSettings setIsMavlinkEnabled:[value boolValue]];

    } else if ([key isEqualToString:[self.privateSikAt showRadioParamCommand:OppResend]]) {
        [_localRadioSettings setIsOppResendEnabled:[value boolValue]];

    }else if ([key isEqualToString:[self.privateSikAt showRadioParamCommand:MinFrequency]]) {
        [_localRadioSettings setMinFrequency:[value integerValue]];

    }else if ([key isEqualToString:[self.privateSikAt showRadioParamCommand:MaxFrequency]]) {
        [_localRadioSettings setMaxFrequency:[value integerValue]];

    }else if ([key isEqualToString:[self.privateSikAt showRadioParamCommand:NumberOfChannels]]) {
        [_localRadioSettings setNumberOfChannels:[value integerValue]];

    }else if ([key isEqualToString:[self.privateSikAt showRadioParamCommand:DutyCycle]]) {
        [_localRadioSettings setDutyCycle:[value integerValue]];

    } else if ([key isEqualToString:[self.privateSikAt showRadioParamCommand:LbtRssi]]) {
        _localRadioSettings.isListenBeforeTalkRSSIEnabled = value;
        [_localRadioSettings setIsListenBeforeTalkRSSIEnabled:[value boolValue]];
    }

    // remote radio settings
    self.privateSikAt.hayesMode = RT;
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

    }else if ([key isEqualToString:[self.privateSikAt showRadioParamCommand:SerialSpeed]]) {
        _remoteRadioSettings.serialSpeed = [value integerValue];

    }else if ([key isEqualToString:[self.privateSikAt showRadioParamCommand:AirSpeed]]) {
        _remoteRadioSettings.airSpeed = [value integerValue];

    }else if ([key isEqualToString:[self.privateSikAt showRadioParamCommand:NetId]]) {
        _remoteRadioSettings.netId = [value integerValue];

    }else if ([key isEqualToString:[self.privateSikAt showRadioParamCommand:TxPower]]) {
        _remoteRadioSettings.transmitterPower = [value integerValue];

    }else if ([key isEqualToString:[self.privateSikAt showRadioParamCommand:EnableECC]]) {
        _remoteRadioSettings.isECCenabled = [value boolValue];

    } else if ([key isEqualToString:[self.privateSikAt showRadioParamCommand:MavLink]]) {
        _remoteRadioSettings.isMavlinkEnabled = [value boolValue];

    } else if ([key isEqualToString:[self.privateSikAt showRadioParamCommand:OppResend]]) {
        _remoteRadioSettings.isOppResendEnabled = [value boolValue];

    }else if ([key isEqualToString:[self.privateSikAt showRadioParamCommand:MinFrequency]]) {
        _remoteRadioSettings.minFrequency = [value integerValue];

    }else if ([key isEqualToString:[self.privateSikAt showRadioParamCommand:MaxFrequency]]) {
        _remoteRadioSettings.maxFrequency = [value integerValue];

    }else if ([key isEqualToString:[self.privateSikAt showRadioParamCommand:NumberOfChannels]]) {
        _remoteRadioSettings.numberOfChannels = [value integerValue];

    }else if ([key isEqualToString:[self.privateSikAt showRadioParamCommand:DutyCycle]]) {
        _remoteRadioSettings.dutyCycle = [value integerValue];

    } else if ([key isEqualToString:[self.privateSikAt showRadioParamCommand:LbtRssi]]) {
        _remoteRadioSettings.isListenBeforeTalkRSSIEnabled = value;
        
    }

}

@end


