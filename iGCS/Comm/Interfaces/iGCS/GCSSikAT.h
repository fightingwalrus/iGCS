//
//  GCSHayesAT.h
//  iGCS
//
//  Created by Andrew Brown on 4/11/14.
//
//

#import <Foundation/Foundation.h>

// Implement flavor of AT commands for Sik firmware
// http://code.google.com/p/ardupilot-mega/wiki/3DRadio

// Local radio constants (AT)
static NSString *const tShowLocalRadioVersion = @"ATI";
static NSString *const tShowLocalRadioVersionNumber = @"ATI1"; // returns just the version number
static NSString *const tShowLocalBoardType = @"ATI2";
static NSString *const tShowLocalBoardFrequency = @"ATI3";
static NSString *const tShowLocalBoardVersion = @"ATI4";
static NSString *const tShowLocalEEPROMParams = @"ATI5";
static NSString *const tShowLocalTDMTimingReport = @"ATI6";
static NSString *const tShowLocalRSSISignalReport = @"ATI7";
static NSString *const tShowLocalFWSikVersionNumber = @"ATI9";

static NSString *const tShowLocalRadioParamN = @"ATS{#}?"; // replace {#} with number

static NSString *const tSetLocalRadioParamN = @"ATS{#}={##}"; // replace {#} and {##} with number
static NSString *const tRebootLocalRadio = @"ATZ";
static NSString *const tWriteCurrentParamsToLocalRadioEEPROM = @"AT&W";
static NSString *const tResetLocalRadioToFactoryDefault = @"AT&F";
static NSString *const tEnableLocalRadioRSSIDebug = @"AT&T=RSSI";
static NSString *const tEnableLocalRadioTDMDebug = @"AT&T=TDM";
static NSString *const tDisableLocalRadioDebug = @"AT&T";
static NSString *const tEnableLocalRadioBootloaderMode = @"AT&UPDATE"; // in this mode radio will accept firmware update
static NSString *const tExitATMode = @"ATO";  // Cannot be used with remote radio. (No RTO)

// Remote radio commands (RT)
static NSString *const tShowRemoteRadioVersion = @"RTI";
static NSString *const tShowRemoteBoardType = @"RTI2";
static NSString *const tShowRemoteBoardFrequency = @"RTI3";
static NSString *const tShowRemoteBoardVersion = @"RTI4";
static NSString *const tShowRemoteEEPROMParams = @"RTI5";
static NSString *const tShowRemoteTDMTimingReport = @"RTI6";
static NSString *const tShowRemoteRSSISignalReport = @"RTI7";
static NSString *const tShowRemoteRadioParamN = @"RTS{#}?"; // replace {#} with number

static NSString *const tSetRemoteRadioParamN = @"RTS{#}={##}"; // replace {#} and {##} with number
static NSString *const tRebootRemoteRadio = @"RTZ";
static NSString *const tWriteCurrentParamsToRemoteRadioEEPROM = @"RT&W";
static NSString *const tResetRemoteRadioToFactoryDefault = @"RT&F";
static NSString *const tEnableRemoteRadioRSSIDebug = @"RT&T=RSSI";
static NSString *const tEnableRemoteRadioTDMDebug = @"RT&T=TDM";
static NSString *const tDisableRemoteRadioDebug = @"RT&T";
static NSString *const tEnableRemoteRadioBootloaderMode = @"RT&UPDATE"; // in this mode radio will accept firmware update

extern NSString *const GCSSikHayesModeKeyName;

typedef NS_ENUM(NSUInteger, GCSSikHayesMode) {
    AT,
    RT
};

