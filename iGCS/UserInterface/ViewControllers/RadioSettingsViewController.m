//
//  SettingsViewController.m
//  iGCS
//
//  Created by Andrew Brown on 3/18/14.
//
//

#import "RadioSettingsViewController.h"
#import "CommController.h"
#import "GCSRadioSettings.h"
#import "GCSThemeManager.h"
#import "GCSActivityIndicatorView.h"

#import "PureLayout.h"

// use for this views kvo context
static void *SVKvoContext = &SVKvoContext;

@interface RadioSettingsViewController ()

// Navigation bar items
@property (strong, nonatomic) UIBarButtonItem *editBarButtonItem;
@property (strong, nonatomic) UIBarButtonItem *cancelBarButtonItem;
@property (strong, nonatomic) UIBarButtonItem *saveBarButtonItem;

@property (strong, nonatomic) UIScrollView *scrollView;

@property (strong, nonatomic) GCSActivityIndicatorView *activityIndicatorView;

// UI elements
@property (strong, nonatomic) UILabel *localRadioFirmwareVersionLabel;
@property (strong, nonatomic) UILabel *localRadioFirmwareVersion;

@property (strong, nonatomic) UILabel *remoteRadioFirmwareVersionLabel;
@property (strong, nonatomic) UILabel *remoteRadioFirmwareVersion;

@property (strong, nonatomic) UILabel *connectionStatusLabel;
@property (strong, nonatomic) UILabel *connectionStatus;

@property (strong, nonatomic) UILabel *localRadioNetIdLabel;
@property (strong, nonatomic) UITextField *localRadioNetId;

//@property (strong, nonatomic) IBOutlet UITextField *localRadioBaudRate;
//@property (strong, nonatomic) IBOutlet UITextField *localRadioAirBaudRate;



//@property (strong, nonatomic) IBOutlet UITextField *localRadioTransmitPower;
//@property (strong, nonatomic) IBOutlet UITextField *localRadioIsMavlinkEnabled;
//@property (strong, nonatomic) IBOutlet UITextField *localRadioMinFrequency;
//@property (strong, nonatomic) IBOutlet UITextField *localRadioMaxFrequency;
//@property (strong, nonatomic) IBOutlet UITextField *localRadioNumberOfChannels;
//@property (strong, nonatomic) IBOutlet UITextField *localRadioDutyCycle;
//@property (strong, nonatomic) IBOutlet UITextField *localRadioLbtRssiEnabled;
//@property (strong, nonatomic) IBOutlet UITextField *localRadioHardwareFlow;

@property (strong, nonatomic) UIButton *editCancelButton;
@property (strong, nonatomic) UIButton *saveButton;

// models
@property (nonatomic, strong) GCSRadioSettings *localRadioSettingsModel;
@property (nonatomic, strong) GCSRadioSettings *remoteRadioSettingsModel;

@end

@implementation RadioSettingsViewController

-(instancetype)init {
    self = [super init];

    if (self) {
        // radio has booted
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(radioHasBooted)
                                                     name:GCSRadioConfigRadioHasBooted object:nil];

        // radio has booted after save
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(radioHasBootedAfterSave)
                                                     name:GCSRadioConfigRadioDidSaveAndBoot object:nil];

        // radio has entered config mode
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(radioHasEnteredConfigMode)
                                                     name:GCSRadioConfigEnteredConfigMode object:nil];

        _activityIndicatorView = [[GCSActivityIndicatorView alloc] init];
    }
    return self;

}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) viewWillAppear:(BOOL)animated {
    // configure subview
    [super viewWillAppear:YES];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureNavigationBar];
    [self configureViewLayout];

    // enter config mode
    [[CommController sharedInstance] closeAllInterfaces];
    [self performSelector:@selector(setupConfigAccessoryConnection) withObject:nil afterDelay:3.0f];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];

    // configure and start spinner
    [self.activityIndicatorView centerOnView:self.view];
    [self.activityIndicatorView startAnimating];
}

