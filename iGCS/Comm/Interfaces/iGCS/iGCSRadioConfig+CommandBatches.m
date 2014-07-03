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

// constants for user as NSNotification messages

NSString * const GCSRadioConfigBatchNameExitConfigMode = @"com.fightingwalrus.radioconfig.batchname.exitconfigmode";
NSString * const GCSRadioConfigBatchNameEnterConfigMode = @"com.fightingwalrus.radioconfig.batchname.enterconfigmode";
NSString * const GCSRadioConfigBatchNameLoadRadioVersion = @"com.fightingwalrus.radioconfig.batchname.loadradioversion";
NSString * const GCSRadioConfigBatchNameLoadBasicSettings = @"com.fightingwalrus.radioconfig.batchname.loadbasicsettings";
NSString * const GCSRadioConfigBatchNameLoadAllSettings = @"com.fightingwalrus.radioconfig.batchname.loadallsettings";
NSString * const GCSRadioConfigBatchNameSaveAndResetWithNetID = @"com.fightingwalrus.radioconfig.batchname.saveandresetwithnetid";


// for use in userInfo dictionary key
NSString *const GCSRadioConfigBatchName = @"GCSRadioConfigBatchName";

@implementation iGCSRadioConfig (CommandBatches)

-(void)exitConfigMode {
    [self prepareQueueForNewCommandsWithName:GCSRadioConfigBatchNameExitConfigMode];

    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, self.atCommandQueue, ^{
        [self exit];
    });

    dispatch_group_notify(group, self.atCommandQueue, ^{
        NSLog(@">>>> iGCSRadioConfig.exitConfigMode complete");
    });
}

#pragma public mark - Command batches

-(void)enterConfigMode {
    
    if (!self.isRadioBooted) {
        NSLog(@"enterConfigMode >> Can't enter config mode. RADIO IS NOT BOOTED.");
        return;
    }

    if (self.isRadioInConfigMode) {
        NSLog(@"enterConfigMode >> Radio is already in config Mode.");
        return;
    }

    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, self.atCommandQueue, ^{
        [self sendConfigModeCommand];
    });


    dispatch_group_notify(group, self.atCommandQueue, ^{
        NSLog(@">>>> iGCSRadioConfig.enterConfigMode complete");
    });
}

-(void)loadRadioVersion {
    dispatch_group_t group = dispatch_group_create();

    dispatch_group_async(group, self.atCommandQueue, ^{
        [self radioVersion];
    });

    dispatch_group_notify(group, self.atCommandQueue, ^{
        NSLog(@">>>> iGCSRadioConfig.loadRadioVersion complete");
    });
}

-(void)loadBasicSettings {
    [self prepareQueueForNewCommandsWithName:GCSRadioConfigBatchNameLoadBasicSettings];

    dispatch_group_t group = dispatch_group_create();

    dispatch_group_async(group, self.atCommandQueue, ^{[self radioVersion];});
    dispatch_group_async(group, self.atCommandQueue, ^{[self boadType];});
    dispatch_group_async(group, self.atCommandQueue, ^{[self boadFrequency];;});
    dispatch_group_async(group, self.atCommandQueue, ^{[self boadVersion];});
    dispatch_group_async(group, self.atCommandQueue, ^{[self serialSpeed];});
    dispatch_group_async(group, self.atCommandQueue, ^{[self airSpeed];});
    dispatch_group_async(group, self.atCommandQueue, ^{[self netId];});
    dispatch_group_async(group, self.atCommandQueue, ^{[self maxFrequency];});
    dispatch_group_async(group, self.atCommandQueue, ^{[self transmitPower];});
    dispatch_group_async(group, self.atCommandQueue, ^{[self dutyCycle];});

    dispatch_group_notify(group, self.atCommandQueue, ^{
        NSLog(@">>>> iGCSRadioConfig.loadBasicSettings complete");
    });
}

-(void)loadAllSettings {
    [self prepareQueueForNewCommandsWithName:GCSRadioConfigBatchNameLoadAllSettings];

    dispatch_group_t group = dispatch_group_create();

    dispatch_group_async(group, self.atCommandQueue, ^{[self radioVersion];});
    dispatch_group_async(group, self.atCommandQueue, ^{[self boadType];});
    dispatch_group_async(group, self.atCommandQueue, ^{[self boadFrequency];});
    dispatch_group_async(group, self.atCommandQueue, ^{[self boadVersion];});
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
        NSLog(@">>>> iGCSRadioConfig.loadAllSettings complete");
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
        NSLog(@">>>> iGCSRadioConfig.saveAndResetWithNetID complete");
    });
}

@end
