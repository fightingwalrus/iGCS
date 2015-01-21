//
//  ArDroneViewController.m
//  iGCS
//
//  Created by David Leskowicz on 10/21/14.
//
//

#import "CommController.h"
#import "ArDroneViewController.h"
#import "GCSThemeManager.h"
#import "PureLayout.h"
#import "ArDroneUtils.h"
#import "CoreMotionUtils.h"

@interface ArDroneViewController ()

//Navigation bar items
@property (strong, nonatomic) UIBarButtonItem *cancelBarButtonItem;




//UI Elements
@property (strong, nonatomic) UIButton *takeOffButton;
@property (strong, nonatomic) UIButton *landButton;
@property (strong, nonatomic) UIButton *emergencyButton;
@property (strong, nonatomic) UIButton *doAnimationButton;
@property (strong, nonatomic) UIButton *calibrationButton;
@property (strong, nonatomic) UIButton *resetWatchDogButton;
@property (strong, nonatomic) UIButton *manualControlButton;
@property (strong, nonatomic) UIButton *stopManualControlButton;
@property (strong, nonatomic) UIButton *thrustPlusButton;
@property (strong, nonatomic) UIButton *thrustMinusButton;
@property (strong, nonatomic) UIButton *thrustZeroButton;

@property (strong, nonatomic) UIButton *pitchRollButton;

@property (strong, nonatomic) UIButton *upTwoButton;
@property (strong, nonatomic) UIButton *upOneButton;
@property (strong, nonatomic) UIButton *neutralButton;
@property (strong, nonatomic) UIButton *downOneButton;
@property (strong, nonatomic) UIButton *downTwoButton;




@property (strong, nonatomic) UIButton *ftpButton;
@property (strong, nonatomic) UIButton *telnetButton;

@property (strong, nonatomic) UITextField *pickerTextField;
@property (strong, nonatomic) NSArray *animationNames;

@property (nonatomic, assign) uint16_t sequenceNumber;
@property (nonatomic, assign) int16_t thrust;

@property (strong, nonatomic) CMAttitude* rollPitchOffset;
@property (strong, nonatomic) CMAttitude* yawOffset;

@property (nonatomic, assign) AngleStatusType sendRollPitch;
@property (nonatomic, assign) AngleStatusType sendYawThrust;





@end

@implementation ArDroneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureNavigationBar];
    [self configureViewLayout];
    UIPickerView *picker = [[UIPickerView alloc] init];
    picker.dataSource = self;
    picker.delegate = self;
    self.pickerTextField.inputView = picker;
    self.animationNames = @[@"Flip Right", @"Flip Left", @"Flip Ahead", @"Flip Behind", @"Wave", @"Turn Around", @"Phi Theta Mixed"];
    _arDrone2 = [[ArDroneUtils alloc] init];
    self.sequenceNumber = 1;
    self.thrust = 0;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.animationNames.count;
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return  1;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.animationNames[row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.pickerTextField.text = self.animationNames[row];
    [self.pickerTextField resignFirstResponder];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)configureNavigationBar {
    [self setTitle:@"ArDrone Test"];
    self.cancelBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                             target:self action:@selector(cancelChanges:)];
    
    self.navigationItem.leftBarButtonItem = self.cancelBarButtonItem;
   }

