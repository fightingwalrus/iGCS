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

@property (strong, nonatomic) UIButton *ftpButton;
@property (strong, nonatomic) UIButton *telnetButton;


@end

@implementation ArDroneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureNavigationBar];
    [self configureViewLayout];
    
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
    [self.view addSubview:self.ftpButton];
    [self.ftpButton autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10.0f];
    [self.ftpButton autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:50.0f];
    
    
    self.telnetButton = [UIButton newAutoLayoutView];
    [self.telnetButton setTitle :@"Execute program on drone" forState:UIControlStateNormal];
    [self.telnetButton addTarget:self action:@selector(telnetProgram) forControlEvents:UIControlEventTouchUpInside];
    [self.telnetButton setTitleColor:[GCSThemeManager sharedInstance].appTintColor forState:UIControlStateNormal];
    [self.view addSubview:self.telnetButton];
    [self.telnetButton autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10.0f];
    [self.telnetButton autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:80.0f];
    
    
    self.takeOffButton = [UIButton newAutoLayoutView];
    [self.takeOffButton setTitle :@"Launch Drone" forState:UIControlStateNormal];
    [self.takeOffButton addTarget:self action:@selector(takeoffProgram) forControlEvents:UIControlEventTouchUpInside];
    [self.takeOffButton setTitleColor:[GCSThemeManager sharedInstance].appTintColor forState:UIControlStateNormal];
    [self.view addSubview:self.takeOffButton];
    [self.takeOffButton autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10.0f];
    [self.takeOffButton autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:130.0f];
    
    self.landButton = [UIButton newAutoLayoutView];
    [self.landButton setTitle :@"Land Drone" forState:UIControlStateNormal];
    [self.landButton addTarget:self action:@selector(landProgram) forControlEvents:UIControlEventTouchUpInside];
    [self.landButton setTitleColor:[GCSThemeManager sharedInstance].appTintColor forState:UIControlStateNormal];
    [self.view addSubview:self.landButton];
    [self.landButton autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10.0f];
    [self.landButton autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:160.0f];
    
    
    self.calibrationButton = [UIButton newAutoLayoutView];
    [self.calibrationButton setTitle :@"Calibrate Magnetometer" forState:UIControlStateNormal];
    [self.calibrationButton addTarget:self action:@selector(calibrationProgram) forControlEvents:UIControlEventTouchUpInside];
    [self.calibrationButton setTitleColor:[GCSThemeManager sharedInstance].appTintColor forState:UIControlStateNormal];
    [self.view addSubview:self.calibrationButton];
    [self.calibrationButton autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10.0f];
    [self.calibrationButton autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:190.0f];

    
    self.doAnimationButton = [UIButton newAutoLayoutView];
    [self.doAnimationButton setTitle :@"Do Animation" forState:UIControlStateNormal];
    [self.doAnimationButton addTarget:self action:@selector(doAnimationProgram) forControlEvents:UIControlEventTouchUpInside];
    [self.doAnimationButton setTitleColor:[GCSThemeManager sharedInstance].appTintColor forState:UIControlStateNormal];
    [self.view addSubview:self.doAnimationButton];
    [self.doAnimationButton autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10.0f];
    [self.doAnimationButton autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:220.0f];
    
    
    self.emergencyButton = [UIButton newAutoLayoutView];
    [self.emergencyButton setTitle :@"Send Emergency Signal" forState:UIControlStateNormal];
    [self.emergencyButton addTarget:self action:@selector(emergencyProgram) forControlEvents:UIControlEventTouchUpInside];
    [self.emergencyButton setTitleColor:[GCSThemeManager sharedInstance].appTintColor forState:UIControlStateNormal];
    [self.view addSubview:self.emergencyButton];
    [self.emergencyButton autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10.0f];
    [self.emergencyButton autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:300.0f];

    
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
    [[CommController sharedInstance].mavLinkInterface arDroneFlipLeft];}


@end
