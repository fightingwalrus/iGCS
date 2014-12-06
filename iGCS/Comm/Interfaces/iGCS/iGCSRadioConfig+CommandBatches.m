//
//  iGCSRadioConfig+CommandBatches.m
//  iGCS
//
//  Created by Andrew Brown on 6/20/14.
//
//

#import "iGCSRadioConfig+CommandBatches.h"
#import "iGCSRadioConfig_Private.h"
#import "iGCSRadioConfig_Commands.h"

// consts for NSNotification message names
NSString * const GCSRadioConfigBatchNameExitConfigMode = @"com.fightingwalrus.radioconfig.batchname.exitconfigmode";
NSString * const GCSRadioConfigBatchNameCheckForPairedRemoteRadio = @"com.fightingwalrus.radioconfig.batchname.checkpairedremoteradio";
NSString * const GCSRadioConfigBatchNameEnterConfigMode = @"com.fightingwalrus.radioconfig.batchname.enterconfigmode";
NSString * const GCSRadioConfigBatchNameLoadRadioVersion = @"com.fightingwalrus.radioconfig.batchname.loadradioversion";
NSString * const GCSRadioConfigBatchNameLoadBasicSettings = @"com.fightingwalrus.radioconfig.batchname.loadbasicsettings";
NSString * const GCSRadioConfigBatchNameLoadAllSettings = @"com.fightingwalrus.radioconfig.batchname.loadallsettings";
NSString * const GCSRadioConfigBatchNameSaveAndResetWithNetID = @"com.fightingwalrus.radioconfig.batchname.saveandresetwithnetid";

// consts for use as userInfo dict keys when sending NSNotifications
NSString * const GCSRadioConfigBatchName = @"GCSRadioConfigBatchName";
NSString * const GCSRadioConfigHayesResponseStateKey = @"GCSRadioConfigHayesResponseStateKey";
NSString * const GCSRadioConfigIsRadioBootedKey = @"GCSRadioConfigIsRadioBootedKey";
NSString * const GCSRadioConfigIsRadioInConfigModeKey = @"GCSRadioConfigIsRadioInConfigModeKey";
NSString * const GCSRadioConfigIsRemoteRadioRespondingKey = @"GCSRadioConfigIsRemoteRadioRespondingKey";
NSString * const GCSRadioConfigCommandHasTimedOutKey = @"GCSRadioConfigCommandHasTimedOutKey";

@implementation iGCSRadioConfig (CommandBatches)

-(void)exitConfigMode {
    [self prepareQueueForNewCommandsWithName:GCSRadioConfigBatchNameExitConfigMode];

    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, self.atCommandQueue, ^{
        [self exit];
    });

    dispatch_group_notify(group, self.atCommandQueue, ^{
        dispatch_async(dispatch_get_main_queue(),^{
            DDLogInfo(@">>>> iGCSRadioConfig.exitConfigMode complete");
            [[NSNotificationCenter defaultCenter] postNotificationName:GCSRadioConfigBatchNameExitConfigMode
                                                                object:nil
                                                              userInfo:[self userInfoFromCurrentState]];
        });
    });
}

#pragma public mark - Command batches

-(void)enterConfigMode {
    
    if (!self.isRadioBooted) {
        DDLogWarn(@"enterConfigMode >> Can't enter config mode. RADIO IS NOT BOOTED.");
        return;
    }

    if (self.isRadioInConfigMode) {
        DDLogWarn(@"enterConfigMode >> Radio is already in config Mode.");
        return;
    }

    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, self.atCommandQueue, ^{
        [self sendConfigModeCommand];
    });

    dispatch_group_notify(group, self.atCommandQueue, ^{
        dispatch_async(dispatch_get_main_queue(),^{
        DDLogInfo(@">>>> iGCSRadioConfig.enterConfigMode complete");
            [[NSNotificationCenter defaultCenter] postNotificationName:GCSRadioConfigBatchNameEnterConfigMode
                                                                object:nil
                                                              userInfo:[self userInfoFromCurrentState]];
        });
    });
}

-(void)checkForPairedRemoteRadio {
    dispatch_group_t group = dispatch_group_create();

    // set RT mode.
    dispatch_group_async(group, self.atCommandQueue, ^{
        self.sikAt.hayesMode = RT;
    });

    dispatch_group_async(group, self.atCommandQueue, ^{
        [self netId];
    });

    dispatch_group_notify(group, self.atCommandQueue, ^{
        // set hayesMode back to AT;
        self.sikAt.hayesMode = AT;

        // post notification on main thread
        dispatch_async(dispatch_get_main_queue(),^{
            DDLogInfo(@">>>> iGCSRadioConfig.checkForPairedRemoteRadio complete");
            [[NSNotificationCenter defaultCenter] postNotificationName:GCSRadioConfigBatchNameCheckForPairedRemoteRadio
                                                                object:nil
                                                              userInfo:[self userInfoFromCurrentState]];
        });
    });

}

-(void)loadRadioVersion {
    dispatch_group_t group = dispatch_group_create();

    dispatch_group_async(group, self.atCommandQueue, ^{
        [self radioVersion];
    });

    dispatch_group_notify(group, self.atCommandQueue, ^{
        dispatch_async(dispatch_get_main_queue(),^{
            DDLogInfo(@">>>> iGCSRadioConfig.loadRadioVersion complete");
            [[NSNotificationCenter defaultCenter] postNotificationName:GCSRadioConfigBatchNameLoadRadioVersion
                                                                object:nil
                                                              userInfo:[self userInfoFromCurrentState]];
        });
    });
}

