//
//  DebugViewController.h
//  iGCS
//
//  Created by Andrew Aarestad on 2/25/13.
//
//

#import <UIKit/UIKit.h>
#import <sys/socket.h>
#import "BRRequest.h"
#import "GCDAsyncSocket.h"
#import "GCDAsyncUdpSocket.h"
#import "ArDroneUtils.h"

@interface DebugViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextView *consoleTextView;

- (IBAction)arDroneCtrl:(id)sender;



-(void)consoleMessage:(NSString*)messageText;


@end
