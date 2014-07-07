//
//  SettingsViewController.h
//  iGCS
//
//  Created by Andrew Brown on 3/18/14.
//
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController <UIAlertViewDelegate>
@property (strong, nonatomic) IBOutlet UILabel *localRadioFirmwareVersion;
@property (strong, nonatomic) IBOutlet UILabel *remoteRadioFirmwareVersion;
@property (strong, nonatomic) IBOutlet UILabel *connectionStatus;


//@property (strong, nonatomic) IBOutlet UITextField *localRadioBaudRate;
//@property (strong, nonatomic) IBOutlet UITextField *localRadioAirBaudRate;
@property (strong, nonatomic) IBOutlet UITextField *localRadioNetId;

//@property (strong, nonatomic) IBOutlet UITextField *localRadioTransmitPower;
//@property (strong, nonatomic) IBOutlet UITextField *localRadioIsMavlinkEnabled;
//@property (strong, nonatomic) IBOutlet UITextField *localRadioMinFrequency;
//@property (strong, nonatomic) IBOutlet UITextField *localRadioMaxFrequency;
//@property (strong, nonatomic) IBOutlet UITextField *localRadioNumberOfChannels;
//@property (strong, nonatomic) IBOutlet UITextField *localRadioDutyCycle;
//@property (strong, nonatomic) IBOutlet UITextField *localRadioLbtRssiEnabled;
//@property (strong, nonatomic) IBOutlet UITextField *localRadioHardwareFlow;
@property (weak, nonatomic) IBOutlet UIButton *editCancelButton;

@end