-(void)loadBasicSettings {
    [self prepareQueueForNewCommandsWithName:GCSRadioConfigBatchNameLoadBasicSettings];

    dispatch_group_t group = dispatch_group_create();

    dispatch_group_async(group, self.atCommandQueue, ^{[self radioVersion];});
    dispatch_group_async(group, self.atCommandQueue, ^{[self boardType];});
    dispatch_group_async(group, self.atCommandQueue, ^{[self boardFrequency];;});
    dispatch_group_async(group, self.atCommandQueue, ^{[self boardVersion];});
    dispatch_group_async(group, self.atCommandQueue, ^{[self serialSpeed];});
    dispatch_group_async(group, self.atCommandQueue, ^{[self airSpeed];});
    dispatch_group_async(group, self.atCommandQueue, ^{[self netId];});
    dispatch_group_async(group, self.atCommandQueue, ^{[self maxFrequency];});
    dispatch_group_async(group, self.atCommandQueue, ^{[self transmitPower];});
    dispatch_group_async(group, self.atCommandQueue, ^{[self dutyCycle];});

    dispatch_group_notify(group, self.atCommandQueue, ^{
        dispatch_async(dispatch_get_main_queue(),^{
        DDLogInfo(@">>>> iGCSRadioConfig.loadBasicSettings complete");
            [[NSNotificationCenter defaultCenter] postNotificationName:GCSRadioConfigBatchNameLoadBasicSettings
                                                                object:nil
                                                              userInfo:[self userInfoFromCurrentState]];
        });
    });
}

-(void)loadAllSettings {
    [self prepareQueueForNewCommandsWithName:GCSRadioConfigBatchNameLoadAllSettings];

    dispatch_group_t group = dispatch_group_create();

    dispatch_group_async(group, self.atCommandQueue, ^{[self radioVersion];});
    dispatch_group_async(group, self.atCommandQueue, ^{[self boardType];});
    dispatch_group_async(group, self.atCommandQueue, ^{[self boardFrequency];});
    dispatch_group_async(group, self.atCommandQueue, ^{[self boardVersion];});
    dispatch_group_async(group, self.atCommandQueue, ^{[self serialSpeed];});
    dispatch_group_async(group, self.atCommandQueue, ^{[self airSpeed];});
    dispatch_group_async(group, self.atCommandQueue, ^{[self netId];});
    dispatch_group_async(group, self.atCommandQueue, ^{[self transmitPower];});
    dispatch_group_async(group, self.atCommandQueue, ^{[self radioVersion];});
    dispatch_group_async(group, self.atCommandQueue, ^{[self mavLink];});
    dispatch_group_async(group, self.atCommandQueue, ^{[self oppResend];});
    dispatch_group_async(group, self.atCommandQueue, ^{[self numberOfChannels];});
    dispatch_group_async(group, self.atCommandQueue, ^{[self minFrequency];});
    dispatch_group_async(group, self.atCommandQueue, ^{[self maxFrequency];});
    dispatch_group_async(group, self.atCommandQueue, ^{[self dutyCycle];});
    dispatch_group_async(group, self.atCommandQueue, ^{[self listenBeforeTalkRssi];});
    dispatch_group_async(group, self.atCommandQueue, ^{[self transmitPower];});

    //  TODO: need more logic to parse response from this command.
    //  eepromParams are currently gathered one by one.
    //  [self.commandQueue addObject:^(){[weakSelf eepromParams];}];
    //  [self.commandQueue addObject:^(){[weakSelf tdmTimingReport];}];
    dispatch_group_notify(group, self.atCommandQueue, ^{
        dispatch_async(dispatch_get_main_queue(),^{
        DDLogInfo(@">>>> iGCSRadioConfig.loadAllSettings complete");
            [[NSNotificationCenter defaultCenter] postNotificationName:GCSRadioConfigBatchNameLoadAllSettings
                                                                object:nil
                                                              userInfo:[self userInfoFromCurrentState]];
        });
    });
}

-(void)saveAndResetWithNetID:(NSInteger) netId withHayesMode:(GCSSikHayesMode) hayesMode{
    [self prepareQueueForNewCommandsWithName:GCSRadioConfigBatchNameSaveAndResetWithNetID];

    dispatch_group_t group = dispatch_group_create();

    dispatch_group_async(group, self.atCommandQueue, ^{
        [self setNetId:netId withHayesMode:hayesMode];
    });

    dispatch_group_async(group, self.atCommandQueue, ^{
        [self saveWithHayesMode:hayesMode];
    });

    dispatch_group_async(group, self.atCommandQueue, ^{
        [self rebootRadioWithHayesMode:hayesMode];
    });

    dispatch_group_notify(group, self.atCommandQueue, ^{
        dispatch_async(dispatch_get_main_queue(),^{
            DDLogInfo(@">>>> iGCSRadioConfig.saveAndResetWithNetID complete");
            [[NSNotificationCenter defaultCenter] postNotificationName:GCSRadioConfigBatchNameSaveAndResetWithNetID
                                                                object:nil
                                                              userInfo:[self userInfoFromCurrentState]];
        });
    });
}

# pragma mark - helpers
-(NSDictionary *)userInfoFromCurrentState {
    return @{GCSRadioConfigHayesResponseStateKey: @(self.hayesResponseState),
             GCSRadioConfigIsRadioBootedKey: @(self.isRadioBooted),
             GCSRadioConfigIsRadioInConfigModeKey: @(self.isRadioInConfigMode),
             GCSRadioConfigIsRemoteRadioRespondingKey: @(self.isRemoteRadioResponding),
             GCSRadioConfigCommandHasTimedOutKey: @(self.commandHasTimedOut)};
}

@end
