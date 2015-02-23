//
//  DefaultSettingsTableViewController.m
//  iGCS
//
//  Created by David Leskowicz on 2/9/15.
//
//

#import "DefaultSettingsTableViewController.h"
#import "SettingsSegementedControlCell.h"
#import "RadioSettingsViewController.h"
#import "AboutViewController.h"
#import "SettingsWaypointCell.h"
#import "GCSDataManager.h"


@interface DefaultSettingsTableViewController ()
@property (nonatomic, retain) NSArray *generalSettingsArray;
@property (nonatomic, retain) NSArray *waypointSettingsArray;
@property (nonatomic, retain) NSArray *otherSettingsArray;

@property (nonatomic, retain) NSMutableArray *sectionKeysArray;
@property (nonatomic, retain) NSMutableDictionary *sectionContentsDict;

@property (strong, nonatomic) UIBarButtonItem *editBarButtonItem;
@property (strong, nonatomic) UIBarButtonItem *doneBarButtonItem;

@property (nonatomic, assign) BOOL standardSelected;
@end

@implementation DefaultSettingsTableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    [self configureNavigationBar];
    [self createSectionData];
}

- (void) createSectionData {
    
    //general settings
    self.generalSettingsArray = @[@"Contact Us", @"Order iDroneLink"];
    
    //waypoint settings
    //Remove For this Release
    //self.waypointSettingsArray = @[@"Altitude", @"Radius"];
    
    //other settings
    self.otherSettingsArray = @[@"Radio",@"About"];
    
    NSMutableArray *keys = [[NSMutableArray alloc] init];
    NSMutableDictionary *contents = [[NSMutableDictionary alloc] init];
    
    NSString *generalSectionKey = @"General";
    //Remove for this Release
    //NSString *waypointSectionKey = @"Waypoints";
    NSString *otherSectionKey = @"Other";
    contents[generalSectionKey] = self.generalSettingsArray;
    //Remove for this Release
    //contents[waypointSectionKey] = self.waypointSettingsArray;
    contents[otherSectionKey] = self.otherSettingsArray;

    
    [keys addObject:generalSectionKey];
    //Remove for this Release
    //[keys addObject:waypointSectionKey];
    [keys addObject:otherSectionKey];
    
    [self setSectionKeysArray:keys];
    [self setSectionContentsDict:contents];
}

-(void)configureNavigationBar {
    [self setTitle:@"Settings"];
    
    self.doneBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                             target:self action:@selector(doneWithChanges:)];
    
    self.navigationItem.rightBarButtonItem = self.doneBarButtonItem;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self sectionKeysArray] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *key = [self.sectionKeysArray objectAtIndex:section];
    return [self.sectionContentsDict[key] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"Cell";
    NSString *key = [self.sectionKeysArray objectAtIndex:indexPath.section];
    NSArray *contents = [self.sectionContentsDict objectForKey:key];
    NSString *cellContent = [contents objectAtIndex:indexPath.row];
    
    UITableViewCell *cell;
      
    if ([key isEqual:@"Waypoints"]) {
        SettingsWaypointCell *settingsWaypointCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (settingsWaypointCell == nil) {
            settingsWaypointCell = [[SettingsWaypointCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }

        settingsWaypointCell.textLabel.text = cellContent;
        
        if ([GCSDataManager sharedInstance].gcsSettings.unitType == metric) {
            settingsWaypointCell.customLabel.text = @"meters";
        } else {
            settingsWaypointCell.customLabel.text = @"feet";
        }

        if ([cellContent isEqual:@"Altitude"]) {
            settingsWaypointCell.customTextField.text = [NSString stringWithFormat:@"%.2f",[GCSDataManager sharedInstance].gcsSettings.altitude];
            settingsWaypointCell.customTextField.tag = 0;

        } else if ([cellContent isEqual:@"Ceiling"]) {
            settingsWaypointCell.customTextField.text = [NSString stringWithFormat:@"%.2f",[GCSDataManager sharedInstance].gcsSettings.ceiling];
            settingsWaypointCell.customTextField.tag = 2;

        } else if ([cellContent isEqual:@"Radius"]) {
            settingsWaypointCell.customTextField.text = [NSString stringWithFormat:@"%.2f",[GCSDataManager sharedInstance].gcsSettings.radius];
            settingsWaypointCell.customTextField.tag = 1;
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [settingsWaypointCell.customTextField addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventEditingDidEnd];
        cell = settingsWaypointCell;

    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            
            cell.textLabel.text = cellContent;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            if ([cellContent isEqual:@"Units"]) {
                SettingsSegementedControlCell *settingsSegementedControlCell = [[SettingsSegementedControlCell alloc] initWithFrame:CGRectZero];
                settingsSegementedControlCell.tableView = tableView;
                cell.accessoryView = settingsSegementedControlCell;
                
            } else {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            }
        }
    }
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.sectionKeysArray objectAtIndex:section];
}


#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *key = [self.sectionKeysArray objectAtIndex:indexPath.section];
    NSArray *contents = [self.sectionContentsDict objectForKey:key];
    NSString *cellContent = [contents objectAtIndex:indexPath.row];
    
    if ([cellContent isEqual: @"Contact Us"]) {
        NSURL *contactInfo = [NSURL URLWithString:[NSString stringWithFormat:@"mailto:contact@fightingwalrus.com?subject=iDroneCtrl%%20%@", [self getVersionInfo]]];
        [[UIApplication sharedApplication] openURL:contactInfo];
    }
    
    if ([cellContent isEqual: @"Order iDroneLink"]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.fightingwalrus.com/products/idronelink"]];
    }
    
    if ([cellContent isEqual: @"About"]) {
        AboutViewController *aboutViewController = [[AboutViewController alloc] init];
        [self.navigationController pushViewController:aboutViewController animated:YES];
    }

    if ([cellContent isEqual: @"Radio"]) {
        RadioSettingsViewController *radioSettingsViewController = [[RadioSettingsViewController alloc] init];
        [self.navigationController pushViewController:radioSettingsViewController animated:YES];
    }
}


#pragma mark - UINavigationBar Button handlers

- (void)doneWithChanges:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) textFieldChanged:(UITextField *)textField {
    NSIndexPath *indexPath;
    SettingsWaypointCell *cell;
    
    if (textField.tag == 0) {
        indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
        cell = (SettingsWaypointCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        [GCSDataManager sharedInstance].gcsSettings.altitude = [cell.customTextField.text doubleValue];
    }
    
    if (textField.tag == 1) {
        indexPath = [NSIndexPath indexPathForRow:1 inSection:1];
        cell = (SettingsWaypointCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        [GCSDataManager sharedInstance].gcsSettings.radius = [cell.customTextField.text doubleValue];
    }
    [GCSDataManager save];
}

- (NSString *) getVersionInfo {
    return[[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
}

@end



