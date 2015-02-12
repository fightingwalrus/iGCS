//
//  DefaultSettingsTableViewController.m
//  iGCS
//
//  Created by David Leskowicz on 2/9/15.
//
//

#import "DefaultSettingsTableViewController.h"
#import "WaypointSettingsViewController.h"



@interface DefaultSettingsTableViewController ()
@property (nonatomic, retain) NSArray *generalSettingsArray;
@property (nonatomic, retain) NSArray *otherSettingsArray;

@property (nonatomic, retain) NSMutableArray *sectionKeysArray;
@property (nonatomic, retain) NSMutableDictionary *sectionContentsDict;


@property (strong, nonatomic) UIBarButtonItem *editBarButtonItem;
@property (strong, nonatomic) UIBarButtonItem *cancelBarButtonItem;
@property (strong, nonatomic) UIBarButtonItem *saveBarButtonItem;


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
    self.generalSettingsArray = @[@"Waypoint Settings", @"Altitude Ceiling", @"Units"];
    
    //other settings
    self.otherSettingsArray = @[@"About", @"Other1", @"Other2"];
    
    NSMutableArray *keys = [[NSMutableArray alloc] init];
    NSMutableDictionary *contents = [[NSMutableDictionary alloc] init];
    
    NSString *generalSectionKey = @"General";
    NSString *otherSectionKey = @"Other";
    
    [contents setObject:self.generalSettingsArray forKey:generalSectionKey];
    [contents setObject:self.otherSettingsArray forKey:otherSectionKey];
    
    [keys addObject:generalSectionKey];
    [keys addObject:otherSectionKey];
    
    [self setSectionKeysArray:keys];
    [self setSectionContentsDict:contents];
}

-(void)configureNavigationBar {
    [self setTitle:@"Settings"];
    
    self.cancelBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                             target:self action:@selector(cancelChanges:)];
    // save button disabled on load
    self.saveBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                           target:self action:@selector(saveSettings:)];
    self.saveBarButtonItem.enabled = NO;
    
    self.navigationItem.leftBarButtonItem = self.cancelBarButtonItem;
    self.navigationItem.rightBarButtonItem = self.saveBarButtonItem;
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    NSString *key = [self.sectionKeysArray objectAtIndex:indexPath.section];
    NSArray *contents = [self.sectionContentsDict objectForKey:key];
    NSString *cellContent = [contents objectAtIndex:indexPath.row];
    cell.textLabel.text = cellContent;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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
    
    
    if ([cellContent isEqual: @"Waypoint Settings"]) {
        WaypointSettingsViewController *wayPointSettingsViewController = [WaypointSettingsViewController alloc];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:wayPointSettingsViewController];
        
        navController.navigationBar.barStyle = UIBarStyleDefault;
        navController.modalPresentationStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:navController animated:YES completion:nil];

        
    }
    
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

- (void)cancelChanges:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveSettings:(id)sender {
    DDLogDebug(@"Save Default Settings");
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}







@end



