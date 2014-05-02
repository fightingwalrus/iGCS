//
//  GCSHayesAT.m
//  iGCS
//
//  Created by Andrew Brown on 4/11/14.
//
//

#import "GCSSikAT.h"
// Implement this flavor of AT commands
//http://code.google.com/p/ardupilot-mega/wiki/3DRadio

// Replace AT with RT for remote radio command
static NSString *const tShowRadioVersion = @"ATI";
static NSString *const tShowBoardType = @"ATI2";
static NSString *const tShowBoardFrequency = @"ATI3";
static NSString *const tShowBoardVersion = @"ATI4";
static NSString *const tShowEEPROMParams = @"ATI5";
static NSString *const tShowTDMTimingReport = @"ATI6";
static NSString *const tShowRSSISignalReport = @"ATI7";
static NSString *const tShowRadioParamN = @"ATS{#}?"; // replace {#} with number
static NSString *const tSetRadioParamN = @"ATS{#}={##}"; // replace {#} and {##} with number
static NSString *const tRebotRadio = @"ATZ";
static NSString *const tWriteCurrentParamsToEEPROM = @"AT&W";
static NSString *const tResetToFactoryDefault = @"AT&F";
static NSString *const tEnableRSSIDebug = @"AT&T=RSSI";
static NSString *const tEnableTDMDebug = @"AT&T=TDM";
static NSString *const tDisableDebug = @"AT&T";


// Cannot be used with remote radio. (No RT0)
static NSString *const tExitATMode = @"AT0";
static NSString *const tEnableBootloaderMode = @"AT&UPDATE"; // in this mode radio will accept firmware update

//The first column is the S register to set if you want to change that parameter. So for example, to set the transmit power to 10dBm, use 'ATS4=10'.
//
//Most parameters only take effect on the next reboot. So the usual pattern is to set the parameters you want, then use 'AT&W' to write the parameters to EEPROM, then reboot using 'ATZ'. The exception is the transmit power, which changes immediately (although it will revert to the old setting on reboot unless you use AT&W).
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


#pragma mark - convenience methods
-(NSString *)showNetIDCommand {
    NSString *cmd = [self showRadioParamCommand:NetId];
    return cmd;
}

-(NSString *)setNetIdCommandWithNetId:(NSInteger) netId {
    NSString *cmd = [self setRadioParamCommand:NetId withValue:netId];
    return cmd;
}

#pragma mark - public AT/RT commands

-(NSString *)showRadioVersionCommand {
    if (_hayesMode == AT) {
        return tShowRadioVersion;
    }

    return [self RTFromAT:tShowRadioVersion];
}

-(NSString *)showBoardTypeCommand {
    if (_hayesMode == AT) {
        return tShowBoardType;
    }

    return [self RTFromAT:tShowBoardType];
}

-(NSString *)showBoardFrequencyCommand {
    if (_hayesMode == AT) {
        return tShowBoardFrequency;
    }

    return [self RTFromAT:tShowBoardFrequency];
}

-(NSString *)showBoardVersionCommand {
    if (_hayesMode == AT) {
        return tShowBoardVersion;
    }

    return [self RTFromAT:tShowBoardVersion];
}

-(NSString *)showEEPROMParamsCommand {
    if (_hayesMode == AT) {
        return tShowEEPROMParams;
    }

    return [self RTFromAT:tShowEEPROMParams];
}


-(NSString *)showTDMTimingReport {
    if (_hayesMode == AT) {
        return tShowTDMTimingReport;
    }

    return [self RTFromAT:tShowTDMTimingReport];
}

-(NSString *)showRSSISignalReport {
    if (_hayesMode == AT) {
        return tShowRSSISignalReport;
    }

    return [self RTFromAT:tShowRSSISignalReport];
}

-(NSString *)showRadioParamCommand:(GCSSikSRegister ) aRegister {
    NSString *cmd;
    if (_hayesMode == AT) {
        cmd = tShowRadioParamN;
    } else {
        cmd = [self RTFromAT:tShowRadioParamN];
    }

    cmd = [cmd stringByReplacingOccurrencesOfString:@"{#}"
                                                 withString:[@(aRegister) stringValue]];
    return cmd;
}

-(NSString *)setRadioParamCommand:(GCSSikSRegister ) aRegister
               withValue:(NSInteger) value{

    NSString *cmd;
    if (_hayesMode == AT) {
        cmd = tSetRadioParamN;
    } else {
        cmd = [self RTFromAT:tSetRadioParamN];
    }

    cmd = [cmd stringByReplacingOccurrencesOfString:@"{#}"
                                         withString:[@(aRegister) stringValue]];

    cmd = [cmd stringByReplacingOccurrencesOfString:@"{##}" withString:[@(value) stringValue]];

    return cmd;
}

-(NSString *)rebootRadioCommand {
    if (_hayesMode == AT) {
        return tRebotRadio;
    }

    return [self RTFromAT:tRebotRadio];
}

-(NSString *)writeCurrentParamsToEEPROMCommand {
    if (_hayesMode == AT) {
        return tWriteCurrentParamsToEEPROM;
    }

    return [self RTFromAT:tWriteCurrentParamsToEEPROM];
}

-(NSString *)resetToFactoryDefaultCommand {
    if (_hayesMode == AT) {
        return tResetToFactoryDefault;
    }

    return [self RTFromAT:tResetToFactoryDefault];
}

-(NSString *)enableRSSIDebugCommand {
    if (_hayesMode == AT) {
        return tEnableRSSIDebug;
    }

    return [self RTFromAT:tEnableRSSIDebug];
}

-(NSString *)enableTDMDebugCommand {
    if (_hayesMode == AT) {
        return tEnableTDMDebug;
    }

    return [self RTFromAT:tEnableTDMDebug];
}

-(NSString *)disableDebugCommand {
    if (_hayesMode == AT) {
        return tDisableDebug;
    }

    return [self RTFromAT:tDisableDebug];

}

// cannot use in RT mode...
-(NSString *)exitATModeCommand {
    return tExitATMode;
}

// allows you to upload new firmware.
-(NSString *)enableBootloaderModeCommand {
    return tEnableBootloaderMode;
}

#pragma mark - helpers
-(NSString *)RTFromAT:(NSString *)at {
    return [at stringByReplacingOccurrencesOfString:@"AT" withString:@"RT"];
}

@end
