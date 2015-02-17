//
//  DefaultSettingsTableViewController.m
//  iGCS
//
//  Created by David Leskowicz on 2/9/15.
//
//

#import "DefaultSettingsTableViewController.h"
#import "WaypointSettingsViewController.h"
#import "SettingsSegementedControlCell.h"
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
    self.generalSettingsArray = @[@"Units"];
    
    //waypoint settings
    self.waypointSettingsArray = @[@"Altitude", @"Radius"];
    
    //other settings
    self.otherSettingsArray = @[@"Radio",@"About"];
    
    NSMutableArray *keys = [[NSMutableArray alloc] init];
    NSMutableDictionary *contents = [[NSMutableDictionary alloc] init];
    
    NSString *generalSectionKey = @"General";
    NSString *waypointSectionKey = @"Waypoints";
    NSString *otherSectionKey = @"Other";
    
    [contents setObject:self.generalSettingsArray forKey:generalSectionKey];
    [contents setObject:self.waypointSettingsArray forKey:waypointSectionKey];
    [contents setObject:self.otherSettingsArray forKey:otherSectionKey];
    
    [keys addObject:generalSectionKey];
    [keys addObject:waypointSectionKey];
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
    NSArray *contents = [self.sectionContentsDict objectForKey:key];
    NSInteger rows = contents.count;
    return rows;
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
        }
        else {
            settingsWaypointCell.customLabel.text = @"feet";
        }
        
        if ([cellContent isEqual: @"Altitude"]) {
            settingsWaypointCell.customTextField.text = [NSString stringWithFormat:@"%lu",(unsigned long)[GCSDataManager sharedInstance].gcsSettings.altitude];
        }
        else if ([cellContent isEqual: @"Ceiling"]) {
            settingsWaypointCell.customTextField.text = [NSString stringWithFormat:@"%lu",(unsigned long)[GCSDataManager sharedInstance].gcsSettings.ceiling];
        }
        
        else if ([cellContent isEqual: @"Radius"]) {
            settingsWaypointCell.customTextField.text = [NSString stringWithFormat:@"%lu",(unsigned long)[GCSDataManager sharedInstance].gcsSettings.radius];
        }
        cell = settingsWaypointCell;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            
            cell.textLabel.text = cellContent;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            if ([cellContent isEqual: @"Units"]) {
                SettingsSegementedControlCell *settingsSegementedControlCell = [[SettingsSegementedControlCell alloc] initWithFrame:CGRectZero];
                settingsSegementedControlCell.tableView = tableView;
                cell.accessoryView = settingsSegementedControlCell;
                
            }
            else {
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

/*
    if ([cellContent isEqual: @"Waypoints"]) {
        WaypointSettingsViewController *wayPointSettingsViewController = [[WaypointSettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
        [self.navigationController pushViewController:wayPointSettingsViewController animated:YES];
    }
*/
    
}


/* Probably eventually need to implement this to customize our header
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UILabel *myLabel = [[UILabel alloc] init];
    myLabel.frame = CGRectMake(20, 8, 320, 20);
    myLabel.font = [UIFont boldSystemFontOfSize:18];
    myLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    
    UIView *headerView = [[UIView alloc] init];
    [headerView addSubview:myLabel];
    
    return headerView;
}
*/


#pragma mark - UINavigationBar Button handlers

- (void)doneWithChanges:(id)sender {
    
    NSIndexPath *indexPath;
    SettingsWaypointCell *cell;
    
    indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    cell = (SettingsWaypointCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    [GCSDataManager sharedInstance].gcsSettings.altitude = [cell.customTextField.text integerValue];
   
    indexPath = [NSIndexPath indexPathForRow:1 inSection:1];
    cell = (SettingsWaypointCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    [GCSDataManager sharedInstance].gcsSettings.radius = [cell.customTextField.text integerValue];
    [GCSDataManager save];

    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end



