//
//  GCSRadioSettings.h
//  iGCS
//
//  Created by Andrew Brown on 5/7/14.
//
//

#import <Foundation/Foundation.h>

//static NSString *const tShowRadioVersion = @"ATI";
//static NSString *const tShowBoardType = @"ATI2";
//static NSString *const tShowBoardFrequency = @"ATI3";
//static NSString *const tShowBoardVersion = @"ATI4";
//static NSString *const tShowEEPROMParams = @"ATI5";
//static NSString *const tShowTDMTimingReport = @"ATI6";
//static NSString *const tShowRSSISignalReport = @"ATI7";
//static NSString *const tShowRadioParamN = @"ATS{#}?"; // replace {#} with number
//
//static NSString *const tSetRadioParamN = @"ATS{#}={##}"; // replace {#} and {##} with number
//static NSString *const tRebotRadio = @"ATZ";
//static NSString *const tWriteCurrentParamsToEEPROM = @"AT&W";
//static NSString *const tResetToFactoryDefault = @"AT&F";
//static NSString *const tEnableRSSIDebug = @"AT&T=RSSI";
//static NSString *const tEnableTDMDebug = @"AT&T=TDM";
//static NSString *const tDisableDebug = @"AT&T";

@interface GCSRadioSettings : NSObject

@property(nonatomic, strong) NSString *radioVersion;
@property(nonatomic, strong) NSString *boardType;
@property(nonatomic, strong) NSString *boardFrequency;
@property(nonatomic, strong) NSString *boardVersion;
@property(nonatomic, strong) NSString *tdmTimingReport;
@property(nonatomic, strong) NSString *RSSIReport;
@property(nonatomic, readwrite) NSInteger serialSpeed;
@property(nonatomic, readwrite) NSInteger airSpeed;
@property(nonatomic, readwrite) NSInteger netId;
@property(nonatomic, readwrite) NSInteger transmitterPower;
@property(nonatomic, readwrite) BOOL isECCenabled;
@property(nonatomic, readwrite) BOOL isMavlinkEnabled;
@property(nonatomic, readwrite) BOOL isOppResendEnabled;
@property(nonatomic, readwrite) NSInteger minFrequency;
@property(nonatomic, readwrite) NSInteger maxFrequency;
@property(nonatomic, readwrite) NSInteger numberOfChannels;
@property(nonatomic, readwrite) NSInteger dutyCycle;
@property(nonatomic, readwrite) BOOL isListenBeforeTalkRSSIEnabled;

@end
