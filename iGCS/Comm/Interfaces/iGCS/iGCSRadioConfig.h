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
    HayesEnterConfigMode,
    HayesWaitingForEcho,
    HayesWaitingForData,
    HayesReadyForCommand
};

NS_OPTIONS(NSInteger, GCSRadioLinkState) {
    LocalRadioResponding  = 1 << 0,
    RemoteRadioResponding = 1 << 1
};

@interface iGCSRadioConfig : CommInterface
// subsclasses must assign this property to use produceData
@property (nonatomic, strong) GCSSikAT *sikAt;
@property (strong) CommConnectionPool *connectionPool;
@property (strong) GCSRadioSettings *localRadioSettings;
@property (strong) GCSRadioSettings *remoteRadioSettings;
@property (strong) NSMutableDictionary *responses;
@property (readwrite) BOOL isRadioBooted;
@property (readwrite) BOOL isRadioInConfigMode;

// timeout for single AT and RT command roundtrip
@property (nonatomic, readwrite) float ATCommandTimeout;
@property (nonatomic, readwrite) float RTCommandTimeout;

// receiveBytes processes bytes forwarded from another interface
-(void)consumeData:(uint8_t*)bytes length:(int)length;
-(void)produceData:(uint8_t*)bytes length:(int)length;
-(void)close;

// state
@property (readwrite) GCSHayesReponseState hayesResponseState;
@property (readwrite) enum GCSRadioLinkState radioLinkState;

// all methods use local radio by default

#pragma mark - read radio settings via AT/RT commands
-(void)sendConfigModeCommand;
-(void)enterConfigMode;
-(void)exitConfigMode;

-(void)loadRadioVersion;
-(void)loadSettings;
-(void)saveAndResetWithNetID:(NSInteger) netId;

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
-(void)setNetId:(NSInteger) aNetId withHayesMode:(GCSSikHayesMode) hayesMode;
-(void)enableRSSIDebug;
-(void)disableDebug;
-(void)rebootRadioWithHayesMode:(GCSSikHayesMode) hayesMode;
-(void)saveWithHayesMode:(GCSSikHayesMode) hayesMode;
@end

// const for NSNotification messages
extern NSString * const GCSRadioConfigCommandQueueHasEmptied;
extern NSString * const GCSRadioConfigCommandBatchResponseTimeOut;
extern NSString * const GCSRadioConfigEnteredConfigMode;
extern NSString * const GCSRadioConfigRadioHasBooted;
extern NSString * const GCSRadioConfigCommandRetryFailed;

