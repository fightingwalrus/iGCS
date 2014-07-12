//
//  iCGCRadioConfig.m
//  iGCS
//
//  Created by Andrew Brown on 9/5/13.
//
//

#import "iGCSRadioConfig.h"
#import "iGCSRadioConfig_Private.h"
#import "iGCSRadioConfig+CommandBatches.h"

NSString * const GCSRadioConfigCommandBatchResponseTimeOut = @"com.fightingwalrus.radioconfig.commandbatch.timeout";
NSString * const GCSRadioConfigEnteredConfigMode = @"com.fightingwalrus.radioconfig.entered.configmode";
NSString * const GCSRadioConfigRadioHasBooted = @"com.fightingwalrus.radioconfig.radiobooted";
NSString * const GCSRadioConfigRadioDidSaveAndBoot = @"com.fightingwalrus.radioconfig.didsaveandboot";
NSString * const GCSRadioConfigCommandRetryFailed = @"com.fightingwalrus.radioconfig.commandretry.failed";
NSString * const GCSRadioConfigSentRebootCommand = @"com.fightingwalrus.radioconfig.sent.rebootcommand";

NSString * const GCSHayesResponseStateDescription[] = {
    [HayesEnterConfigMode] = @"HayesEnterConfigMode",
    [HayesWaitingForEcho] = @"HayesWaitingForEcho",
    [HayesWaitingForData] = @"HayesWaitingForData",
    [HayesReadyForCommand] = @"HayesReadyForCommand"
};

@implementation NSMutableArray (Queue)
-(id)gcs_pop{
    id anObject = [self lastObject];
    [self removeLastObject];
    return anObject;
}

-(id)gcs_shift {
    id anObject = [self objectAtIndex:0];
    [self removeObjectAtIndex:0];
    return anObject;
}

@end


@implementation iGCSRadioConfig

-(id) init {
    self = [super init];
    if (self) {
        // public
        _sikAt = [[GCSSikAT alloc] init];
        _localRadioSettings = [[GCSRadioSettings alloc] init];
        _remoteRadioSettings = [[GCSRadioSettings alloc] init];
        _hayesResponseState = HayesReadyForCommand;
        
        // private
        _privateSikAt = [[GCSSikAT alloc] init];
        _sentCommands = [[NSMutableArray alloc] init];
        _responseBuffer = [[NSArray alloc] init];
        _currentSettings = [[NSMutableDictionary alloc] init];
        _ATCommandTimeout = 3.0; // total time give for send, echo and response cycle to complete once
        _RTCommandTimeout = 5.0f;
        _retryCount = 2;

        _completeResponseBuffer = [[NSMutableArray alloc] init];

        _atCommandQueue = dispatch_queue_create("com.fightingwalrus.hayes.queue", DISPATCH_QUEUE_SERIAL);
        _atCommandSemaphore = dispatch_semaphore_create(1);

    }
    return self;
}

