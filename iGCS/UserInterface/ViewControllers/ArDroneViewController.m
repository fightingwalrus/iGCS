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

@property (strong, nonatomic) UIButton *ftpButton;
@property (strong, nonatomic) UIButton *telnetButton;

@property (strong, nonatomic) UITextField *tf;
@property (strong, nonatomic) NSArray *theData;




@end

@implementation ArDroneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureNavigationBar];
    [self configureViewLayout];
    UIPickerView *picker = [[UIPickerView alloc] init];
    picker.dataSource = self;
    picker.delegate = self;
    self.tf.inputView = picker;
    self.theData = @[@"Flip Right", @"Flip Left", @"Flip Ahead", @"Flip Behind", @"Wave", @"Turn Around", @"Phi Theta Mixed"];
    
    
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.theData.count;
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return  1;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.theData[row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.tf.text = self.theData[row];
    [self.tf resignFirstResponder];
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
    [self.ftpButton addTarget:self action:@selector(ftpProgram) forControlEvents:UIControlEventTouchUpInside];
    [self.ftpButton setTitleColor:[GCSThemeManager sharedInstance].appTintColor forState:UIControlStateNormal];
    [self.ftpButton setTitleColor:[GCSThemeManager sharedInstance].waypointOtherColor forState:UIControlStateHighlighted];
    [self.view addSubview:self.ftpButton];
 
    
    
    self.telnetButton = [UIButton newAutoLayoutView];
    [self.telnetButton setTitle :@"Execute program on drone" forState:UIControlStateNormal];
    [self.telnetButton addTarget:self action:@selector(telnetProgram) forControlEvents:UIControlEventTouchUpInside];
    [self.telnetButton setTitleColor:[GCSThemeManager sharedInstance].appTintColor forState:UIControlStateNormal];
    [self.telnetButton setTitleColor:[GCSThemeManager sharedInstance].waypointOtherColor forState:UIControlStateHighlighted];
    [self.view addSubview:self.telnetButton];
    
    
    self.takeOffButton = [UIButton newAutoLayoutView];
    [self.takeOffButton setTitle :@"Launch Drone" forState:UIControlStateNormal];
    [self.takeOffButton addTarget:self action:@selector(takeoffProgram) forControlEvents:UIControlEventTouchUpInside];
    [self.takeOffButton setTitleColor:[GCSThemeManager sharedInstance].appTintColor forState:UIControlStateNormal];
    [self.takeOffButton setTitleColor:[GCSThemeManager sharedInstance].waypointOtherColor forState:UIControlStateHighlighted];
    [self.view addSubview:self.takeOffButton];

    
    self.landButton = [UIButton newAutoLayoutView];
    [self.landButton setTitle :@"Land Drone" forState:UIControlStateNormal];
    [self.landButton addTarget:self action:@selector(landProgram) forControlEvents:UIControlEventTouchUpInside];
    [self.landButton setTitleColor:[GCSThemeManager sharedInstance].appTintColor forState:UIControlStateNormal];
    [self.landButton setTitleColor:[GCSThemeManager sharedInstance].waypointOtherColor forState:UIControlStateHighlighted];
    [self.view addSubview:self.landButton];
    
    self.calibrationButton = [UIButton newAutoLayoutView];
    [self.calibrationButton setTitle :@"Calibrate Magnetometer" forState:UIControlStateNormal];
    [self.calibrationButton addTarget:self action:@selector(calibrationProgram) forControlEvents:UIControlEventTouchUpInside];
    [self.calibrationButton setTitleColor:[GCSThemeManager sharedInstance].appTintColor forState:UIControlStateNormal];
    [self.calibrationButton setTitleColor:[GCSThemeManager sharedInstance].waypointOtherColor forState:UIControlStateHighlighted];
    [self.view addSubview:self.calibrationButton];
 
    
    self.doAnimationButton = [UIButton newAutoLayoutView];
    [self.doAnimationButton setTitle :@"Do Animation" forState:UIControlStateNormal];
    [self.doAnimationButton addTarget:self action:@selector(doAnimationProgram) forControlEvents:UIControlEventTouchUpInside];
    [self.doAnimationButton setTitleColor:[GCSThemeManager sharedInstance].appTintColor forState:UIControlStateNormal];
    [self.doAnimationButton setTitleColor:[GCSThemeManager sharedInstance].waypointOtherColor forState:UIControlStateHighlighted];
    [self.view addSubview:self.doAnimationButton];
    
    
    self.resetWatchDogButton = [UIButton newAutoLayoutView];
    [self.resetWatchDogButton setTitle :@"Reset Watchdog Timer" forState:UIControlStateNormal];
    [self.resetWatchDogButton addTarget:self action:@selector(doAnimationProgram) forControlEvents:UIControlEventTouchUpInside];
    [self.resetWatchDogButton setTitleColor:[GCSThemeManager sharedInstance].appTintColor forState:UIControlStateNormal];
    [self.resetWatchDogButton setTitleColor:[GCSThemeManager sharedInstance].waypointOtherColor forState:UIControlStateHighlighted];
    [self.view addSubview:self.resetWatchDogButton];

    
    
    self.emergencyButton = [UIButton newAutoLayoutView];
    [self.emergencyButton setTitle :@"Send Emergency Signal" forState:UIControlStateNormal];
    [self.emergencyButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:35.0]];
    [self.emergencyButton addTarget:self action:@selector(emergencyProgram) forControlEvents:UIControlEventTouchUpInside];
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


    self.tf = [UITextField newAutoLayoutView];
    [self.tf setText :@"Choose Animation"];
    //[self.tf.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:35.0]];
    [self.tf addTarget:self action:@selector(emergencyProgram) forControlEvents:UIControlEventTouchUpInside];
    [self.tf setTextColor:[GCSThemeManager sharedInstance].appTintColor];
    //[self.tf setTitleColor:[GCSThemeManager sharedInstance].waypointOtherColor forState:UIControlStateHighlighted];
    [self.view addSubview:self.tf];
    
    
    [self.doAnimationButton autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [self.doAnimationButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:180.0f];
    
    [self.tf autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [self.tf autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:150.0f];
    
    
}



#pragma mark - UINavigationBar Button handlers

- (void)cancelChanges:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) ftpProgram {
    _arDrone2 = [[ArDroneUtils alloc] init];
    [_arDrone2 uploadProgramToDrone];
}