typedef NS_ENUM(NSUInteger, GCSSikSRegister) {
    EEPROMFormatVersion = 0,    // EEPROM format version. Do not change
    SerialSpeed         = 1,    // data rate in 'one byte form' - this will be hard codded for FWR etc
    AirSpeed            = 2,    // data rate in 'one byte form' (int represending baud rate) in kbps
    NetId               = 3,    // network id. Needs to match on the Rx Side.
    TxPower             = 4,    // transmit power in dBm. 20dBm max.
    EnableECC           = 5,    // enable error correcting code
    MavLink             = 6,    // enable mavlink
    OppResend           = 7,    // ??
    MinFrequency        = 8,    // in kHx
    MaxFrequency        = 9,    // in kHz
    NumberOfChannels    = 10,   // total number of channels for freqency hopping
    DutyCycle           = 11,   // percent time for transmit
    LbtRssi             = 12,   // Listen Before Talk
    Manchester          = 13,   // ??
    Rtscts              = 14    // ??
};


// Possible serial speeds in one byte form (kbps)
typedef NS_ENUM(NSInteger, GCSSikATSerialSpeed) {
    GCSSikATSerialSpeed1    = 1,    // 1200
    GCSSikATSerialSpeed2    = 2,    // 2400
    GCSSikATSerialSpeed4    = 4,    // 4800
    GCSSikATSerialSpeed9    = 9,    // 9600
    GCSSikATSerialSpeed19   = 19,   // 19200
    GCSSikATSerialSpeed38   = 38,   // 38400
    GCSSikATSerialSpeed57   = 57,   // 57600 - default speed
    GCSSikATSerialSpeed115  = 115,  // 115200
    GCSSikATSerialSpeed230  = 230   // 230400
};

// possible radio airspeeds in one byte form (kbps)
typedef NS_ENUM(NSUInteger, GCSSikAirSpeed) {
    GCSSikAirSpeed2     = 2,
    GCSSikAirSpeed4     = 4,
    GCSSikAirSpeed8     = 8,
    GCSSikAirSpeed16    = 16,
    GCSSikAirSpeed19    = 19,
    GCSSikAirSpeed24    = 24,
    GCSSikAirSpeed32    = 32,
    GCSSikAirSpeed48    = 48,
    GCSSikAirSpeed64    = 64, // default speed
    GCSSikAirSpeed96    = 96,
    GCSSikAirSpeed128   = 128,
    GCSSikAirSpeed192   = 192,
    GCSSikAirSpeed250   = 250
};

// possible power level in dBm
typedef NS_ENUM(NSUInteger, GCSSikPowerLevel) {
    GCSSiKPowerLevel1   =   1,
    GCSSiKPowerLevel2   =   2,
    GCSSiKPowerLevel5   =   5,
    GCSSiKPowerLevel8   =   8,
    GCSSiKPowerLevel11  =   1,
    GCSSiKPowerLevel14  =   14,
    GCSSiKPowerLevel17  =   17,
    GCSSiKPowerLevel20  =   20
};

extern NSString * const GCSSikHayesModeDescription[];

@interface GCSSikAT : NSObject
@property (nonatomic, readwrite) GCSSikHayesMode hayesMode;

#pragma mark - public AT/RT commands
-(NSString *)showRadioVersionCommand;
-(NSString *)showBoardTypeCommand;
-(NSString *)showBoardFrequencyCommand;
-(NSString *)showBoardVersionCommand;
-(NSString *)showEEPROMParamsCommand;
-(NSString *)showTDMTimingReport;
-(NSString *)showRSSISignalReport;
-(NSString *)showRadioParamCommand:(GCSSikSRegister)aRegister;

-(NSString *)setRadioParamCommand:(GCSSikSRegister)aRegister
                        withValue:(NSInteger)value;
-(NSString *)rebootRadioCommand;
-(NSString *)writeCurrentParamsToEEPROMCommand;
-(NSString *)resetToFactoryDefaultCommand;
-(NSString *)enableRSSIDebugCommand;
-(NSString *)enableTDMDebugCommand;
-(NSString *)disableDebugCommand;

// cannot use in RT mode...
-(NSString *)exitATModeCommand;
@end