//
//  DefaultSettingsViewController.m
//  iGCS
//
//  Created by David Leskowicz on 2/9/15.
//
//

#import "DefaultSettingsViewController.h"
#import "CommController.h"
#import "GCSRadioSettings.h"
#import "GCSThemeManager.h"
#import "GCSActivityIndicatorView.h"
#import "GCSAccessoryFirmwareUtils.h"

#import "PureLayout.h"

// use for this views kvo context
static void *SVKvoContext = &SVKvoContext;

@interface DefaultSettingsViewController ()

// Navigation bar items
@property (strong, nonatomic) UIBarButtonItem *editBarButtonItem;
@property (strong, nonatomic) UIBarButtonItem *cancelBarButtonItem;
@property (strong, nonatomic) UIBarButtonItem *saveBarButtonItem;
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



@property (strong, nonatomic) UIButton *editCancelButton;
@property (strong, nonatomic) UIButton *saveButton;

// models
@property (nonatomic, strong) GCSRadioSettings *localRadioSettingsModel;
@property (nonatomic, strong) GCSRadioSettings *remoteRadioSettingsModel;

@end

@implementation DefaultSettingsViewController

-(instancetype)init {
    self = [super init];
    
    if (self) {
        
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
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    
    // configure and start spinner
    [self.activityIndicatorView centerOnView:self.view];
    [self.activityIndicatorView startAnimating];
}

-(void)configureNavigationBar {
    [self setTitle:@"Default Settings"];
    
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
    
    self.localRadioFirmwareVersion.text = nil;
    self.remoteRadioFirmwareVersion.text = nil;
    self.connectionStatus.text = nil;
    self.view.backgroundColor = [GCSThemeManager sharedInstance].appSheetBackgroundColor;
    
    // NetID UI
    self.localRadioNetIdLabel = [UILabel newAutoLayoutView];
    [self.view addSubview:self.localRadioNetIdLabel];
    [self.localRadioNetIdLabel setText:@"Net ID:"];
    self.localRadioNetIdLabel.textAlignment = NSTextAlignmentRight;
    
    self.localRadioNetId = [UITextField newAutoLayoutView];
    self.localRadioNetId.borderStyle = UITextBorderStyleRoundedRect;
    [self.localRadioNetId autoSetDimension:ALDimensionWidth toSize:150.0f];
    [self.view  addSubview:self.localRadioNetId];
    self.localRadioNetId.textAlignment = NSTextAlignmentLeft;
    self.localRadioNetId.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    self.localRadioNetId.delegate = self;
    
    [self.localRadioNetId autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.localRadioNetIdLabel withOffset:10];
    [self.localRadioNetId autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.localRadioNetIdLabel withOffset:0.0f];
    
    // normally the app will propt if a connection is opened to a FWR that needs updated
    // we want an easy way to test the firmware updater.
#if DEBUG
    UIButton *firmwareUpdateButton = [UIButton newAutoLayoutView];
    [firmwareUpdateButton setTitle:@"Update Firmware" forState:UIControlStateNormal];
    [firmwareUpdateButton addTarget:self action:@selector(updateFirmware) forControlEvents:UIControlEventTouchUpInside];
    [firmwareUpdateButton setTitleColor:[GCSThemeManager sharedInstance].appTintColor forState:UIControlStateNormal];
    [self.view addSubview:firmwareUpdateButton];
    
    [firmwareUpdateButton autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10.0f];
    [firmwareUpdateButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:10.0f];
#endif
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.localRadioNetIdLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:88.0f + 10];
    } else {
        [self.localRadioNetIdLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:88.0f];
    }
    
    [self.localRadioNetIdLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.view withOffset:160];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
 
    
    return YES;
}

#pragma mark - UINavigationBar Button handlers

- (void)cancelChanges:(id)sender {

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveSettings:(id)sender {
    DDLogDebug(@"Save Default Settings");
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    return;
}

@end
