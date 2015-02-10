//
//  DefaultSettingsTableViewController.m
//  iGCS
//
//  Created by David Leskowicz on 2/9/15.
//
//

#import "DefaultSettingsTableViewController.h"



@interface DefaultSettingsTableViewController ()
@property (nonatomic, retain) NSArray *settingsArray;
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
    
    self.title = @"User Settings";
    self.settingsArray = [NSArray arrayWithObjects:@"About", @"Altitude", @"Units", nil];

   
    
}

-(void)configureNavigationBar {
    [self setTitle:@"Default Settings"];
    
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.settingsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

 static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = [self.settingsArray objectAtIndex:indexPath.row];
    
    return cell;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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







@end