-(void)configureNavigationBar {
    [self setTitle:@"Configure Radio"];

    self.cancelBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                         target:self action:@selector(cancelChanges:)];
    // save button disabled on load
    self.saveBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                       target:self action:@selector(saveSettings:)];
    self.saveBarButtonItem.enabled = NO;

    self.navigationItem.leftBarButtonItem = self.cancelBarButtonItem;
    self.navigationItem.rightBarButtonItem = self.saveBarButtonItem;
}

-(void)configureViewLayout {

    self.scrollView = [UIScrollView newAutoLayoutView];
    [self.view addSubview:self.scrollView];
    [self.scrollView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];

    self.localRadioFirmwareVersion.text = nil;
    self.remoteRadioFirmwareVersion.text = nil;
    self.connectionStatus.text = nil;
    self.view.backgroundColor = [GCSThemeManager sharedInstance].appSheetBackgroundColor;

    // NetID UI
    self.localRadioNetIdLabel = [UILabel newAutoLayoutView];
    [self.scrollView addSubview:self.localRadioNetIdLabel];
    [self.localRadioNetIdLabel setText:@"Net ID:"];
    self.localRadioNetIdLabel.textAlignment = NSTextAlignmentRight;


    self.localRadioNetId = [UITextField newAutoLayoutView];
    self.localRadioNetId.borderStyle = UITextBorderStyleRoundedRect;
    [self.localRadioNetId autoSetDimension:ALDimensionWidth toSize:150.0f];
    [self.scrollView  addSubview:self.localRadioNetId];
    self.localRadioNetId.textAlignment = NSTextAlignmentLeft;
    self.localRadioNetId.keyboardType = UIKeyboardTypeNumbersAndPunctuation;

    // Local radio version
    self.localRadioFirmwareVersionLabel = [UILabel newAutoLayoutView];
    [self.scrollView  addSubview:self.localRadioFirmwareVersionLabel];
    [self.localRadioFirmwareVersionLabel setText:@"Local Radio Firmware:"];
    self.localRadioFirmwareVersionLabel.textAlignment = NSTextAlignmentRight;

    self.localRadioFirmwareVersion = [UILabel newAutoLayoutView];
    [self.scrollView  addSubview:self.localRadioFirmwareVersion];
    [self.localRadioFirmwareVersion setText:@"-"];
    self.localRadioFirmwareVersion.textAlignment = NSTextAlignmentLeft;

    // remote radio version
    self.remoteRadioFirmwareVersionLabel = [UILabel newAutoLayoutView];
    [self.scrollView  addSubview:self.remoteRadioFirmwareVersionLabel];
    [self.remoteRadioFirmwareVersionLabel setText:@"Remote Radio Firmware:"];
    self.remoteRadioFirmwareVersionLabel.textAlignment = NSTextAlignmentRight;

    self.remoteRadioFirmwareVersion = [UILabel newAutoLayoutView];
    [self.scrollView  addSubview:self.remoteRadioFirmwareVersion];
    [self.remoteRadioFirmwareVersion setText:@"-"];
    self.remoteRadioFirmwareVersion.textAlignment = NSTextAlignmentLeft;


    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self.localRadioNetIdLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:88.0f + 50.0f];
        [self.localRadioNetIdLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:60.0f];
    } else {
        [self.localRadioNetIdLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:44.0f + 25.0f];
        [self.localRadioNetIdLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:60.0f];
    }


    // normally the app will prompt if a connection is opened to a FWR that needs updated
    // hoever we want an easy way to test the firmware updater.

    NSArray *labelViews;
#if DEBUG
    UIButton *fwrFirmwareUpdateButton = [UIButton newAutoLayoutView];
    [fwrFirmwareUpdateButton setTitle:@"Update Firmware" forState:UIControlStateNormal];
    [fwrFirmwareUpdateButton addTarget:self action:@selector(updateFirmware) forControlEvents:UIControlEventTouchUpInside];
    [fwrFirmwareUpdateButton setTitleColor:[GCSThemeManager sharedInstance].appTintColor forState:UIControlStateNormal];
    [self.scrollView addSubview:fwrFirmwareUpdateButton];

    [fwrFirmwareUpdateButton autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10.0f];
    [fwrFirmwareUpdateButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:10.0f];

    labelViews = @[self.localRadioNetIdLabel, self.localRadioFirmwareVersionLabel, self.remoteRadioFirmwareVersionLabel, fwrFirmwareUpdateButton];
