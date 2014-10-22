//
//  DebugViewController.m
//  iGCS
//
//  Created by Andrew Aarestad on 2/25/13.
//
//

#import "DebugViewController.h"
#import "CommController.h"
#import "Logger.h"
#import "ExceptionHandler.h"

#import "BRRequestCreateDirectory.h"
#import "BRRequestDelete.h"
#import "BRRequestUpload.h"
#import "BRRequestError.h"
#import "BRStreamInfo.h"
#import "BRRequestListDirectory.h"
#import "BRRequestQueue.h"

#import <sys/socket.h>
#import "GCDAsyncSocket.h"
#import "GCDAsyncUdpSocket.h"
#import "FileUtils.h"
#import "iGCSMavLinkInterface.h"
#import "ArDroneUtils.h"
#import "ArDroneViewController.h"


@interface DebugViewController ()

@end

@implementation DebugViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        self.pendingConsoleMessages = [NSMutableArray array];
        self.pendingErrorMessages = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    NSString *videoSource = [[NSUserDefaults standardUserDefaults] valueForKey:@"videoSource"];
    if ([videoSource isEqualToString:@"testStream"]) {
        self.videoSource.selectedSegmentIndex = 0;
    } else {
        self.videoSource.selectedSegmentIndex = 1;
    }
    
    NSString *videoDisplayLocation = [[NSUserDefaults standardUserDefaults] valueForKey:@"videoDisplayLocation"];
    if ([videoDisplayLocation isEqualToString:@"corner"]) {
        self.videoDisplayLocation.selectedSegmentIndex = 0;
    } else {
        self.videoDisplayLocation.selectedSegmentIndex = 1;
    }
    
    [ExceptionHandler start:self];
}


-(void)viewDidAppear:(BOOL)animated
{
    [Logger setDebugVC:self];

    if ([[Logger getPendingErrorMessages] count] > 0)
    {
        for (NSString *message in [Logger getPendingErrorMessages])
        {
            [self errorMessage:message];
        }
    }
    
    [Logger clearPendingErrorMessages];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)bluetoothRxClicked:(id)sender {
    [[CommController sharedInstance] startBluetoothRx];
}


- (IBAction)bluetoothTxClicked:(id)sender {
    [[CommController sharedInstance] startBluetoothTx];
}

- (IBAction)videoSourceValueChanged:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *) sender;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if ([segmentedControl selectedSegmentIndex] == 1) {
        DDLogDebug(@"Video Source: Z3");
        [userDefaults setObject:@"Z3" forKey:@"videoSource"];
    } else {
        DDLogDebug(@"Video Source: Test Stream");
        [userDefaults setObject:@"testStream" forKey:@"videoSource"];
    }
    [userDefaults synchronize];
}


- (IBAction)videoDisplayLocationValueChanged:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if ([segmentedControl selectedSegmentIndex] == 1) {
        DDLogDebug(@"Video Location: Full Screen");
        [userDefaults setObject:@"fullScreen" forKey:@"videoDisplayLocation"];
    } else {
        DDLogDebug(@"Video Source: Test Stream");
        [userDefaults setObject:@"corner" forKey:@"videoDisplayLocation"];
    }
    [userDefaults synchronize];
}

- (IBAction)ftpClicked:(id)sender {
    _arDrone2 = [[ArDroneUtils alloc] init];
    [_arDrone2 uploadProgramToDrone];
}


- (IBAction)telClicked:(id)sender {
    _arDrone2 = [[ArDroneUtils alloc] init];
    [_arDrone2 makeTelnetConnectionToDrone];
}

- (IBAction)mavClicked:(id)sender {
    _arDrone2 = [[ArDroneUtils alloc] init];
    [_arDrone2 mavlinkCommandedTakeoff];
    
}

- (IBAction)lndClicked:(id)sender {
    [[CommController sharedInstance].mavLinkInterface arDroneLand];
}

- (IBAction)rtlClicked:(id)sender {
    _arDrone2 = [[ArDroneUtils alloc] init];
    [_arDrone2 mavlinkReturnToLaunch];
}

- (IBAction)specClicked:(id)sender {
    [[CommController sharedInstance].mavLinkInterface arDroneCalibrateHorizontalPlane];
    [[CommController sharedInstance].mavLinkInterface arDroneTakeOff];
    
}

- (IBAction)emergencyClicked:(id)sender {
   [[CommController sharedInstance].mavLinkInterface arDroneToggleEmergency];
    
}

- (IBAction)calClicked:(id)sender {
    [[CommController sharedInstance].mavLinkInterface arDroneCalibrateMagnetometer];
    
}

- (IBAction)flipClicked:(id)sender {
    [[CommController sharedInstance].mavLinkInterface arDroneFlipLeft];
    
}

- (IBAction)testClicked:(id)sender {
        ArDroneViewController *arDroneViewController = [[ArDroneViewController alloc] init];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:arDroneViewController];
        
        navController.navigationBar.barStyle = UIBarStyleDefault;
        navController.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:navController animated:YES completion:nil];
    
}




-(void)consoleMessage:(NSString*)messageText
{
    NSUInteger consoleMessagesStringLength = [self.consoleTextView.text length];
    NSUInteger maxLength = 1000;
    if(consoleMessagesStringLength > maxLength)
    {
        NSUInteger startIdx = consoleMessagesStringLength - maxLength;
        NSString *cutString = [self.consoleTextView.text substringFromIndex:startIdx];
        NSRange firstReturn = [cutString rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]];
        firstReturn.length = cutString.length - firstReturn.location;
        self.consoleTextView.text = [cutString substringWithRange:firstReturn];
    }
    self.consoleTextView.text = [[self.consoleTextView.text stringByAppendingString:messageText] stringByAppendingString:@"\n"];
    [self.consoleTextView scrollRangeToVisible:NSMakeRange([self.consoleTextView.text length], 0)];
}

-(void)errorMessage:(NSString*)messageText {
    NSString *currentText = self.errorsTextView.text;
    
    NSString *updatedText;
    
    if (currentText) {
        updatedText = [NSString stringWithFormat:@"%@\n%@",currentText,messageText];
    } else {
        updatedText = messageText;
    }
    
    self.errorsTextView.text = updatedText;

}

- (void)viewDidUnload {
    [self setConsoleTextView:nil];
    [self setErrorsTextView:nil];
    [super viewDidUnload];
}

@end




