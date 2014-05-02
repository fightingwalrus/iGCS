//
//  SettingsViewController.m
//  iGCS
//
//  Created by Andrew Brown on 3/18/14.
//
//

#import "SettingsViewController.h"
#import "CommController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)configRadioMode:(id)sender {
    NSLog(@"configRadioMode");
    [[CommController sharedInstance] startFWRConfigMode];
}

-(IBAction)sendATCommand:(id)sender {
    NSLog(@"Send AT Command");


//    [[CommController sharedInstance].radioConfig.sikAt setHayesMode:RT];
    [[CommController sharedInstance].radioConfig radioVersion];
//    [[CommController sharedInstance].radioConfig setNetId:25];
//    [[CommController sharedInstance].radioConfig save];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