#else
    labelViews = @[self.localRadioNetIdLabel, self.localRadioFirmwareVersionLabel, self.remoteRadioFirmwareVersionLabel];
#endif

    UIView *previousLabel = nil;
    for (UIView *view in labelViews) {
        if (previousLabel) {
            [view autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:previousLabel withOffset:30.0f];
            UILayoutPriority priority = (view == self.remoteRadioFirmwareVersionLabel) ? UILayoutPriorityDefaultHigh + 1 : UILayoutPriorityRequired;
            [UIView autoSetPriority:priority forConstraints:^{
                [view autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:previousLabel];
                [view autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:previousLabel];
            }];
        }
        previousLabel = view;
    }

    // need one scroll view subview pinned to bottom of scroll view in order for scrolling to work with autolayout
#if DEBUG
  [fwrFirmwareUpdateButton autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.scrollView withOffset:-10.0f relation:NSLayoutRelationLessThanOrEqual];
#else
  [self.remoteRadioFirmwareVersionLabel autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.scrollView withOffset:-10.0f relation:NSLayoutRelationLessThanOrEqual];
#endif

    [labelViews autoAlignViewsToEdge:ALEdgeRight];
    [labelViews autoMatchViewsDimension:ALDimensionWidth];

    [self.localRadioNetId autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.localRadioNetIdLabel withOffset:10];
    [self.localRadioNetId autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.localRadioNetIdLabel];

    [self.localRadioFirmwareVersion autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.localRadioFirmwareVersionLabel withOffset:10];
    [self.localRadioFirmwareVersion autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.localRadioFirmwareVersionLabel];

    [self.remoteRadioFirmwareVersion autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.remoteRadioFirmwareVersionLabel withOffset:10];
    [self.remoteRadioFirmwareVersion autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.remoteRadioFirmwareVersionLabel];

}

#pragma mark - UINavigationBar Button handlers

- (void)cancelChanges:(id)sender {
    [[CommController sharedInstance] startTelemetryMode];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveSettings:(id)sender {
    DDLogDebug(@"Save Radio config Settings");

    // attempt to update the remote radio first
    if ([CommController sharedInstance].radioConfig.isRemoteRadioResponding) {
        [self saveSettingsToRemoteRadio];
    } else  {
        [self saveSettingsToLocalRadio];
    }
}

-(void)updateFirmware {
    DDLogDebug(@"Update FWR Firmware");
    [[CommController sharedInstance] startFWRFirmwareUpdateMode];

    [self performSelector:@selector(sendFirmwareToFWR) withObject:self afterDelay:0.2f];
}

-(void)sendFirmwareToFWR {
    [[CommController sharedInstance].fwrFirmwareInterface updateFwrFirmware];
}

#pragma mark - NSNotifcation handlers

-(void)radioHasBooted {

    // If the radio has rebooted and we are not in config mode then enter config
    // read/write local settings. Once we enter configmode an NSNotification
    // will trigger the readRadioSettings selector
    if (![CommController sharedInstance].radioConfig.isRadioInConfigMode) {
        // outbound wire must be quiet for at least 1 second before we can enter config mode per
        // SiK firmware.
        [self performSelector:@selector(enterConfigMode) withObject:nil afterDelay:1.1f];
        return;
    }

    // we are already in config mode so just load the current settings
    // this code path will be executed after radio settings have been
    // saved and the radio has been rebooted
    [self readRadioSettings];
}

-(void)radioHasBootedAfterSave {
    // dissmiss radio config sheet
    [[CommController sharedInstance] startTelemetryMode];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)radioHasEnteredConfigMode {
    // read current settings
    [self readRadioSettings];
}

#pragma mark - radio commands

-(void)enterConfigMode {
    DDLogDebug(@"enterConfigMode");
    [[CommController sharedInstance].radioConfig enterConfigMode];
}

-(void)exitConfigMode {
    DDLogDebug(@"exitConfigMode");
    if ([CommController sharedInstance].radioConfig.isRadioInConfigMode) {
        [[CommController sharedInstance].radioConfig exitConfigMode];
    }
}

-(void)readRadioSettings {
    DDLogDebug(@"readLocalSettings");
    [[CommController sharedInstance].radioConfig loadBasicSettings];

    // enable save button and remove spinner
    self.saveBarButtonItem.enabled = YES;
    [self.activityIndicatorView stopAnimating];
    [self.activityIndicatorView removeFromSuperview];
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
            self.localRadioFirmwareVersion.text = change[NSKeyValueChangeNewKey];

        }else if ([keyPath isEqual:@"boardType"]) {
            // noop

        }else if ([keyPath isEqual:@"boardFrequency"]) {
            // noop

        }else if ([keyPath isEqual:@"boardVersion"]) {
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
            self.localRadioNetId.text = [change[NSKeyValueChangeNewKey] stringValue];

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
            self.remoteRadioFirmwareVersion.text = change[NSKeyValueChangeNewKey];
            self.connectionStatus.text = @"YES";
        }
    }
}


