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

@implementation iGCSRadioConfig (CommandBatches)

-(void)exitConfigMode {
    [self prepareQueueForNewCommandsWithName:NSStringFromSelector(_cmd)];

    __weak iGCSRadioConfig *weakSelf = self;
    [self.commandQueue addObject:^(){[weakSelf exit];}];

    [self dispatchCommandFromQueue];
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

    [self prepareQueueForNewCommandsWithName:NSStringFromSelector(_cmd)];

    __weak iGCSRadioConfig *weakSelf = self;
    [self.commandQueue addObject:^(){[weakSelf sendConfigModeCommand];}];

    [self dispatchCommandFromQueue];
}

-(void)loadRadioVersion {
    [self prepareQueueForNewCommandsWithName:NSStringFromSelector(_cmd)];
    __weak iGCSRadioConfig *weakSelf = self;
    [self.commandQueue addObject:^(){[weakSelf radioVersion];}];

    [self dispatchCommandFromQueue];
}

-(void)loadSettings {
    [self prepareQueueForNewCommandsWithName:NSStringFromSelector(_cmd)];

    __weak iGCSRadioConfig *weakSelf = self;
    [self.commandQueue addObject:^(){[weakSelf boadType];}];
    [self.commandQueue addObject:^(){[weakSelf boadFrequency];}];
    [self.commandQueue addObject:^(){[weakSelf boadVersion];}];

    //  TODO: need more logic to parse response from this command.
    //  eepromParams are currently gathered one by one.
    //  [self.commandQueue addObject:^(){[weakSelf eepromParams];}];
    //  [self.commandQueue addObject:^(){[weakSelf tdmTimingReport];}];

    [self.commandQueue addObject:^(){[weakSelf serialSpeed];}];
    [self.commandQueue addObject:^(){[weakSelf airSpeed];}];
    [self.commandQueue addObject:^(){[weakSelf netId];}];
    [self.commandQueue addObject:^(){[weakSelf transmitPower];}];
    [self.commandQueue addObject:^(){[weakSelf ecc];}];
    [self.commandQueue addObject:^(){[weakSelf radioVersion];}];
    [self.commandQueue addObject:^(){[weakSelf mavLink];}];
    [self.commandQueue addObject:^(){[weakSelf oppResend];}];
    [self.commandQueue addObject:^(){[weakSelf minFrequency];}];
    [self.commandQueue addObject:^(){[weakSelf maxFrequency];}];
    [self.commandQueue addObject:^(){[weakSelf numberOfChannels];}];
    [self.commandQueue addObject:^(){[weakSelf dutyCycle];}];
    [self.commandQueue addObject:^(){[weakSelf listenBeforeTalkRssi];}];
    [self.commandQueue addObject:^(){[weakSelf radioVersion];}];
    [self.commandQueue addObject:^(){[weakSelf RSSIReport];}];

    [self dispatchCommandFromQueue];
}


-(void)saveAndResetWithNetID:(NSInteger) netId withHayesMode:(GCSSikHayesMode) hayesMode{
    [self prepareQueueForNewCommandsWithName:NSStringFromSelector(_cmd)];

    __weak iGCSRadioConfig *weakSelf = self;

    if (hayesMode == AT) {
        [self.commandQueue addObject:^(){[weakSelf setNetId:netId withHayesMode:AT];}];
        [self.commandQueue addObject:^(){[weakSelf saveWithHayesMode:AT];}];
        [self.commandQueue addObject:^(){[weakSelf rebootRadioWithHayesMode:AT];}];
    } else {
        [self.commandQueue addObject:^(){[weakSelf setNetId:netId withHayesMode:RT];}];
        [self.commandQueue addObject:^(){[weakSelf saveWithHayesMode:RT];}];
        [self.commandQueue addObject:^(){[weakSelf rebootRadioWithHayesMode:RT];}];
    }

    [self dispatchCommandFromQueue];
}

@end
