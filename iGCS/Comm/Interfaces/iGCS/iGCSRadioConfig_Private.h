//
//  iGCSRadioConfig_Private.h
//  iGCS
//
//  Created by Andrew Brown on 6/20/14.
//
//

#import "iGCSRadioConfig.h"

typedef void (^HayesDispatchBlock)(NSObject *);

@interface iGCSRadioConfig ()
@property (nonatomic, strong) GCSSikAT *sikAt;
@property (nonatomic, strong) GCSSikAT *privateSikAt;
@property (strong) NSTimer *commandResponseTimer;
@property (strong) NSMutableArray *sentCommands;
@property (strong) NSArray *responseBuffer;
@property (strong) NSMutableDictionary *currentSettings;
@property (strong) NSString *previousHayesResponse;
@property (readonly) NSInteger retryCount;
@property (readwrite) NSInteger commandRetryCountdown;
@property (nonatomic, copy) HayesDispatchBlock hayesDispatchCommand;
@property (nonatomic, readwrite) dispatch_queue_t atCommandQueue;
@property (nonatomic, readwrite) dispatch_semaphore_t atCommandSemaphore;
@property (strong) NSMutableArray *completeResponseBuffer;

// Queue of selectors of commands to perform
@property (strong) NSMutableArray *commandQueue;
@property (strong) NSString *commandQueueName;

// helpers and dispatchers
-(void)sendATCommand:(NSString *)atCommand;
-(void)prepareQueueForNewCommandsWithName:(NSString *) name;
-(void)sendConfigModeCommand;
@end

