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
-(void)loadSettings;
-(void)saveAndResetWithNetID:(NSInteger) netId
               withHayesMode:(GCSSikHayesMode) hayesMode;
@end
