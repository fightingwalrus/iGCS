//
//  GCSHayesAT.m
//  iGCS
//
//  Created by Andrew Brown on 4/11/14.
//
//

#import "GCSSikAT.h"

// notes from docs...
// The first column is the S register to set if you want to change that parameter.
// So for example, to set the transmit power to 10dBm, use 'ATS4=10'.
// Most parameters only take effect on the next reboot. So the usual pattern
// is to set the parameters you want, then use 'AT&W' to write the parameters to EEPROM,
// then reboot using 'ATZ'. The exception is the transmit power, which changes immediately
// (although it will revert to the old setting on reboot unless you use AT&W).
//

@interface GCSSikAT () {
    NSArray *_matchRegisters;
}

@end


@implementation GCSSikAT

-(id) init {
    self = [super init];
    if (self) {
        // registers that *must* match on both of the connected radios
        // for things to work. The radios firmware must also match.
        _matchRegisters = @[@(AirSpeed), @(MinFrequency), @(MaxFrequency),
                              @(NumberOfChannels), @(NetId), @(EnableECC), @(LbtRssi)];

        // default is AT in order to work with the locally connected radio
        _hayesMode = AT;
    }
    return self;
}


#pragma mark - public AT/RT commands

-(NSString *)showRadioVersionCommand {
    if (_hayesMode == AT) {
        return tShowLocalRadioVersion;
    }

    return tShowRemoteRadioVersion;
}

-(NSString *)showBoardTypeCommand {
    if (_hayesMode == AT) {
        return tShowLocalBoardType;
    }

    return tShowRemoteBoardType;
}

-(NSString *)showBoardFrequencyCommand {
    if (_hayesMode == AT) {
        return tShowLocalBoardFrequency;
    }

    return tShowRemoteBoardFrequency;
}

-(NSString *)showBoardVersionCommand {
    if (_hayesMode == AT) {
        return tShowLocalBoardVersion;
    }

    return tShowRemoteBoardVersion;
}

-(NSString *)showEEPROMParamsCommand {
    if (_hayesMode == AT) {
        return tShowLocalEEPROMParams;
    }

    return tShowRemoteEEPROMParams;
}


-(NSString *)showTDMTimingReport {
    if (_hayesMode == AT) {
        return tShowLocalTDMTimingReport;
    }

    return tShowRemoteTDMTimingReport;
}

-(NSString *)showRSSISignalReport {
    if (_hayesMode == AT) {
        return tShowLocalRSSISignalReport;
    }

    return tShowRemoteRSSISignalReport;
}

-(NSString *)showRadioParamCommand:(GCSSikSRegister ) aRegister {
    NSString *cmd;
    if (_hayesMode == AT) {
        cmd = tShowLocalRadioParamN;
    } else {
        cmd = tShowRemoteRadioParamN;
    }

    cmd = [cmd stringByReplacingOccurrencesOfString:@"{#}"
                                                 withString:[@(aRegister) stringValue]];
    return cmd;
}

-(NSString *)setRadioParamCommand:(GCSSikSRegister ) aRegister
               withValue:(NSInteger) value{

    NSString *cmd;
    if (_hayesMode == AT) {
        cmd = tSetLocalRadioParamN;
    } else {
        cmd = tSetRemoteRadioParamN;
    }

    cmd = [cmd stringByReplacingOccurrencesOfString:@"{#}"
                                         withString:[@(aRegister) stringValue]];

    cmd = [cmd stringByReplacingOccurrencesOfString:@"{##}" withString:[@(value) stringValue]];

    return cmd;
}

-(NSString *)rebootRadioCommand {
    if (_hayesMode == AT) {
        return tRebootLocalRadio;
    }

    return tRebootRemoteRadio;
}

-(NSString *)writeCurrentParamsToEEPROMCommand {
    if (_hayesMode == AT) {
        return tWriteCurrentParamsToLocalRadioEEPROM;
    }

    return tWriteCurrentParamsToRemoteRadioEEPROM;
}

-(NSString *)resetToFactoryDefaultCommand {
    if (_hayesMode == AT) {
        return tResetLocalRadioToFactoryDefault;
    }

    return tResetRemoteRadioToFactoryDefault;
}

-(NSString *)enableRSSIDebugCommand {
    if (_hayesMode == AT) {
        return tEnableLocalRadioRSSIDebug;
    }

    return tEnableRemoteRadioRSSIDebug;
}

-(NSString *)enableTDMDebugCommand {
    if (_hayesMode == AT) {
        return tEnableLocalRadioTDMDebug;
    }

    return tEnableLocalRadioTDMDebug;
}

-(NSString *)disableDebugCommand {
    if (_hayesMode == AT) {
        return tDisableLocalRadioDebug;
    }

    return tDisableRemoteRadioDebug;
}

// cannot use in RT mode...
-(NSString *)exitATModeCommand {
    return tExitATMode;
}

// allows you to upload new firmware.
-(NSString *)enableBootloaderModeCommand {
    if (_hayesMode == AT) {
        return tEnableLocalRadioBootloaderMode;
    }

    return tEnableRemoteRadioBootloaderMode;
}

@end