#pragma mark - CommInterfaceProtocol
// receiveBytes processes bytes forwarded from another interface
-(void)consumeData:(uint8_t*)bytes length:(int)length {
    NSLog(@"begin consumeData:");
    [self logCurrentHayesIOState];

    NSData *data = [NSData dataWithBytes:bytes length:length];
    NSString *aString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    NSLog(@"raw consumeData: %@", aString);
    NSString *currentString = [aString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    // reponses are not framed so split them on CR
    NSArray *responsesArray = [currentString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSLog(@"responsesArray: %@", responsesArray);

    self.responseBuffer = responsesArray;
    [self.completeResponseBuffer addObjectsFromArray:responsesArray];

    for (NSString *hayesResponse in self.responseBuffer) {
        if (hayesResponse.length == 0) {
            continue;
        }

        [self handleHayesResponse:hayesResponse];
    }
    NSLog(@"end handleHayesResponse:");
}

-(void)handleHayesResponse:(NSString *)hayesResponse {
    NSLog(@"iGCSRadioConfig handleHayesResponse: %@", hayesResponse);

    if ([hayesResponse rangeOfString:@"BOOTED"].location != NSNotFound) {

        self.isRadioBooted = YES;

        // determine the reason for the reboot
        if (self.sentCommands.count > 1 &&
            [[self.sentCommands gcs_pop] isEqualToString:tRebootLocalRadio] &&
            [[self.sentCommands gcs_pop] rangeOfString:@"&W"].location != NSNotFound) {

            [[NSNotificationCenter defaultCenter] postNotificationName:GCSRadioConfigRadioDidSaveAndBoot object:nil];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:GCSRadioConfigRadioHasBooted object:nil];
        }


        @synchronized(self) {
            self.hayesResponseState = HayesReadyForCommand;
            dispatch_semaphore_signal(self.atCommandSemaphore);
        }

        [self invalidateCommandTimer];
        [self logCurrentHayesIOState];
        NSLog(@"end handleHayesResponse:");
        return;
    }

    if (self.hayesResponseState == HayesEnterConfigMode) {
        if ([self fuzzyContainesString:hayesResponse inArray:self.sentCommands]) {

            if ([hayesResponse rangeOfString:@"OK"].location != NSNotFound) {
                self.isRadioInConfigMode = YES;
                [[NSNotificationCenter defaultCenter] postNotificationName:GCSRadioConfigEnteredConfigMode object:nil];
                [self invalidateCommandTimer];
            }
        }

        @synchronized(self) {
            self.hayesResponseState = HayesReadyForCommand;
            dispatch_semaphore_signal(self.atCommandSemaphore);
        }

        [self invalidateCommandTimer];
        [self logCurrentHayesIOState];

    } else if (self.hayesResponseState == HayesWaitingForEcho) {
        // handle echoed command
        if ([self.sentCommands containsObject:hayesResponse]) {
            self.previousHayesResponse = hayesResponse;

            // manage radio status properties
            if ([hayesResponse rangeOfString:@"AT"].location != NSNotFound) {
                self.isLocalRadioResponding = YES;
            }

            if ([hayesResponse rangeOfString:tExitATMode].location != NSNotFound) {
                self.isRadioInConfigMode = NO;
            }

        } else {
            NSLog(@"Command expected ecgho of %@ got %@ instead,", [self.sentCommands lastObject], hayesResponse);
        }

        @synchronized(self) {
            self.hayesResponseState = HayesWaitingForData;
        }

    } else if (self.hayesResponseState == HayesWaitingForData && self.previousHayesResponse) {
        // handle response from command previously sent
        [self.commandResponseTimer invalidate]; // prevent retry from fireing since we got a response
        [self updateModelWithKey:self.previousHayesResponse andValue:hayesResponse];
        self.currentSettings[self.previousHayesResponse] = hayesResponse;

        if ([self.previousHayesResponse rangeOfString:@"&W"].location != NSNotFound) {
            NSLog(@"Got %@ for %@", hayesResponse, self.previousHayesResponse);
        }

        // update link status
        if ([self.previousHayesResponse rangeOfString:@"RT"].location != NSNotFound) {
            self.isRemoteRadioResponding = YES;
        }

        @synchronized(self) {
            self.hayesResponseState = HayesReadyForCommand;
            dispatch_semaphore_signal(self.atCommandSemaphore);
        }
        self.previousHayesResponse = nil;
    }
    [self logCurrentHayesIOState];
    NSLog(@"end handleHayesResponse:");
}

-(void)produceData:(uint8_t*)bytes length:(int)length {
    NSLog(@"iGCSRadioConfig produceData");
    [super produceData:bytes length:length];
}

-(void) close {
    NSLog(@"iGCSRadioClose: close is a noop");
}

-(BOOL)fuzzyContainesString:(NSString *) string inArray:(NSArray *)array {

    BOOL containstString = NO;
    // probably the last thing added
    for (NSString *aString in [array reverseObjectEnumerator]) {
        if ([string rangeOfString:aString].location != NSNotFound) {
            containstString = YES;
            break;
        }
    }

    return containstString;
}

#pragma mark - Queue, state and timer helpers
-(void)prepareQueueForNewCommandsWithName:(NSString *) name{
    self.commandHasTimedOut = NO;
    [self.sentCommands removeAllObjects];
    self.commandQueueName = name;
}

-(void)logCurrentHayesIOState {
    NSLog(@"---------------------");
    NSLog(@"");
    NSLog(@"HayesResponseState: %@", GCSHayesResponseStateDescription[self.hayesResponseState]);
    NSLog(@"possibleCommands: %@", self.sentCommands);
    NSLog(@"isRadioBooted: %@", (self.isRadioBooted) ? @"YES": @"NO");
    NSLog(@"isRadioInConfigMode: %@", (self.isRadioInConfigMode) ? @"YES": @"NO");
    NSLog(@"isRemoteRadioResponding: %@: ", (self.isRemoteRadioResponding) ? @"YES": @"NO");
    NSLog(@"");
    NSLog(@"---------------------");
}

#pragma mark - Private

-(void)sendConfigModeCommand {

    // if a previous command has timed out we just return
    if (self.commandHasTimedOut) {
        return;
    }

    dispatch_time_t timeout = dispatch_time(0, self.ATCommandTimeout * NSEC_PER_SEC);
    long ret = dispatch_semaphore_wait(self.atCommandSemaphore, timeout);

    if (ret == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.hayesResponseState != HayesReadyForCommand) {
                NSLog(@"Waiting for previous response. Can't send command: %@", @"+++");
                [self logCurrentHayesIOState];
                return;
            }

            @synchronized(self) {
                self.hayesResponseState = HayesEnterConfigMode;
            }

            [self.sentCommands addObject:@"+++"];
            [self.sentCommands addObject:@"OK"];

            const char* buf;

            // no trailing CR for +++ as with AT commands
            buf = [@"+++" cStringUsingEncoding:NSASCIIStringEncoding];
            uint32_t len = (uint32_t)strlen(buf);
            [self produceData:buf length:len];
        });

    } else {
        // by setting commandHasTimedOut to YES all other
        // blocks in the serial queue will return before doing
        // any work
        self.commandHasTimedOut = YES;
    }
}

