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
    
    dispatch_async(self.atCommandQueue, ^{
        [self exit];
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

    dispatch_async(self.atCommandQueue, ^{
        [self sendConfigModeCommand];
    });
}

-(void)loadRadioVersion {
    __weak iGCSRadioConfig *weakSelf = self;

    dispatch_async(self.atCommandQueue, ^{
        [weakSelf radioVersion];
    });

}

-(void)loadBasicSettings {
    [self prepareQueueForNewCommandsWithName:GCSRadioConfigBatchNameLoadBasicSettings];
    dispatch_async(self.atCommandQueue, ^{[self radioVersion];});
    dispatch_async(self.atCommandQueue, ^{[self boadType];});
    dispatch_async(self.atCommandQueue, ^{[self boadFrequency];;});
    dispatch_async(self.atCommandQueue, ^{[self boadVersion];});
    dispatch_async(self.atCommandQueue, ^{[self serialSpeed];});
    dispatch_async(self.atCommandQueue, ^{[self airSpeed];});
    dispatch_async(self.atCommandQueue, ^{[self netId];});
    dispatch_async(self.atCommandQueue, ^{[self maxFrequency];});
    dispatch_async(self.atCommandQueue, ^{[self transmitPower];});
    dispatch_async(self.atCommandQueue, ^{[self dutyCycle];});
}

-(void)loadAllSettings {
    [self prepareQueueForNewCommandsWithName:GCSRadioConfigBatchNameLoadAllSettings];

    dispatch_async(self.atCommandQueue, ^{[self radioVersion];});
    dispatch_async(self.atCommandQueue, ^{[self boadType];});
    dispatch_async(self.atCommandQueue, ^{[self boadFrequency];});
    dispatch_async(self.atCommandQueue, ^{[self boadVersion];});
    dispatch_async(self.atCommandQueue, ^{[self serialSpeed];});
    dispatch_async(self.atCommandQueue, ^{[self airSpeed];});
    dispatch_async(self.atCommandQueue, ^{[self netId];});
    dispatch_async(self.atCommandQueue, ^{[self transmitPower];});
    dispatch_async(self.atCommandQueue, ^{[self radioVersion];});
    dispatch_async(self.atCommandQueue, ^{[self mavLink];});
    dispatch_async(self.atCommandQueue, ^{[self oppResend];});
    dispatch_async(self.atCommandQueue, ^{[self numberOfChannels];});
    dispatch_async(self.atCommandQueue, ^{[self minFrequency];});
    dispatch_async(self.atCommandQueue, ^{[self maxFrequency];});
    dispatch_async(self.atCommandQueue, ^{[self dutyCycle];});
    dispatch_async(self.atCommandQueue, ^{[self listenBeforeTalkRssi];});
    dispatch_async(self.atCommandQueue, ^{[self transmitPower];});

    //  TODO: need more logic to parse response from this command.
    //  eepromParams are currently gathered one by one.
    //  [self.commandQueue addObject:^(){[weakSelf eepromParams];}];
    //  [self.commandQueue addObject:^(){[weakSelf tdmTimingReport];}];

}

-(void)saveAndResetWithNetID:(NSInteger) netId withHayesMode:(GCSSikHayesMode) hayesMode{
    [self prepareQueueForNewCommandsWithName:GCSRadioConfigBatchNameSaveAndResetWithNetID];

    __weak iGCSRadioConfig *weakSelf = self;

    if (hayesMode == AT) {
        dispatch_async(self.atCommandQueue, ^{
            [weakSelf setNetId:netId withHayesMode:AT];
        });

        dispatch_async(self.atCommandQueue, ^{
            [weakSelf saveWithHayesMode:AT];
        });

        dispatch_async(self.atCommandQueue, ^{
            [weakSelf rebootRadioWithHayesMode:AT];
        });

    } else {
        dispatch_async(self.atCommandQueue, ^{
            [weakSelf setNetId:netId withHayesMode:RT];
        });

        dispatch_async(self.atCommandQueue, ^{
            [weakSelf saveWithHayesMode:RT];
        });

        dispatch_async(self.atCommandQueue, ^{
            [weakSelf rebootRadioWithHayesMode:RT];
        });
    }
}

@end
