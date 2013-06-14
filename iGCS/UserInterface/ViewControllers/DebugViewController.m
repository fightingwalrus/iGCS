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
    
    [ExceptionHandler start:self];
    
    
}


-(void)viewDidAppear:(BOOL)animated
{
    [Logger setDebugVC:self];
    
    if ([[Logger getPendingConsoleMessages] count] > 0)
    {
        for (NSString *message in [Logger getPendingConsoleMessages])
        {
            [self consoleMessage:message];
        }
    }
    if ([[Logger getPendingErrorMessages] count] > 0)
    {
        for (NSString *message in [Logger getPendingErrorMessages])
        {
            [self errorMessage:message];
        }
    }
    
    [Logger clearPendingConsoleMessages];
    [Logger clearPendingErrorMessages];
        
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)bluetoothRxClicked:(id)sender {
    
    [CommController startBluetoothRx];
    
}


- (IBAction)bluetoothTxClicked:(id)sender {
    
    [CommController startBluetoothTx];
}

- (IBAction)videoSourceValueChanged:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *) sender;
    
    if ([segmentedControl selectedSegmentIndex] == UISegmentedControlSegmentLeft) {
        NSLog(@"Video Source: Z3");
    } else {
        NSLog(@"Video Source: Test Stream");
    }
}

-(void)consoleMessage:(NSString*)messageText
{
    /*
    NSString *currentText = self.consoleTextView.text;
    
    NSString *updatedText;
    
    if (currentText)
    {
        updatedText = [NSString stringWithFormat:@"%@\n%@",currentText,messageText];
    }
    else
    {
        updatedText = messageText;
    }
    
    self.consoleTextView.text = updatedText;
     */
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
    //[self.consoleTextView.textStorage.mutableString appendString:string];
    
    
    
    
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




