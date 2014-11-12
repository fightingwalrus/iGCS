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

@property (strong, nonatomic) UIButton *ftpButton;
@property (strong, nonatomic) UIButton *telnetButton;

@property (strong, nonatomic) UITextField *pickerTextField;
@property (strong, nonatomic) NSArray *animationNames;

@property int sequenceNumber;


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
    [self.manualControlButton setTitle :@"Manual Flight" forState:UIControlStateNormal];
    [self.manualControlButton addTarget:self action:@selector(manualFlight) forControlEvents:UIControlEventTouchUpInside];
    [self.manualControlButton setTitleColor:[GCSThemeManager sharedInstance].appTintColor forState:UIControlStateNormal];
    [self.manualControlButton setTitleColor:[GCSThemeManager sharedInstance].waypointOtherColor forState:UIControlStateHighlighted];
    [self.view addSubview:self.manualControlButton];

    self.emergencyButton = [UIButton newAutoLayoutView];
    [self.emergencyButton setTitle :@"Send Emergency Signal" forState:UIControlStateNormal];
    [self.emergencyButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:35.0]];
    [self.emergencyButton addTarget:self action:@selector(emergency) forControlEvents:UIControlEventTouchUpInside];
    [self.emergencyButton setTitleColor:[GCSThemeManager sharedInstance].appTintColor forState:UIControlStateNormal];
    [self.emergencyButton setTitleColor:[GCSThemeManager sharedInstance].waypointOtherColor forState:UIControlStateHighlighted];
    [self.view addSubview:self.emergencyButton];
    [self.emergencyButton autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [self.emergencyButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:10.0f];
    

    [self.ftpButton autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10.0f];
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
    
    
    [self.takeOffButton autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10.0f];
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
    [self.manualControlButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:240.0f];
    
    [self.doAnimationButton autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [self.doAnimationButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:180.0f];
    
    [self.pickerTextField autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [self.pickerTextField autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:150.0f];
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


- (void) manualFlight {
    NSLog(@"manual flight function");
    
    //http://nscookbook.com/2013/03/ios-programming-recipe-19-using-core-motion-to-access-gyro-and-accelerometer/
    
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.accelerometerUpdateInterval = .01;
    self.motionManager.gyroUpdateInterval = .01;
    
    [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue]
                                            withHandler:^(CMDeviceMotion  *deviceMotion, NSError *error) {
                                                [self outputMotionData:deviceMotion];
                                                if(error){
                                                    
                                                    NSLog(@"%@", error);
                                                }
                                            }];
    
    
}


-(void)outputMotionData:(CMDeviceMotion*)deviceMotion
{
    
    //Probably need to make more robust and switch to Quaternions to calculate the roll, pitch, and yaw values
    
    float roll = (float) deviceMotion.attitude.roll / M_PI * -1.0;
    float pitch = (float) deviceMotion.attitude.pitch / M_PI;
    float yaw =  (float) deviceMotion.attitude.yaw / M_PI;
    
    NSLog(@"The Roll, Pitch, Yaw is %f, %f, %f", roll, pitch, yaw);
    
    NSString *instrumData = [NSString stringWithFormat:@"AT*PCMD=%i,%d,%d,%d,%d,%d\r",
                             self.sequenceNumber,                //seq
                             1,                  //flag
                             *(int*)(&roll),     //roll
                             *(int*)(&pitch),    //pitch
                             0,                  //gaz (vertical speed)
                             *(int*)(&yaw)       //yaw
                             ];
    self.sequenceNumber++;
    NSLog(@"the converted data is %@", instrumData);
    //NSString *testDFL = @"AT*PCMD=1,1,0,0,0,1061158912\r";
    //[[CommController sharedInstance].mavLinkInterface arDroneResetWatchDogTimer];
      [[CommController sharedInstance].mavLinkInterface arDroneMove:instrumData];
    
   
    //[self.arDrone2 droneMove:instrumData];
    
}


@end