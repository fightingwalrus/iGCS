//
//  GCSHayesAT.h
//  iGCS
//
//  Created by Andrew Brown on 4/11/14.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, GCSSikHayesMode) {
    AT,
    RT
};


typedef NS_ENUM(NSUInteger, GCSSikSRegister) {
    EEPROMFormatVersion = 0, // EEPROM format version. Do not change
    SerialSpeed = 1, // data rate in 'one byte form' - this will be hard codded for FWR etc
    AirSpeed = 2, // data rate in 'one byte form' (int represending baud rate) in kbps
    NetId = 3, // network id. Needs to match on the Rx Side.
    TxPower = 4, // transmit power in dBm. 20dBm max.
    EnableECC = 5, // enable error correcting code
    MavLink = 6, // enable mavlink
    OppResend = 7, // ??
    MinFrequency = 8, // in kHx
    MaxFrequency = 9, // in kHz
    NumberOfChannels = 10, // total number of channels for freqency hopping
    DutyCycle = 11, // percent time for transmit
    LbtRssi = 12 // Listen Before Talk
};

// Possible serial speeds in one byte form (kbps)
typedef NS_ENUM(NSInteger, GCSSikATSerialSpeed) {
    GCSSikATSerialSpeed1 = 1,
    GCSSikATSerialSpeed2 = 2,
    GCSSikATSerialSpeed4 = 4,
    GCSSikATSerialSpeed9 = 9,
    GCSSikATSerialSpeed19 = 19,
    GCSSikATSerialSpeed38 = 38,
    GCSSikATSerialSpeed57 = 57,
    GCSSikATSerialSpeed115 = 115
};

// possible radio airspeeds in one byte form (kbps)
typedef NS_ENUM(NSUInteger, GCSSikAirSpeed) {
    GCSSikAirSpeed2 = 2,
    GCSSikAirSpeed4 = 4,
    GCSSikAirSpeed8 = 8,
    GCSSikAirSpeed16 = 16,
    GCSSikAirSpeed19 = 19,
    GCSSikAirSpeed24 = 24,
    GCSSikAirSpeed32 = 32,
    GCSSikAirSpeed48 = 48,
    GCSSikAirSpeed64 = 64, // default
    GCSSikAirSpeed96 = 96,
    GCSSikAirSpeed128 = 128,
    GCSSikAirSpeed192 = 192,
    GCSSikAirSpeed250 = 250
};

// possible power level in dBm
typedef NS_ENUM(NSUInteger, GCSSikPowerLevel) {
    GCSSiKPowerLevel1 = 1,
    GCSSiKPowerLevel2 = 2,
    GCSSiKPowerLevel5 = 5,
    GCSSiKPowerLevel8 = 8,
    GCSSiKPowerLevel11 = 11,
    GCSSiKPowerLevel14 = 14,
    GCSSiKPowerLevel17 = 17,
    GCSSiKPowerLevel20 = 20
};

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
-(NSString *)showRadioParamCommand:(GCSSikSRegister ) aRegister;

-(NSString *)setRadioParamCommand:(GCSSikSRegister ) aRegister withValue:(NSInteger)value;
-(NSString *)rebootRadioCommand;
-(NSString *)writeCurrentParamsToEEPROMCommand;
-(NSString *)resetToFactoryDefaultCommand;
-(NSString *)enableRSSIDebugCommand;
-(NSString *)enableTDMDebugCommand;
-(NSString *)disableDebugCommand;

// cannot use in RT mode...
-(NSString *)exitATModeCommand;
@end