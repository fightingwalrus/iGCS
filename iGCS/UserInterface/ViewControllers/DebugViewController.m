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
    //----- get the file to upload as an NSData object
    _uploadData = [FileUtils dataFromFileInMainBundleWithName: @"ser2udp.gz"];
    
    _uploadFile = [[BRRequestUpload alloc] initWithDelegate: self];
    
    //----- for anonymous login just leave the username and password nil
    _uploadFile.path = @"ser2udp.gz";
    _uploadFile.hostname = @"192.168.1.1";
    _uploadFile.username = nil;
    _uploadFile.password = nil;
    
    //we start the request
    [_uploadFile start];
}


- (IBAction)telClicked:(id)sender {
    
    NSLog(@"%s",__FUNCTION__);
    gcdsocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError *err = nil;
    if (![gcdsocket connectToHost:@"192.168.1.1" onPort:23 error:&err]) {
        NSLog(@"I goofed: %@", err);
    }
    [gcdsocket readDataWithTimeout:5 tag:1];
    
    
    
    NSLog(@"Unzipping program");
    NSString *requestStr = @"gunzip -f data/video/ser2udp.gz\r";
    NSData *requestData = [requestStr dataUsingEncoding:NSUTF8StringEncoding];
    [gcdsocket writeData:requestData withTimeout:1.0 tag:0];
    
    NSLog(@"changing permissions");
    requestStr = @"chmod 755 data/video/ser2udp\r";
    requestData = [requestStr dataUsingEncoding:NSUTF8StringEncoding];
    [gcdsocket writeData:requestData withTimeout:1.0 tag:0];
    
    NSLog(@"running program");
    requestStr = @"data/video/ser2udp\r";
    requestData = [requestStr dataUsingEncoding:NSUTF8StringEncoding];
    [gcdsocket writeData:requestData withTimeout:1.0 tag:0];

    
}


- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    NSLog(@"Telnet Connected!");
}


- (IBAction)mavClicked:(id)sender {
    NSLog(@"Mav Button Clicked");
       [[CommController sharedInstance].mavLinkInterface sendMavtest];
    
    
}

- (IBAction)lndClicked:(id)sender {
    NSLog(@"LND Button Clicked");
    [[CommController sharedInstance].mavLinkInterface sendArdroneLand];
    
}

<<<<<<< HEAD
=======
- (IBAction)rtlClicked:(id)sender {
    NSLog(@"RTL Button Clicked");
    [[CommController sharedInstance].mavLinkInterface sendArdroneRtl];
    
}


>>>>>>> added function for Return to Launch
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

-(void)errorMessage:(NSString*)messageText
{
    NSString *currentText = self.errorsTextView.text;
    
    NSString *updatedText;
    
    if (currentText)
    {
        updatedText = [NSString stringWithFormat:@"%@\n%@",currentText,messageText];
    }
    else
    {
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