-(void)configureViewLayout {
    
    self.view.backgroundColor = [GCSThemeManager sharedInstance].appSheetBackgroundColor;
    
    self.ftpButton = [UIButton newAutoLayoutView];
    [self.ftpButton setTitle :@"FTP program to drone" forState:UIControlStateNormal];
    [self.ftpButton addTarget:self action:@selector(ftp) forControlEvents:UIControlEventTouchUpInside];
    [self.ftpButton setTitleColor:[GCSThemeManager sharedInstance].appTintColor forState:UIControlStateNormal];
    [self.ftpButton setTitleColor:[GCSThemeManager sharedInstance].waypointOtherColor forState:UIControlStateHighlighted];
    [self.view addSubview:self.ftpButton];

    self.telnetButton = [UIButton newAutoLayoutView];
    [self.telnetButton setTitle :@"Execute program on drone" forState:UIControlStateNormal];
    [self.telnetButton addTarget:self action:@selector(telnet) forControlEvents:UIControlEventTouchUpInside];
    [self.telnetButton setTitleColor:[GCSThemeManager sharedInstance].appTintColor forState:UIControlStateNormal];
    [self.telnetButton setTitleColor:[GCSThemeManager sharedInstance].waypointOtherColor forState:UIControlStateHighlighted];
    [self.view addSubview:self.telnetButton];
    
    self.takeOffButton = [UIButton newAutoLayoutView];
    [self.takeOffButton setTitle :@"Launch Drone" forState:UIControlStateNormal];
    [self.takeOffButton addTarget:self action:@selector(takeoff) forControlEvents:UIControlEventTouchUpInside];
    [self.takeOffButton setTitleColor:[GCSThemeManager sharedInstance].appTintColor forState:UIControlStateNormal];
    [self.takeOffButton setTitleColor:[GCSThemeManager sharedInstance].waypointOtherColor forState:UIControlStateHighlighted];
    [self.view addSubview:self.takeOffButton];

    self.landButton = [UIButton newAutoLayoutView];
    [self.landButton setTitle :@"Land Drone" forState:UIControlStateNormal];
    [self.landButton addTarget:self action:@selector(land) forControlEvents:UIControlEventTouchUpInside];
    [self.landButton setTitleColor:[GCSThemeManager sharedInstance].appTintColor forState:UIControlStateNormal];
    [self.landButton setTitleColor:[GCSThemeManager sharedInstance].waypointOtherColor forState:UIControlStateHighlighted];
    [self.view addSubview:self.landButton];
    
    self.calibrationButton = [UIButton newAutoLayoutView];
    [self.calibrationButton setTitle :@"Calibrate Magnetometer" forState:UIControlStateNormal];
    [self.calibrationButton addTarget:self action:@selector(calibration) forControlEvents:UIControlEventTouchUpInside];
    [self.calibrationButton setTitleColor:[GCSThemeManager sharedInstance].appTintColor forState:UIControlStateNormal];
    [self.calibrationButton setTitleColor:[GCSThemeManager sharedInstance].waypointOtherColor forState:UIControlStateHighlighted];
    [self.view addSubview:self.calibrationButton];
    
    self.doAnimationButton = [UIButton newAutoLayoutView];
    [self.doAnimationButton setTitle :@"Do Animation" forState:UIControlStateNormal];
    [self.doAnimationButton addTarget:self action:@selector(executeAnimation) forControlEvents:UIControlEventTouchUpInside];
    [self.doAnimationButton setTitleColor:[GCSThemeManager sharedInstance].appTintColor forState:UIControlStateNormal];
    [self.doAnimationButton setTitleColor:[GCSThemeManager sharedInstance].waypointOtherColor forState:UIControlStateHighlighted];
    [self.view addSubview:self.doAnimationButton];
    
    self.resetWatchDogButton = [UIButton newAutoLayoutView];
    [self.resetWatchDogButton setTitle :@"Reset Watchdog Timer" forState:UIControlStateNormal];
    [self.resetWatchDogButton addTarget:self action:@selector(resetWatchDogTimer) forControlEvents:UIControlEventTouchUpInside];
    [self.resetWatchDogButton setTitleColor:[GCSThemeManager sharedInstance].appTintColor forState:UIControlStateNormal];
    [self.resetWatchDogButton setTitleColor:[GCSThemeManager sharedInstance].waypointOtherColor forState:UIControlStateHighlighted];
    [self.view addSubview:self.resetWatchDogButton];
    
    self.manualControlButton = [UIButton newAutoLayoutView];
    [self.manualControlButton setTitle :@"Start Manual Flight" forState:UIControlStateNormal];
    [self.manualControlButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:18.0]];
    [self.manualControlButton addTarget:self action:@selector(manualFlight) forControlEvents:UIControlEventTouchUpInside];
    [self.manualControlButton setTitleColor:[GCSThemeManager sharedInstance].appTintColor forState:UIControlStateNormal];
    [self.manualControlButton setTitleColor:[GCSThemeManager sharedInstance].waypointOtherColor forState:UIControlStateHighlighted];
    [self.view addSubview:self.manualControlButton];
    
    self.stopManualControlButton = [UIButton newAutoLayoutView];
    [self.stopManualControlButton setTitle :@"Stop Manual Flight" forState:UIControlStateNormal];
    [self.stopManualControlButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:18.0]];
    [self.stopManualControlButton addTarget:self action:@selector(stopManualFlight) forControlEvents:UIControlEventTouchUpInside];
    [self.stopManualControlButton setTitleColor:[GCSThemeManager sharedInstance].appTintColor forState:UIControlStateNormal];
    [self.stopManualControlButton setTitleColor:[GCSThemeManager sharedInstance].waypointOtherColor forState:UIControlStateHighlighted];
    [self.view addSubview:self.stopManualControlButton];
    
    
    self.thrustPlusButton = [UIButton newAutoLayoutView];
    [self.thrustPlusButton setTitle :@"+" forState:UIControlStateNormal];
    [self.thrustPlusButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:50.0]];
    [self.thrustPlusButton addTarget:self action:@selector(plusThrust) forControlEvents:UIControlEventTouchUpInside];
    [self.thrustPlusButton setTitleColor:[GCSThemeManager sharedInstance].appTintColor forState:UIControlStateNormal];
    [self.thrustPlusButton setTitleColor:[GCSThemeManager sharedInstance].waypointOtherColor forState:UIControlStateHighlighted];
    [self.view addSubview:self.thrustPlusButton];
    
    self.thrustMinusButton = [UIButton newAutoLayoutView];
    [self.thrustMinusButton setTitle :@"-" forState:UIControlStateNormal];
    [self.thrustMinusButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:50.0]];
    [self.thrustMinusButton addTarget:self action:@selector(minusThrust) forControlEvents:UIControlEventTouchUpInside];
    [self.thrustMinusButton setTitleColor:[GCSThemeManager sharedInstance].appTintColor forState:UIControlStateNormal];
    [self.thrustMinusButton setTitleColor:[GCSThemeManager sharedInstance].waypointOtherColor forState:UIControlStateHighlighted];
    [self.view addSubview:self.thrustMinusButton];
    
    self.thrustZeroButton = [UIButton newAutoLayoutView];
    [self.thrustZeroButton setTitle :@"0" forState:UIControlStateNormal];
    [self.thrustZeroButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:50.0]];
    [self.thrustZeroButton addTarget:self action:@selector(zeroThrust) forControlEvents:UIControlEventTouchUpInside];
    [self.thrustZeroButton setTitleColor:[GCSThemeManager sharedInstance].appTintColor forState:UIControlStateNormal];
    [self.thrustZeroButton setTitleColor:[GCSThemeManager sharedInstance].waypointOtherColor forState:UIControlStateHighlighted];
    [self.view addSubview:self.thrustZeroButton];
    
    

    self.emergencyButton = [UIButton newAutoLayoutView];
    [self.emergencyButton setTitle :@"Send Emergency Signal" forState:UIControlStateNormal];
    [self.emergencyButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:35.0]];
    [self.emergencyButton addTarget:self action:@selector(emergency) forControlEvents:UIControlEventTouchUpInside];
    [self.emergencyButton setTitleColor:[GCSThemeManager sharedInstance].appTintColor forState:UIControlStateNormal];
    [self.emergencyButton setTitleColor:[GCSThemeManager sharedInstance].waypointOtherColor forState:UIControlStateHighlighted];
    [self.view addSubview:self.emergencyButton];
    [self.emergencyButton autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [self.emergencyButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:10.0f];
    
    
    
    
    
    
    self.pitchRollButton = [UIButton newAutoLayoutView];
    [self.pitchRollButton setTitle :@"O" forState:UIControlStateNormal];
    [self.pitchRollButton addTarget:self action:@selector(pitchRoll) forControlEvents:UIControlEventTouchDown];
    [self.pitchRollButton addTarget:self action:@selector(pitchRollRelease) forControlEvents:UIControlEventTouchUpInside];
    [self.pitchRollButton addTarget:self action:@selector(pitchRollRelease) forControlEvents:UIControlEventTouchUpOutside];
    self.pitchRollButton.backgroundColor = [UIColor grayColor];
    [self.pitchRollButton setTitleColor:[GCSThemeManager sharedInstance].appTintColor forState:UIControlStateNormal];
    [self.pitchRollButton setTitleColor:[GCSThemeManager sharedInstance].waypointOtherColor forState:UIControlStateHighlighted];
    [self.view addSubview:self.pitchRollButton];
    
    [self.pitchRollButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:160];
    [self.pitchRollButton autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:160];
    [self.pitchRollButton autoSetDimension:ALDimensionHeight toSize:100];
    [self.pitchRollButton autoSetDimension:ALDimensionWidth toSize:100];
    
    CGFloat buttonWidths = 80;
    CGFloat buttonHeights = 140;
    
    self.neutralButton = [UIButton newAutoLayoutView];
    [self.neutralButton setTitle :@"--" forState:UIControlStateNormal];
    [self.neutralButton addTarget:self action:@selector(neutral) forControlEvents:UIControlEventTouchDown];
    [self.neutralButton addTarget:self action:@selector(neutralRelease) forControlEvents:UIControlEventTouchUpInside];
    [self.neutralButton addTarget:self action:@selector(neutralRelease) forControlEvents:UIControlEventTouchUpOutside];
    self.neutralButton.backgroundColor = [UIColor grayColor];
    [self.neutralButton setTitleColor:[GCSThemeManager sharedInstance].appTintColor forState:UIControlStateNormal];
    [self.neutralButton setTitleColor:[GCSThemeManager sharedInstance].waypointOtherColor forState:UIControlStateHighlighted];
    [self.view addSubview:self.neutralButton];
    
    [self.neutralButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [self.neutralButton autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [self.neutralButton autoSetDimension:ALDimensionHeight toSize:buttonHeights];
    [self.neutralButton autoSetDimension:ALDimensionWidth toSize:buttonWidths];
    
    
    

    
    self.upOneButton = [UIButton newAutoLayoutView];
    [self.upOneButton setTitle :@"^" forState:UIControlStateNormal];
    [self.upOneButton addTarget:self action:@selector(oneUp) forControlEvents:UIControlEventTouchDown];
    [self.upOneButton addTarget:self action:@selector(oneUpRelease) forControlEvents:UIControlEventTouchUpInside];
    [self.upOneButton addTarget:self action:@selector(oneUpRelease) forControlEvents:UIControlEventTouchUpOutside];
    self.upOneButton.backgroundColor = [UIColor blueColor];
    [self.upOneButton setTitleColor:[GCSThemeManager sharedInstance].appTintColor forState:UIControlStateNormal];
    [self.upOneButton setTitleColor:[GCSThemeManager sharedInstance].waypointOtherColor forState:UIControlStateHighlighted];
    [self.view addSubview:self.upOneButton];
    
    [self.upOneButton autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [self.upOneButton autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:self.neutralButton];
    [self.upOneButton autoSetDimension:ALDimensionHeight toSize:buttonHeights];
    [self.upOneButton autoSetDimension:ALDimensionWidth toSize:buttonWidths];
    
    
    
    self.upTwoButton = [UIButton newAutoLayoutView];
    [self.upTwoButton setTitle :@"^^" forState:UIControlStateNormal];
    [self.upTwoButton addTarget:self action:@selector(twoUp) forControlEvents:UIControlEventTouchDown];
    [self.upTwoButton addTarget:self action:@selector(twoUpRelease) forControlEvents:UIControlEventTouchUpInside];
    [self.upTwoButton addTarget:self action:@selector(twoUpRelease) forControlEvents:UIControlEventTouchUpOutside];
    self.upTwoButton.backgroundColor = [UIColor greenColor];
    [self.upTwoButton setTitleColor:[GCSThemeManager sharedInstance].appTintColor forState:UIControlStateNormal];
    [self.upTwoButton setTitleColor:[GCSThemeManager sharedInstance].waypointOtherColor forState:UIControlStateHighlighted];
    [self.view addSubview:self.upTwoButton];
    
    [self.upTwoButton autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [self.upTwoButton autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:self.upOneButton];
    [self.upTwoButton autoSetDimension:ALDimensionHeight toSize:buttonHeights];
    [self.upTwoButton autoSetDimension:ALDimensionWidth toSize:buttonWidths];
    
    self.downOneButton = [UIButton newAutoLayoutView];
    [self.downOneButton setTitle :@"v" forState:UIControlStateNormal];
    [self.downOneButton addTarget:self action:@selector(oneDown) forControlEvents:UIControlEventTouchDown];
    [self.downOneButton addTarget:self action:@selector(oneDownRelease) forControlEvents:UIControlEventTouchUpInside];
    [self.downOneButton addTarget:self action:@selector(oneDownRelease) forControlEvents:UIControlEventTouchUpOutside];
    self.downOneButton.backgroundColor = [UIColor yellowColor];
    [self.downOneButton setTitleColor:[GCSThemeManager sharedInstance].appTintColor forState:UIControlStateNormal];
    [self.downOneButton setTitleColor:[GCSThemeManager sharedInstance].waypointOtherColor forState:UIControlStateHighlighted];
    [self.view addSubview:self.downOneButton];
    
    [self.downOneButton autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [self.downOneButton autoPinEdge:ALEdgeTop  toEdge:ALEdgeBottom ofView:self.neutralButton];
    [self.downOneButton autoSetDimension:ALDimensionHeight toSize:buttonHeights];
    [self.downOneButton autoSetDimension:ALDimensionWidth toSize:buttonWidths];
    
    self.downTwoButton = [UIButton newAutoLayoutView];
    [self.downTwoButton setTitle :@"vv" forState:UIControlStateNormal];
    [self.downTwoButton addTarget:self action:@selector(twoDown) forControlEvents:UIControlEventTouchDown];
    [self.downTwoButton addTarget:self action:@selector(twoDownRelease) forControlEvents:UIControlEventTouchUpInside];
    [self.downTwoButton addTarget:self action:@selector(twoDownRelease) forControlEvents:UIControlEventTouchUpOutside];
    self.downTwoButton.backgroundColor = [UIColor redColor];
    [self.downTwoButton setTitleColor:[GCSThemeManager sharedInstance].appTintColor forState:UIControlStateNormal];
    [self.downTwoButton setTitleColor:[GCSThemeManager sharedInstance].waypointOtherColor forState:UIControlStateHighlighted];
    [self.view addSubview:self.downTwoButton];
    
    [self.downTwoButton autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [self.downTwoButton autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.downOneButton];
    [self.downTwoButton autoSetDimension:ALDimensionHeight toSize:buttonHeights];
    [self.downTwoButton autoSetDimension:ALDimensionWidth toSize:buttonWidths];
    
    
    
    
    
    [self.ftpButton autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [self.ftpButton autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:80.0f];

    
    NSArray *buttonlViews = @[self.ftpButton, self.telnetButton];
    
    UIView *previousLabel = nil;
    for (UIView *view in buttonlViews) {
        if (previousLabel) {
            [view autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:previousLabel withOffset:0.0f];
            [view autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:previousLabel withOffset:0.0f];
            UILayoutPriority priority = (view == self.ftpButton) ? UILayoutPriorityDefaultHigh + 1 : UILayoutPriorityRequired;
            [UIView autoSetPriority:priority forConstraints:^{
                [view autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:previousLabel];
            }];
        }
        previousLabel = view;
    }
    
    
    [self.takeOffButton autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [self.takeOffButton autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:180.0f];
    
    NSArray *buttonlViews2 = @[self.takeOffButton, self.landButton, self.calibrationButton, self.resetWatchDogButton];
    
    previousLabel = nil;
    for (UIView *view in buttonlViews2) {
        if (previousLabel) {
            [view autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:previousLabel withOffset:0.0f];
            [view autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:previousLabel withOffset:0.0f];
            UILayoutPriority priority = (view == self.takeOffButton) ? UILayoutPriorityDefaultHigh + 1 : UILayoutPriorityRequired;
            [UIView autoSetPriority:priority forConstraints:^{
                [view autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:previousLabel];
            }];
        }
        previousLabel = view;
    }

    self.pickerTextField = [UITextField newAutoLayoutView];
    [self.pickerTextField setText :@"Choose Animation"];
    [self.pickerTextField addTarget:self action:@selector(emergency) forControlEvents:UIControlEventTouchUpInside];
    [self.pickerTextField setTextColor:[GCSThemeManager sharedInstance].appTintColor];
    [self.view addSubview:self.pickerTextField];
    
    [self.manualControlButton autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [self.manualControlButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:300.0f];
    
    [self.stopManualControlButton autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [self.stopManualControlButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:240.0f];
    
    
    [self.thrustPlusButton autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:30.0f];
    [self.thrustPlusButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:500.0f];
    
    [self.thrustZeroButton autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:30.0f];
    [self.thrustZeroButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:400.0f];
    
    [self.thrustMinusButton autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:30.0f];
    [self.thrustMinusButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:300.0f];

    
    [self.doAnimationButton autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [self.doAnimationButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:160.0f];
    
    [self.pickerTextField autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [self.pickerTextField autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:130.0f];
}



#pragma mark - UINavigationBar Button handlers

- (void)cancelChanges:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) ftp {
    [self.arDrone2 uploadProgramToDrone];
}

- (void) telnet {
    [self.arDrone2 makeTelnetConnectionToDrone];
}

- (void) takeoff {
    [[CommController sharedInstance].mavLinkInterface arDroneCalibrateHorizontalPlane];
    [[CommController sharedInstance].mavLinkInterface arDroneTakeOff];
}

- (void) land {
    [[CommController sharedInstance].mavLinkInterface arDroneLand];
}

- (void) calibration {
    [[CommController sharedInstance].mavLinkInterface arDroneCalibrateMagnetometer];
}

- (void) emergency {
    [[CommController sharedInstance].mavLinkInterface arDroneToggleEmergency];
}

- (void) resetWatchDogTimer {
    [[CommController sharedInstance].mavLinkInterface arDroneResetWatchDogTimer];
}

- (void) pitchRoll {
    NSLog(@"pitchRoll Down");
    self.sendRollPitch = angleNeedsOffset;
}

- (void) pitchRollRelease {
    NSLog(@"pitchRoll Released");
    self.sendRollPitch = angleNotUsed;
}

- (void) twoUp {
    NSLog(@"TwoUp Down");
    self.sendYawThrust = angleNeedsOffset;
    self.thrust = 1000;
}

- (void) twoUpRelease {
    NSLog(@"TwoUp Released");
    self.sendYawThrust = angleNotUsed;
}

- (void) oneUp {
    NSLog(@"OneUp Down");
    self.sendYawThrust = angleNeedsOffset;
    self.thrust = 500;
}

- (void) oneUpRelease {
    NSLog(@"OneUp Released");
    self.sendYawThrust = angleNotUsed;
}

- (void) neutral {
    NSLog(@"Neutral Down");
    self.sendYawThrust = angleNeedsOffset;
    self.thrust = 0;

}

- (void) neutralRelease {
    NSLog(@"Neutral Released");
    self.sendYawThrust = angleNotUsed;
}

- (void) oneDown {
    NSLog(@"OneDown Down");
    self.sendYawThrust = angleNeedsOffset;
    self.thrust = -500;
}

- (void) oneDownRelease {
    NSLog(@"OneDown Released");
    self.sendYawThrust = angleNotUsed;
}

- (void) twoDown {
    NSLog(@"TwoDown Down");
    self.sendYawThrust = angleNeedsOffset;
    self.thrust = -1000;
}

- (void) twoDownRelease {
    NSLog(@"TwoDown Released");
    self.sendYawThrust = angleNotUsed;

}




- (void) executeAnimation {
    if ([self.pickerTextField.text isEqualToString:@"Flip Left"])
        [[CommController sharedInstance].mavLinkInterface arDroneFlipLeft];
    else if ([self.pickerTextField.text isEqualToString:@"Flip Right"])
        [[CommController sharedInstance].mavLinkInterface arDroneFlipRight];
    else if ([self.pickerTextField.text isEqualToString:@"Flip Ahead"])
        [[CommController sharedInstance].mavLinkInterface arDroneFlipAhead];
    else if ([self.pickerTextField.text isEqualToString:@"Flip Behind"])
        [[CommController sharedInstance].mavLinkInterface arDroneFlipBehind];
    else if ([self.pickerTextField.text isEqualToString:@"Wave"])
        [[CommController sharedInstance].mavLinkInterface arDroneWave];
    else if ([self.pickerTextField.text isEqualToString:@"Turn Around"])
        [[CommController sharedInstance].mavLinkInterface arDroneTurnAround];
    else if ([self.pickerTextField.text isEqualToString:@"Phi Theta Mixed"])
        [[CommController sharedInstance].mavLinkInterface arDronePhiThetaMixed];
}

- (void) viewDidDisappear:(BOOL)animated{
    [self.motionManager stopDeviceMotionUpdates];
}


- (void) manualFlight {
    //http://nscookbook.com/2013/03/ios-programming-recipe-19-using-core-motion-to-access-gyro-and-accelerometer/
    
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.accelerometerUpdateInterval = .03;
    self.motionManager.gyroUpdateInterval = .03;
    
    [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue]
                                            withHandler:^(CMDeviceMotion  *deviceMotion, NSError *error) {
                                                
                                                int16_t yaw = 0;
                                                int16_t roll = 0;
                                                int16_t pitch = 0;
                                                int16_t thrust = 0;
                                                //Get offsets at time of initial button press for each button
                                                if(self.sendRollPitch == angleNeedsOffset)
                                                {
                                                    self.rollPitchOffset = [deviceMotion.attitude copy];
                                                    self.sendRollPitch = angleHasOffset;
                                                }
                                                
                                                if(self.sendYawThrust == angleNeedsOffset)
                                                {
                                                    self.yawOffset = [deviceMotion.attitude copy];
                                                    self.sendYawThrust = angleHasOffset;
                                                }
                                                
                                                //Once we have the offsets lets calculate the angles based on those offsets
                                                if (self.sendRollPitch != angleNotUsed) {
                                                    GCSMAVRotationAngles anglesOfRotation = [self outputMotionData:deviceMotion relativeToOffset:self.rollPitchOffset];

                                                    roll = anglesOfRotation.roll;
                                                    pitch = anglesOfRotation.pitch;
                                                }
                                                if (self.sendYawThrust != angleNotUsed)
                                                {
                                                    GCSMAVRotationAngles anglesOfRotation2 = [self outputMotionData:deviceMotion relativeToOffset:self.yawOffset];
                                                    yaw = anglesOfRotation2.yaw;
                                                    thrust = self.thrust;
                                                }
                                                
                                                DDLogDebug(@"Pitch : %d, Roll : %d, Yaw : %d, Thrust : %d", pitch, roll, yaw, thrust);
                                                

                                                [[CommController sharedInstance].mavLinkInterface sendMoveCommandWithPitch:pitch andRoll:roll andThrust:thrust andYaw:yaw andSequenceNumber:self.sequenceNumber];
                                                self.sequenceNumber++;
                                                if(error){
                                                    
                                                    DDLogDebug(@"%@", error);
                                                }
                                            }];
}


-(GCSMAVRotationAngles)outputMotionData:(CMDeviceMotion*)deviceMotion {
    CMQuaternion quat = deviceMotion.attitude.quaternion;
    GCSMAVRotationAngles anglesOfRotation = [CoreMotionUtils normalizedRotationAnglesFromQuaternion:quat];
    return anglesOfRotation;
}

-(GCSMAVRotationAngles)outputMotionData:(CMDeviceMotion*)deviceMotion relativeToOffset: (CMAttitude*) offset{
    [deviceMotion.attitude multiplyByInverseOfAttitude:offset];
    CMQuaternion quat = deviceMotion.attitude.quaternion;
    GCSMAVRotationAngles anglesOfRotation = [CoreMotionUtils normalizedRotationAnglesFromQuaternion:quat];
    return anglesOfRotation;
}


- (void) stopManualFlight {
    [self.motionManager stopDeviceMotionUpdates];
    [[CommController sharedInstance].mavLinkInterface sendMoveCommandWithPitch:0 andRoll:0 andThrust:0 andYaw:0 andSequenceNumber:1];
        self.thrust = 0;
}

- (void) plusThrust {
    self.thrust = 500;
}

- (void) minusThrust {
    self.thrust = -500;
}

- (void) zeroThrust {
    self.thrust = 0;
}


@end