-(void)sendATCommand:(NSString *)atCommand {

    // if a previous command has timed out we just return
    if (self.commandHasTimedOut) {
        return;
    }

    dispatch_time_t timeout = dispatch_time(0, self.ATCommandTimeout * NSEC_PER_SEC);
    long ret = dispatch_semaphore_wait(self.atCommandSemaphore, timeout);

    // if semiphore was signaled then do work otherwise just fall through
    if(ret == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_hayesResponseState != HayesReadyForCommand) {
                NSLog(@"Waiting for previous response. Can't send command: %@", atCommand);
                [self logCurrentHayesIOState];
                return;
            }

            @synchronized(self) {
                self.hayesResponseState = HayesWaitingForEcho;
            }

            [self.sentCommands addObject:atCommand];
            NSString *command = [NSString stringWithFormat:@"%@\r", atCommand];
            const char* buf;
            buf = [command cStringUsingEncoding:NSASCIIStringEncoding];
            uint32_t len = (uint32_t)strlen(buf);
            [self produceData:buf length:len];
        });

    } else {
        // by setting commandHasTimedOut to YES all other
        // blocks in the queue will return before doing
        // any work
        self.commandHasTimedOut = YES;
    }
}


-(void)invalidateCommandTimer {
    self.previousHayesResponse = nil;
    [self.commandResponseTimer invalidate];
}

// brute force
-(void)updateModelWithKey:(NSString *)key andValue:(id) value {
    self.privateSikAt.hayesMode = AT;
    // local radio settings
    if ([key isEqualToString:tShowLocalRadioVersion]) {
        [_localRadioSettings setRadioVersion:value];

    }else if ([key isEqualToString:tShowLocalBoardType]) {
        [_localRadioSettings setBoardType:value];

    }else if ([key isEqualToString:tShowLocalBoardFrequency]) {
        [_localRadioSettings setBoardFrequency:value];

    }else if ([key isEqualToString:tShowLocalBoardVersion]) {
        [_localRadioSettings setBoardVersion:value];

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
        _remoteRadioSettings.boardType = value;

    }else if ([key isEqualToString:tShowRemoteBoardFrequency]) {
        _remoteRadioSettings.boardFrequency = value;

    }else if ([key isEqualToString:tShowRemoteBoardVersion]) {
        _remoteRadioSettings.boardVersion = value;

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
        _remoteRadioSettings.isListenBeforeTalkRSSIEnabled = [value boolValue];
        
    }

}

@end


