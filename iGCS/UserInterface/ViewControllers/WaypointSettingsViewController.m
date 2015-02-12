//
//  WaypointSettingsViewController.m
//  iGCS
//
//  Created by David Leskowicz on 2/11/15.
//
//

#import "WaypointSettingsViewController.h"
#import "PureLayout.h"
#import "GCSThemeManager.h"

@interface WaypointSettingsViewController ()

@property (strong, nonatomic) UIBarButtonItem *editBarButtonItem;
@property (strong, nonatomic) UIBarButtonItem *cancelBarButtonItem;
@property (strong, nonatomic) UIBarButtonItem *saveBarButtonItem;


// UI elements

@property (strong, nonatomic) UILabel *altitude;

@end

@implementation WaypointSettingsViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configureNavigationBar];
    [self configureViewLayout];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)configureNavigationBar {
    [self setTitle:@"Waypoint Settings"];
    
    self.cancelBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                             target:self action:@selector(cancelChanges:)];
    // save button disabled on load
    self.saveBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                           target:self action:@selector(saveSettings:)];
    self.saveBarButtonItem.enabled = NO;
    
    self.navigationItem.leftBarButtonItem = self.cancelBarButtonItem;
    self.navigationItem.rightBarButtonItem = self.saveBarButtonItem;
}


-(void)configureViewLayout {
    self.view.backgroundColor = [GCSThemeManager sharedInstance].appSheetBackgroundColor;
    self.altitude.text = nil;
    
    // Test UI
    self.altitude = [UILabel newAutoLayoutView];
    [self.view addSubview:self.altitude];
    [self.altitude setText:@"Altitude:"];
    self.altitude.textAlignment = NSTextAlignmentRight;
    [self.altitude autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.view withOffset:160];
    
    
}



#pragma mark - UINavigationBar Button handlers

- (void)cancelChanges:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveSettings:(id)sender {
    DDLogDebug(@"Save Default Settings");
    
}



@end
