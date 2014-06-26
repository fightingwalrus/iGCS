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
-(void)enterConfigMode;
-(void)loadRadioVersion;
-(void)loadAllSettings;
-(void)loadBasicSettings;
-(void)saveAndResetWithNetID:(NSInteger) netId
               withHayesMode:(GCSSikHayesMode) hayesMode;
@end

// const for NSNotification messages
extern NSString * const GCSRadioConfigBatchNameExitConfigMode;
extern NSString * const GCSRadioConfigBatchNameEnterConfigMode;
extern NSString * const GCSRadioConfigBatchNameLoadRadioVersion;
extern NSString * const GCSRadioConfigBatchNameLoadBasicSettings;
extern NSString * const GCSRadioConfigBatchNameLoadAllSettings;
extern NSString * const GCSRadioConfigBatchNameSaveAndResetWithNetID;

// batch name
extern NSString *const GCSRadioConfigBatchName;