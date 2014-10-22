//
//  GCSHayesAT.m
//  iGCS
//
//  Created by Andrew Brown on 4/11/14.
//
//

#import "GCSSikAT.h"

NSString *const GCSSikHayesModeKeyName = @"GCSSkikHayesModeKey";

NSString *const GCSSikHayesModeDescription[] = {
    [AT] = @"AT",
    [RT] = @"RT"
};

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

-(instancetype) init {
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
    return (self.hayesMode == AT) ? tShowLocalRadioVersion: tShowRemoteRadioVersion;
}

-(NSString *)showBoardTypeCommand {
    return (self.hayesMode == AT) ? tShowLocalBoardType: tShowRemoteBoardType;
}

-(NSString *)showBoardFrequencyCommand {
    return (self.hayesMode == AT) ? tShowLocalBoardFrequency: tShowRemoteBoardFrequency;
}

-(NSString *)showBoardVersionCommand {
    return (self.hayesMode == AT) ? tShowLocalBoardVersion: tShowRemoteBoardVersion;
}

-(NSString *)showEEPROMParamsCommand {
    return (self.hayesMode == AT) ? tShowLocalEEPROMParams: tShowRemoteEEPROMParams;
}

-(NSString *)showTDMTimingReport {
    return (self.hayesMode == AT) ? tShowLocalTDMTimingReport: tShowRemoteTDMTimingReport;
}

-(NSString *)showRSSISignalReport {
    return (self.hayesMode == AT) ? tShowLocalRSSISignalReport: tShowRemoteRSSISignalReport;
}

-(NSString *)showRadioParamCommand:(GCSSikSRegister ) aRegister {
    NSString *cmd = (self.hayesMode == AT) ? tShowLocalRadioParamN: tShowRemoteRadioParamN;
    return [NSString stringWithFormat:cmd, aRegister];
}

-(NSString *)setRadioParamCommand:(GCSSikSRegister ) aRegister
               withValue:(NSInteger) value{
    NSString *cmd = (self.hayesMode == AT) ? tSetLocalRadioParamN: tSetRemoteRadioParamN;
    return [NSString stringWithFormat:cmd, aRegister, value];
}

-(NSString *)rebootRadioCommand {
    return (self.hayesMode == AT) ? tRebootLocalRadio: tRebootRemoteRadio;
}

-(NSString *)writeCurrentParamsToEEPROMCommand {
    return (self.hayesMode == AT) ? tWriteCurrentParamsToLocalRadioEEPROM: tWriteCurrentParamsToRemoteRadioEEPROM;
}

-(NSString *)resetToFactoryDefaultCommand {
    return (self.hayesMode == AT) ? tResetLocalRadioToFactoryDefault: tResetRemoteRadioToFactoryDefault;
}

-(NSString *)enableRSSIDebugCommand {
    return (self.hayesMode == AT) ? tEnableLocalRadioRSSIDebug: tEnableRemoteRadioRSSIDebug;
}

-(NSString *)enableTDMDebugCommand {
    return (self.hayesMode == AT) ? tEnableLocalRadioTDMDebug: tEnableLocalRadioTDMDebug;
}

-(NSString *)disableDebugCommand {
    return (self.hayesMode == AT) ? tDisableLocalRadioDebug: tDisableRemoteRadioDebug;
}

// cannot use in RT mode...
-(NSString *)exitATModeCommand {
    return tExitATMode;
}

// allows you to upload new firmware.
-(NSString *)enableBootloaderModeCommand {
    return (self.hayesMode == AT) ? tEnableLocalRadioBootloaderMode: tEnableRemoteRadioBootloaderMode;
}

@end
