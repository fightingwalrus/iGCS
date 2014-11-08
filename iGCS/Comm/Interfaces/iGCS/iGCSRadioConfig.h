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
    HayesEnteredConfigMode,
    HayesWaitingForEcho,
    HayesWaitingForData,
    HayesReadyForCommand
};

@interface iGCSRadioConfig : CommInterface
// subsclasses must assign this property to use produceData
@property (strong) CommConnectionPool *connectionPool;
@property (strong) GCSRadioSettings *localRadioSettings;
@property (strong) GCSRadioSettings *remoteRadioSettings;
@property (strong) NSMutableDictionary *responses;
@property (readwrite) BOOL isRadioBooted;
@property (readwrite) BOOL isRadioInConfigMode;
@property (readwrite) BOOL isLocalRadioResponding;
@property (readwrite) BOOL isRemoteRadioResponding;
@property (readwrite) BOOL commandHasTimedOut;
// timeout for single AT and RT command roundtrip
@property (nonatomic, readwrite) float ATCommandTimeout;
@property (nonatomic, readwrite) float RTCommandTimeout;

// receiveBytes processes bytes forwarded from another interface
-(void)consumeData:(const uint8_t*)bytes length:(NSUInteger)length;
-(void)produceData:(const uint8_t*)bytes length:(NSUInteger)length;
-(void)close;

// state
@property (readwrite) GCSHayesReponseState hayesResponseState;

@end

// const for NSNotification messages
extern NSString * const GCSRadioConfigCommandQueueHasEmptied;
extern NSString * const GCSRadioConfigCommandBatchResponseTimeOut;
extern NSString * const GCSRadioConfigEnteredConfigMode;
extern NSString * const GCSRadioConfigRadioHasBooted;
extern NSString * const GCSRadioConfigRadioDidSaveAndBoot;
extern NSString * const GCSRadioConfigCommandRetryFailed;
extern NSString * const GCSRadioConfigSentRebootCommand;

