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
    
    
}


-(void)viewDidAppear:(BOOL)animated
{
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


-(void)consoleMessage:(NSString*)message
{
    if (self.consoleTextView)
    {
        NSLog(@"Console message: %@",message);
        NSString *currentText = self.consoleTextView.text;
        NSString *messageText = [self createLogString:message];
        
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
    }
    else
    {
        [Logger addPendingConsoleMessage:message];
    }
    
}

-(void)errorMessage:(NSString*)message
{
    if (self.consoleTextView)
    {
        NSLog(@"Console message: %@",message);
        NSString *currentText = self.errorsTextView.text;
        NSString *messageText = [self createLogString:message];
        
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
    else
    {
        [Logger addPendingErrorMessage:message];
    }
}

-(NSString*)createLogString:(NSString*)message
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    NSLog(@"%@",dateString);
    
    NSString *logString = [NSString stringWithFormat:@"%@: %@",dateString,message];
    
    return logString;
}

- (void)viewDidUnload {
    [self setConsoleTextView:nil];
    [self setErrorsTextView:nil];
    [super viewDidUnload];
}


@end




