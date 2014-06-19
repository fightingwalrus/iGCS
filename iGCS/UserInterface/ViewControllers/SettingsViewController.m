//
//  SettingsViewController.m
//  iGCS
//
//  Created by Andrew Brown on 3/18/14.
//
//

#import "SettingsViewController.h"
#import "CommController.h"
#import "GCSRadioSettings.h"

// use for this views kvo context
static void * SVKvoContext = &SVKvoContext;

@interface SettingsViewController () {
    GCSRadioSettings *_localRadioSettingsModel;
    GCSRadioSettings *_remoteRadioSettingsModel;
}


@end

@implementation SettingsViewController

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hayesCommandTimedOutWithNotification:) name:GCSRadioConfigCommandBatchResponseTimeOut object:nil];
//
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(readRadioSettings) name:GCSRadioConfigEnteredConfigMode object:nil];
//
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(radioHasBooted) name:GCSRadioConfigRadioHasBooted object:nil];

    // alert user to failed retry attempts
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(commandRetryFailed) name:GCSRadioConfigCommandRetryFailed object:nil];

    self.localRadioFirmwareVersion.text = nil;
    self.remoteRadioFirmwareVersion.text = nil;
    self.connectionStatus.text = nil;

    self.localRadioNetId.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
}

#pragma mark - IBAction's

-(void)radioHasBooted {

    // If the radio has rebooted and we are not in config mode then enter config
    // read/write local settings. Once we enter configmode an NSNotification
    // will trigger the readRadioSettings selector
    if (![CommController sharedInstance].radioConfig.isRadioInConfigMode) {
        [self enterConfigMode];
        return;
    }

    // we are already in config mode so just load the current settings
    // this code path will be executed after radio settings have been
    // saved and the radio has been rebooted
    [self readRadioSettings];
}

-(void)enterConfigMode {
    NSLog(@"enterConfigMode");
    [[CommController sharedInstance].radioConfig enterConfigMode];
}

-(void)readRadioSettings {
    NSLog(@"readLocalSettings");
    [[CommController sharedInstance].radioConfig loadSettings];
}

- (IBAction)saveSettings:(id)sender {
    NSLog(@"Save Settings");
    NSInteger netId = [self.localRadioNetId.text integerValue];
    [[CommController sharedInstance].radioConfig saveAndResetWithNetID:netId];
}

-(IBAction)sendATCommand:(id)sender {
    NSLog(@"start RadioMode");
    [self readRadioSettings];
//    [self configureKvo];
//    [self updateUIWithRadioSettingsFromModel];
}

- (IBAction)enableConfigMode:(id)sender {
    [[CommController sharedInstance] startFWRConfigMode];
    [self configureKvo];
    [self updateUIWithRadioSettingsFromModel];
}


- (IBAction)enableHayesMode:(id)sender {
    [[CommController sharedInstance].radioConfig enterConfigMode];
}

