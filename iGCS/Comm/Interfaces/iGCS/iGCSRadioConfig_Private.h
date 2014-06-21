//
//  iGCSRadioConfig_Private.h
//  iGCS
//
//  Created by Andrew Brown on 6/20/14.
//
//

#import "iGCSRadioConfig.h"

typedef void (^HayesWaitingForDataBlock)();

@interface iGCSRadioConfig ()
@property (nonatomic, strong) GCSSikAT *sikAt;
@property (nonatomic, strong) GCSSikAT *privateSikAt;
@property (strong) NSTimer *commandResponseTimer;
@property (strong) NSTimer *batchResponseTimer;
@property (strong) NSMutableArray *sentCommands;
@property (strong) NSArray *responseBuffer;
@property (strong) NSMutableDictionary *currentSettings;
@property (strong) NSString *previousHayesResponse;
@property (readonly) NSInteger retryCount;
@property (readwrite) NSInteger commandRetryCountdown;
@property (nonatomic, copy) HayesWaitingForDataBlock hayesDispatchCommand;

@property (strong) NSMutableArray *completeResponseBuffer;

// Queue of selectors of commands to perform
@property (strong) NSMutableArray *commandQueue;

// helpers and dispatchers
-(void)sendATCommand:(NSString *)atCommand;
-(void)prepareQueueForNewCommands;
-(void)resetBatchTimeoutUsingCommandTimeout:(float) commandTimeout;
-(void)dispatchCommandFromQueue;
-(void)resetBatchResponseTimer;
-(void)sendConfigModeCommand;
@end

