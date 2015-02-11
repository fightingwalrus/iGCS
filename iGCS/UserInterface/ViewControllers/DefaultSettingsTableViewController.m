//
//  DefaultSettingsTableViewController.m
//  iGCS
//
//  Created by David Leskowicz on 2/9/15.
//
//

#import "DefaultSettingsTableViewController.h"



@interface DefaultSettingsTableViewController ()
@property (nonatomic, retain) NSArray *generalSettingsArray;
@property (nonatomic, retain) NSArray *otherSettingsArray;
@property (nonatomic, retain) NSArray *sectionHeadersArray;

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
    
    self.sectionHeadersArray = @[@"General", @"Other"];
    
    //general settings
    self.generalSettingsArray = @[@"Waypoint Altitude", @"Waypoint Radius", @"Altitude Ceiling", @"Units"];
    
    //other settings
    self.otherSettingsArray = @[@"About", @"Other1", @"Other2"];    
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section ==0) {
        return self.generalSettingsArray.count;
    }
    else {
        return self.otherSettingsArray.count;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

 static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if (indexPath.section == 0) {
       cell.textLabel.text = [self.generalSettingsArray objectAtIndex:indexPath.row];
    }
    else {
        cell.textLabel.text = [self.otherSettingsArray objectAtIndex:indexPath.row];
    }
    
    
    return cell;

}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0)
        return self.sectionHeadersArray[0];
    if (section == 1)
        return self.sectionHeadersArray[1];
    
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
/*
 
    NSInteger idx = indexPath.row;
    
    if (tableView.isEditing) {
        if (idx == 0) return; // Prevent editing of the HOME/0 waypoint
        mavlink_mission_item_t waypoint = [[self waypointsHolder] getWaypoint:idx];
        if ([MavLinkUtility isSupportedMissionItemType:waypoint.command]) {
            [self unmarkSelectedRow];
            [[self waypointsVC] maybeUpdateCurrentWaypoint:waypoint.seq]; // mark the selected waypoint
            [self performSegueWithIdentifier:@"editItemVC_segue" sender:@(idx)];
        }
    } else {
        [self modifyHeadersForSelectedRow:idx];
        if ([self.lastIndexPath isEqual:indexPath]) {
            [self unmarkSelectedRow];
        } else {
            self.lastIndexPath = indexPath;
            [[self waypointsVC] maybeUpdateCurrentWaypoint:[[self waypointsHolder] getWaypoint:idx].seq]; // mark the selected waypoint
        }
    }
 */
}


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



