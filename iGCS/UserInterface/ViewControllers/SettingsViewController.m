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
#import "PureLayout.h"

// use for this views kvo context
static void *SVKvoContext = &SVKvoContext;

@interface SettingsViewController ()

// models
@property (nonatomic, strong) GCSRadioSettings *localRadioSettingsModel;
@property (nonatomic, strong) GCSRadioSettings *remoteRadioSettingsModel;

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

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(radioRebootCommandSentWithNotification:)
                                                 name:GCSRadioConfigSentRebootCommand
                                               object:nil];

    // alert user to failed retry attempts
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(commandRetryFailedWithNotification:) name:GCSRadioConfigCommandRetryFailed object:nil];


    // configure subview
    [self configuteViews];
}

-(void)configuteViews {
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

- (IBAction)saveSettings:(id)sender {
    NSLog(@"Save Settings");

    // attempt to update the remote radio first
    if ([CommController sharedInstance].radioConfig.isRemoteRadioResponding) {
        [self saveSettingsToRemoteRadio];
    } else  {
        [self saveSettingsToLocalRadio];
    }
}

-(IBAction)sendATCommand:(id)sender {
    NSLog(@"start RadioMode");
    [self readRadioSettings];
}

- (IBAction)enableConfigMode:(id)sender {
    [[CommController sharedInstance] closeAllInterfaces];
    [self performSelector:@selector(setupConfigAccessoryConnection) withObject:nil afterDelay:3.0f];
}

- (IBAction)enableHayesMode:(id)sender {
    [[CommController sharedInstance].radioConfig enterConfigMode];
}

#pragma mark - radio commands

-(void)readRadioSettings {
    NSLog(@"readLocalSettings");
    [[CommController sharedInstance].radioConfig loadBasicSettings];
}

-(void)saveSettingsToRemoteRadio {
    NSInteger netId = [self.localRadioNetId.text integerValue];
    [[CommController sharedInstance].radioConfig saveAndResetWithNetID:netId withHayesMode:RT];
}

-(void)saveSettingsToLocalRadio {
    NSInteger netId = [self.localRadioNetId.text integerValue];
    [[CommController sharedInstance].radioConfig saveAndResetWithNetID:netId withHayesMode:AT];
}

-(void)setupConfigAccessoryConnection {
    if ([CommController sharedInstance].mavLinkInterface) {
        [[CommController sharedInstance].mavLinkInterface stopRecevingMessages];
    }
    [[CommController sharedInstance] startFWRConfigMode];
    [self configureKvo];
    [self updateUIWithRadioSettingsFromModel];

}

#pragma mark - Set up KVO
-(void) configureKvo {
    
    if (!self.localRadioSettingsModel) {
        self.localRadioSettingsModel = [CommController sharedInstance].radioConfig.localRadioSettings;
    }

    [self.localRadioSettingsModel addObserver:self forKeyPath:@"radioVersion" options:NSKeyValueObservingOptionNew context:&SVKvoContext];
    [self.localRadioSettingsModel addObserver:self forKeyPath:@"netId" options:NSKeyValueObservingOptionNew context:&SVKvoContext];
    [self.localRadioSettingsModel addObserver:self forKeyPath:@"minFrequency" options:NSKeyValueObservingOptionNew context:&SVKvoContext];
    [self.localRadioSettingsModel addObserver:self forKeyPath:@"maxFrequency" options:NSKeyValueObservingOptionNew context:&SVKvoContext];

    if (!self.remoteRadioSettingsModel) {
        self.remoteRadioSettingsModel = [CommController sharedInstance].radioConfig.remoteRadioSettings;
    }

    [self.remoteRadioSettingsModel addObserver:self forKeyPath:@"radioVersion" options:NSKeyValueObservingOptionNew context:&SVKvoContext];
    [self.remoteRadioSettingsModel addObserver:self forKeyPath:@"netId" options:NSKeyValueObservingOptionNew context:&SVKvoContext];
    [self.remoteRadioSettingsModel addObserver:self forKeyPath:@"minFrequency" options:NSKeyValueObservingOptionNew context:&SVKvoContext];
    [self.remoteRadioSettingsModel addObserver:self forKeyPath:@"maxFrequency" options:NSKeyValueObservingOptionNew context:&SVKvoContext];
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

-(void)radioRebootCommandSentWithNotification:(NSNotification *)noti {
    NSString *command = (NSString *)noti.object;
    if ([command isEqualToString:@"RTZ"]) {
        // we told the remote radio to reboot. Wait a second and then
        // update the update the local radios settings.
        [self performSelector:@selector(saveSettingsToLocalRadio) withObject:nil afterDelay:1.0f];
    } else if ([command isEqualToString:@"ATZ"]){
        [self performSelector:@selector(readRadioSettings) withObject:nil afterDelay:3.5];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)commandRetryFailedWithNotification:(NSNotification *) noti{
    GCSSikHayesMode hayesMode = [noti.userInfo[GCSSikHayesModeKeyName] unsignedIntegerValue];
    NSString *sender = noti.userInfo[GCSRadioConfigBatchName];

    // No UIAlert, just set the connection status test if we get no response from the remote radio
    if (hayesMode == RT && ([sender isEqualToString:GCSRadioConfigBatchNameLoadBasicSettings] ||
        [sender isEqualToString:GCSRadioConfigBatchNameLoadAllSettings]) ) {
        self.connectionStatus.text = @"NO";
        return;
    }

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed" message:@"Timeout talking to the radio. Please try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    return;
}

@end