#pragma mark - Set up KVO
-(void) configureKvo {
    
    if (!_localRadioSettingsModel) {
        _localRadioSettingsModel = [CommController sharedInstance].radioConfig.localRadioSettings;
    }

    [_localRadioSettingsModel addObserver:self forKeyPath:@"radioVersion" options:NSKeyValueObservingOptionNew context:&SVKvoContext];
    [_localRadioSettingsModel addObserver:self forKeyPath:@"netId" options:NSKeyValueObservingOptionNew context:&SVKvoContext];
    [_localRadioSettingsModel addObserver:self forKeyPath:@"minFrequency" options:NSKeyValueObservingOptionNew context:&SVKvoContext];
    [_localRadioSettingsModel addObserver:self forKeyPath:@"maxFrequency" options:NSKeyValueObservingOptionNew context:&SVKvoContext];

    if (!_remoteRadioSettingsModel) {
        _remoteRadioSettingsModel = [CommController sharedInstance].radioConfig.remoteRadioSettings;
    }

    [_remoteRadioSettingsModel addObserver:self forKeyPath:@"radioVersion" options:NSKeyValueObservingOptionNew context:&SVKvoContext];
    [_remoteRadioSettingsModel addObserver:self forKeyPath:@"netId" options:NSKeyValueObservingOptionNew context:&SVKvoContext];
    [_remoteRadioSettingsModel addObserver:self forKeyPath:@"minFrequency" options:NSKeyValueObservingOptionNew context:&SVKvoContext];
    [_remoteRadioSettingsModel addObserver:self forKeyPath:@"maxFrequency" options:NSKeyValueObservingOptionNew context:&SVKvoContext];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {

    // pass kvo up the chain.. no need on NSObject.
    if (context != SVKvoContext) {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
        return;
    }


    // local radio settings
    if (object == _localRadioSettingsModel) {
        if ([keyPath isEqual:@"radioVersion"]) {
            self.localRadioFirmwareVersion.text = [change objectForKey:NSKeyValueChangeNewKey];

        }else if ([keyPath isEqual:@"boardType"]) {
            // noop

        }else if ([keyPath isEqual:@"boadFrequency"]) {
            // noop

        }else if ([keyPath isEqual:@"boadVersion"]) {
            // noop

        }else if ([keyPath isEqual:@"tdmTimingReport"]) {
            // noop

        }else if ([keyPath isEqual:@"RSSIReport"]) {
            // noop

        }else if ([keyPath isEqual:@"serialSpeed"]) {
//            self.localRadioBaudRate.text = [[change objectForKey:NSKeyValueChangeNewKey] stringValue];

        }else if ([keyPath isEqual:@"airSpeed"]) {
//            self.localRadioAirBaudRate.text = [[change objectForKey:NSKeyValueChangeNewKey] stringValue];

        }else if ([keyPath isEqual:@"netId"]) {
            self.localRadioNetId.text = [[change objectForKey:NSKeyValueChangeNewKey] stringValue];

        } else if ([keyPath isEqual:@"transmitterPower"]) {
//            self.localRadioTransmitPower.text = [[change objectForKey:NSKeyValueChangeNewKey] stringValue];

        }else if ([keyPath isEqual:@"isECCenabled"]) {
            // noop

        } else if ([keyPath isEqual:@"isMavlinkEnabled"]) {
//            self.localRadioIsMavlinkEnabled.text = ([change objectForKey:NSKeyValueChangeNewKey]) ? @"YES" : @"NO";

        }else if ([keyPath isEqual:@"isOppResendEnabled"]) {
            // noop

        } else if ([keyPath isEqual:@"minFrequency"]) {
//            self.localRadioMinFrequency.text = [[change objectForKey:NSKeyValueChangeNewKey] stringValue];

        }else if ([keyPath isEqual:@"maxFrequency"]) {
//            self.localRadioMaxFrequency.text = [[change objectForKey:NSKeyValueChangeNewKey] stringValue];

        }else if ([keyPath isEqual:@"numberOfChannels"]) {
            // noop

        }else if ([keyPath isEqual:@"dutyCycle"]) {
            // noop

        }else if ([keyPath isEqual:@"isListenBeforeTalkRSSIEnabled"]) {

        }
    }

    // remote radio settings
    if (object == _remoteRadioSettingsModel) {
        if ([keyPath isEqual:@"radioVersion"]) {
            self.remoteRadioFirmwareVersion.text = [change objectForKey:NSKeyValueChangeNewKey];
            self.connectionStatus.text = @"YES";
        }
    }
}


-(void)updateUIWithRadioSettingsFromModel {
    if (_localRadioSettingsModel) {

        if (_localRadioSettingsModel.netId) {
            self.localRadioNetId.text = [@(_localRadioSettingsModel.netId) stringValue];
        }

        self.localRadioFirmwareVersion.text = _localRadioSettingsModel.radioVersion;
    }

    if (_remoteRadioSettingsModel) {
        self.remoteRadioFirmwareVersion.text = _remoteRadioSettingsModel.radioVersion;
    }
}

-(void)hayesCommandTimedOutWithNotification:(NSNotification *)noti {
    NSString *command;
    if (![noti.object isKindOfClass:[NSString class]]) {
        return;
    }

    command = noti.object;
    if ([command rangeOfString:@"RT"].location != NSNotFound) {
        NSLog(@"THIS COMMAND TIMED OUT! NO LINK!: %@", command);
        self.connectionStatus.text = @"NO";
    } else {
        NSLog(@"Timeout talking to local radio");
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)commandRetryFailed {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed" message:@"Timeout talking to the radio. Please try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    return;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
