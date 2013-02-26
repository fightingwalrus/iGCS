//
//  DebugViewController.h
//  iGCS
//
//  Created by Andrew Aarestad on 2/25/13.
//
//

#import <UIKit/UIKit.h>

@interface DebugViewController : UIViewController


@property (strong, nonatomic) IBOutlet UITextView *consoleTextView;
@property (strong, nonatomic) IBOutlet UITextView *errorsTextView;

@property (strong) NSMutableArray *pendingConsoleMessages;
@property (strong) NSMutableArray *pendingErrorMessages;



- (IBAction)bluetoothRxClicked:(id)sender;
- (IBAction)bluetoothTxClicked:(id)sender;

-(void)consoleMessage:(NSString*)message;
-(void)errorMessage:(NSString*)message;

@end