- (void) telnetProgram {
    _arDrone2 = [[ArDroneUtils alloc] init];
    [_arDrone2 makeTelnetConnectionToDrone];
}

- (void) takeoffProgram {
    [[CommController sharedInstance].mavLinkInterface arDroneCalibrateHorizontalPlane];
    [[CommController sharedInstance].mavLinkInterface arDroneTakeOff];}

- (void) landProgram {
    [[CommController sharedInstance].mavLinkInterface arDroneLand];}

- (void) calibrationProgram {
    [[CommController sharedInstance].mavLinkInterface arDroneCalibrateMagnetometer];}

- (void) emergencyProgram {
    [[CommController sharedInstance].mavLinkInterface arDroneToggleEmergency];}

- (void) doAnimationProgram {

    
    
    if ([self.tf.text isEqualToString:@"Flip Left"])
        [[CommController sharedInstance].mavLinkInterface arDroneFlipLeft];
    else if ([self.tf.text isEqualToString:@"Flip Right"])
        [[CommController sharedInstance].mavLinkInterface arDroneFlipRight];
    else if ([self.tf.text isEqualToString:@"Flip Ahead"])
        [[CommController sharedInstance].mavLinkInterface arDroneFlipAhead];
    else if ([self.tf.text isEqualToString:@"Flip Behind"])
        [[CommController sharedInstance].mavLinkInterface arDroneFlipBehind];
    else if ([self.tf.text isEqualToString:@"Wave"])
        [[CommController sharedInstance].mavLinkInterface arDroneWave];
    else if ([self.tf.text isEqualToString:@"Turn Around"])
        [[CommController sharedInstance].mavLinkInterface arDroneTurnAround];
    else if ([self.tf.text isEqualToString:@"Phi Theta Mixed"])
        [[CommController sharedInstance].mavLinkInterface arDronePhiThetaMixed];
    
    }
        
        
    


@end
