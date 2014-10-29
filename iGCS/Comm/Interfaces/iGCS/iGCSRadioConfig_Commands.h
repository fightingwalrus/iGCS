//
//  iGCSRadioConfig_Commands.h
//  iGCS
//
//  Created by Andrew Brown on 6/20/14.
//
//

#import "iGCSRadioConfig.h"

@interface iGCSRadioConfig ()

#pragma mark - write radio settings via AT/RT commands
-(void)setNetId:(NSInteger) aNetId withHayesMode:(GCSSikHayesMode) hayesMode;
-(void)setTxPower:(GCSSikPowerLevel)powerLevel;
-(void)enableRSSIDebug;
-(void)disableDebug;
-(void)rebootRadioWithHayesMode:(GCSSikHayesMode) hayesMode;
-(void)saveWithHayesMode:(GCSSikHayesMode) hayesMode;

#pragma mark - read radio settings via AT/RT commands
-(void)radioVersion;
-(void)boardType;
-(void)boardFrequency;
-(void)boardVersion;
-(void)eepromParams;
-(void)tdmTimingReport;
-(void)RSSIReport;
-(void)serialSpeed;
-(void)airSpeed;
-(void)netId;
-(void)transmitPower;
-(void)ecc;
-(void)mavLink;
-(void)oppResend;
-(void)minFrequency;
-(void)maxFrequency;
-(void)numberOfChannels;
-(void)dutyCycle;
-(void)listenBeforeTalkRssi;

#pragma mark - reboot radio (ATZ/RTZ)
-(void)exit;

@end
