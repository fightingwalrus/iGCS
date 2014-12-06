//
//  iGCSRadioConfig+CommandBatches.h
//  iGCS
//
//  Created by Andrew Brown on 6/20/14.
//
//

#import "iGCSRadioConfig.h"


@interface iGCSRadioConfig (CommandBatches)
-(void)exitConfigMode;
-(void)checkForPairedRemoteRadio;
-(void)enterConfigMode;
-(void)loadRadioVersion;
-(void)loadAllSettings;
-(void)loadBasicSettings;
-(void)saveAndResetWithNetID:(NSInteger) netId
               withHayesMode:(GCSSikHayesMode) hayesMode;
@end

// consts for NSNotification messages
extern NSString * const GCSRadioConfigBatchNameExitConfigMode;
extern NSString * const GCSRadioConfigBatchNameExitConfigMode;
extern NSString * const GCSRadioConfigBatchNameEnterConfigMode;
extern NSString * const GCSRadioConfigBatchNameLoadRadioVersion;
extern NSString * const GCSRadioConfigBatchNameLoadBasicSettings;
extern NSString * const GCSRadioConfigBatchNameLoadAllSettings;
extern NSString * const GCSRadioConfigBatchNameSaveAndResetWithNetID;

// consts for use as userInfo dict keys when sending NSNotifications
extern NSString * const GCSRadioConfigBatchName;
extern NSString * const GCSRadioConfigHayesResponseStateKey;
extern NSString * const GCSRadioConfigIsRadioBootedKey;
extern NSString * const GCSRadioConfigIsRadioInConfigModeKey;
extern NSString * const GCSRadioConfigIsRemoteRadioRespondingKey;
extern NSString * const GCSRadioConfigCommandHasTimedOutKey;