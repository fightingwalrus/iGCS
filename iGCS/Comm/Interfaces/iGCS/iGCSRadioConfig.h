//
//  iCGCRadioConfig.h
//  iGCS
//
//  Created by Andrew Brown on 9/5/13.
//
//

#import "CommInterface.h"
#import "GCSRadioSettings.h"

#import "GCSSikAT.h"

typedef NS_ENUM(NSUInteger, GCSHayesReponseState) {
    HayesStart,
    HayesCommand,
    HayesEnd,
};

@interface iGCSRadioConfig : CommInterface
// subsclasses must assign this property to use produceData
@property (strong) CommConnectionPool *connectionPool;
@property (nonatomic, strong) GCSSikAT *sikAt;
@property (nonatomic, strong) GCSRadioSettings *localRadioSettings;
@property (nonatomic, strong) GCSRadioSettings *remoteRadioSettings;
@property (nonatomic, strong) NSMutableDictionary *responses;

// receiveBytes processes bytes forwarded from another interface
-(void)consumeData:(uint8_t*)bytes length:(int)length;
-(void)produceData:(uint8_t*)bytes length:(int)length;
-(void)close;

// state
@property (readwrite) GCSHayesReponseState hayesResponseState;

// all methods use local radio by default

#pragma mark - read radio settings via AT/RT commands
// read all settings
-(void)loadSettings;
-(void)saveAndReset;

-(void)radioVersion;
-(void)boadType;
-(void)boadFrequency;
-(void)boadVersion;
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

#pragma mark - write radio settings via AT/RT commands
-(void)setNetId:(NSInteger) aNetId;
-(void)enableRSSIDebug;
-(void)disableDebug;
-(void)rebootRadio;
-(void)save;

@end

// const for NSNotification messages
extern NSString * const GCSRadioConfigCommandQueueHasEmptied;
