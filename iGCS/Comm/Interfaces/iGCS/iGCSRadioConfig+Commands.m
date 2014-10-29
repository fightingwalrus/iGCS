//
//  iGCSRadioConfig+Commands.m
//  iGCS
//
//  Created by Andrew Brown on 6/20/14.
//
//

#import "iGCSRadioConfig+Commands.h"
#import "iGCSRadioConfig_Private.h"

@implementation iGCSRadioConfig (Commands)
#pragma mark - Read radio settings via AT/RT commands
-(void)radioVersion {
    [self sendATCommand:self.sikAt.showRadioVersionCommand];
}

-(void)boardType {
    [self sendATCommand:self.sikAt.showBoardTypeCommand];
}

-(void)boardFrequency {
    [self sendATCommand:self.sikAt.showBoardFrequencyCommand];
}

-(void)boardVersion {
    [self sendATCommand:self.sikAt.showBoardVersionCommand];
}

-(void)eepromParams {
    [self sendATCommand:self.sikAt.showEEPROMParamsCommand];
}

-(void)tdmTimingReport {
    [self sendATCommand:self.sikAt.showTDMTimingReport];
}

-(void)RSSIReport {
    [self sendATCommand:self.sikAt.showRSSISignalReport];
}

-(void)serialSpeed {
    [self sendATCommand:[self.sikAt showRadioParamCommand:SerialSpeed]];
}

-(void)airSpeed {
    [self sendATCommand:[self.sikAt showRadioParamCommand:AirSpeed]];
}

-(void)netId {
    [self sendATCommand:[self.sikAt showRadioParamCommand:NetId]];
}

-(void)transmitPower {
    [self sendATCommand:[self.sikAt showRadioParamCommand:TxPower]];
}

-(void)ecc {
    [self sendATCommand:[self.sikAt showRadioParamCommand:EnableECC]];
}

-(void)mavLink {
    [self sendATCommand:[self.sikAt showRadioParamCommand:MavLink]];
}

-(void)oppResend {
    [self sendATCommand:[self.sikAt showRadioParamCommand:OppResend]];
}

-(void)minFrequency {
    [self sendATCommand:[self.sikAt showRadioParamCommand:MinFrequency]];
}

-(void)maxFrequency {
    [self sendATCommand:[self.sikAt showRadioParamCommand:MaxFrequency]];
}

-(void)numberOfChannels {
    [self sendATCommand:[self.sikAt showRadioParamCommand:NumberOfChannels]];
}

-(void)dutyCycle {
    [self sendATCommand:[self.sikAt showRadioParamCommand:DutyCycle]];
}

-(void)listenBeforeTalkRssi {
    [self sendATCommand:[self.sikAt showRadioParamCommand:LbtRssi]];
}

#pragma mark - Write radio settings via AT/RT commands
-(void)setNetId:(NSInteger) aNetId withHayesMode:(GCSSikHayesMode)hayesMode {
    self.sikAt.hayesMode = hayesMode;
    [self sendATCommand:[self.sikAt setRadioParamCommand:NetId withValue:aNetId]];
}

-(void)setTxPower:(GCSSikPowerLevel)powerLevel {
    [self sendATCommand:[self.sikAt setRadioParamCommand:TxPower withValue:powerLevel]];
}

-(void)enableRSSIDebug {
    [self sendATCommand:[self.sikAt enableRSSIDebugCommand]];
}

-(void)disableDebug {
    [self sendATCommand:[self.sikAt disableDebugCommand]];
}

-(void)rebootRadioWithHayesMode:(GCSSikHayesMode)hayesMode {
    self.sikAt.hayesMode = hayesMode;
    NSString *cmd = [self.sikAt rebootRadioCommand];
    [self sendATCommand:cmd];
    self.hayesResponseState = HayesReadyForCommand;
    [self.commandResponseTimer invalidate];

    [[NSNotificationCenter defaultCenter] postNotificationName:GCSRadioConfigSentRebootCommand object:cmd];
}

-(void)saveWithHayesMode:(GCSSikHayesMode)hayesMode{
    self.sikAt.hayesMode = hayesMode;
    [self sendATCommand:[self.sikAt writeCurrentParamsToEEPROMCommand]];
}

-(void)exit {
    [self sendATCommand:[self.sikAt exitATModeCommand]];
}

@end