-(void)updateUIWithRadioSettingsFromModel {
    if (self.localRadioSettingsModel) {

        if (self.localRadioSettingsModel.netId) {
            self.localRadioNetId.text = [@(self.localRadioSettingsModel.netId) stringValue];
        }

        self.localRadioFirmwareVersion.text = self.localRadioSettingsModel.radioVersion;
    }

    if (_remoteRadioSettingsModel) {
        self.remoteRadioFirmwareVersion.text = self.remoteRadioSettingsModel.radioVersion;
    }
}

-(void)hayesCommandTimedOutWithNotification:(NSNotification *)noti {
    NSString *command;
    if (![noti.object isKindOfClass:[NSString class]]) {
        return;
    }

    command = noti.object;
    if ([command rangeOfString:@"RT"].location != NSNotFound) {
        DDLogWarn(@"THIS COMMAND TIMED OUT! NO LINK!: %@", command);
        self.connectionStatus.text = @"NO";
    } else {
        DDLogWarn(@"Timeout talking to local radio");
    }
}

-(void)radioRebootCommandSentWithNotification:(NSNotification *)noti {
    NSString *command = (NSString *)noti.object;
    if ([command isEqualToString:@"RTZ"]) {
        // we told the remote radio to reboot. Wait a second and then
        // update the update the local radios settings.
        [self performSelector:@selector(saveSettingsToLocalRadio) withObject:nil afterDelay:1.0f];
    } else if ([command isEqualToString:@"ATZ"]){
        [self performSelector:@selector(readRadioSettings) withObject:nil afterDelay:5.0];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)commandRetryFailedWithNotification:(NSNotification *) noti{
    GCSSikHayesMode hayesMode = [noti.userInfo[GCSSikHayesModeKeyName] unsignedIntegerValue];
    NSString *sender = noti.userInfo[GCSRadioConfigBatchName];

    // No UIAlert, just set the connection status test if we get no response from the remote radio
    if (hayesMode == RT && ([sender isEqualToString:GCSRadioConfigBatchNameLoadBasicSettings] ||
        [sender isEqualToString:GCSRadioConfigBatchNameLoadAllSettings] ||
        [sender isEqualToString:GCSRadioConfigBatchNameSaveAndResetWithNetID])) {
        self.connectionStatus.text = @"NO";
        return;
    }

    if (hayesMode == AT && ([sender isEqualToString:GCSRadioConfigBatchNameSaveAndResetWithNetID])) {
        return;
    }

    NSString *alertMessage;

    #ifdef DEBUG
        alertMessage = [NSString stringWithFormat:@"Timeout talking to the radio with command batch [ %@ ] in mode: [%@]", sender, GCSSikHayesModeDescription[hayesMode]];
    #else
        alertMessage = @"Timeout talking to the radio. Please try again.";
    #endif

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed" message:alertMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    return;
}

@end
