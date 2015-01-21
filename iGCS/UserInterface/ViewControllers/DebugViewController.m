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
@property (strong) NSMutableArray *pendingConsoleMessages;

@end


@implementation DebugViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _pendingConsoleMessages = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [ExceptionHandler start:self];
}


-(void)viewDidAppear:(BOOL)animated {
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)bluetoothRxClicked:(id)sender {
    [[CommController sharedInstance] startBluetoothRx];
}


- (IBAction)bluetoothTxClicked:(id)sender {
    [[CommController sharedInstance] startBluetoothTx];
}

- (IBAction)arDroneCtrl:(id)sender {
    NSLog(@"You clicked the button, way to go");
    ArDroneViewController *arDroneViewController = [[ArDroneViewController alloc] init];
    [self presentViewController:arDroneViewController animated:YES completion:nil];
    
}




-(void)consoleMessage:(NSString*)messageText {
    NSUInteger consoleMessagesStringLength = [self.consoleTextView.text length];
    NSUInteger maxLength = 1000;
    if(consoleMessagesStringLength > maxLength) {
        NSUInteger startIdx = consoleMessagesStringLength - maxLength;
        NSString *cutString = [self.consoleTextView.text substringFromIndex:startIdx];
        NSRange firstReturn = [cutString rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]];
        firstReturn.length = cutString.length - firstReturn.location;
        self.consoleTextView.text = [cutString substringWithRange:firstReturn];
    }
    self.consoleTextView.text = [[self.consoleTextView.text stringByAppendingString:messageText] stringByAppendingString:@"\n"];
    [self.consoleTextView scrollRangeToVisible:NSMakeRange([self.consoleTextView.text length], 0)];
}



- (void)viewDidUnload {
    [self setConsoleTextView:nil];
    [super viewDidUnload];
}

@end




