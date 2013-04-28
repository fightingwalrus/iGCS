//
//  WaypointsViewController.m
//  iGCS
//
//  Created by Claudio Natoli on 18/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WaypointsViewController.h"
#import "WaypointHelper.h"

@interface WaypointsViewController ()

@end

@implementation WaypointsViewController

@synthesize tableView;

@synthesize editDoneButton;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
    
    // Release any cached data, images, etc that aren't in use.
#if DO_NSLOG
    if ([self isViewLoaded]) {
        NSLog(@"\t\tWaypointsViewController::didReceiveMemoryWarning: view is still loaded");
    } else {
        NSLog(@"\t\tWaypointsViewController::didReceiveMemoryWarning: view is NOT loaded");
    }
#endif
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Custom initialization
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    [tableView setAllowsSelectionDuringEditing: true];
    
    waypoints = [[WaypointsHolder alloc] initWithExpectedCount:0];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) return [waypoints numWaypoints];
    return 0;
}

#define TABLE_HEADER_FONT_SIZE 14

#define TABLE_CELL_CMD_FONT_SIZE 16
#define TABLE_CELL_FONT_SIZE   12

static unsigned int CELL_WIDTHS[] = {
    60,               // row #
    60,               // seq #
    170,              // command
    80, 80, 90,       // x, y, z
    80, 80, 80, 90,  // param1-4
    85               // autocontinue
};

static NSString* CELL_HEADERS[] = {
    @" Row #", // FIXME: temporary?
    @" Seq #",
    @"Command",
    @"X", @"Y", @"Z",
    @"Param1", @"Param2", @"Param3", @"Param4",
    @"Autocontinue"
};

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"WaypointCellID";    
    int TAG_INDEX = 100;

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    // FIXME: outside the above "if (cell == nil)..." because it seems cells are already pre-created. Why? Precreated in nib?
    if ([cell viewWithTag:TAG_INDEX] == NULL) {        
        unsigned int x = 0;
        for (unsigned int i = 0; i < sizeof(CELL_WIDTHS)/sizeof(unsigned int); i++) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x, 0, CELL_WIDTHS[i], tableView.rowHeight)];
            x += CELL_WIDTHS[i];
            label.tag = TAG_INDEX+i;
            //
            label.font = [UIFont systemFontOfSize:TABLE_CELL_FONT_SIZE];
            label.textAlignment = UITextAlignmentLeft;
            label.textColor = [UIColor blackColor];
            label.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
            //
            [cell.contentView addSubview:label];
        }
    }
    
    mavlink_mission_item_t waypoint = [waypoints getWaypoint: indexPath.row];
    
    // Row number
    UILabel *label = (UILabel*)[cell viewWithTag:TAG_INDEX++];
    label.text = [NSString stringWithFormat:@"  %d:", indexPath.row];

    // Seq number
    label = (UILabel*)[cell viewWithTag:TAG_INDEX++];
    label.text = [NSString stringWithFormat:@"  %d:", waypoint.seq];

    // Command
    label = (UILabel*)[cell viewWithTag:TAG_INDEX++];
    label.font = [UIFont systemFontOfSize:TABLE_CELL_CMD_FONT_SIZE];
    label.text = [NSString stringWithFormat:@"%@", [WaypointHelper commandIDToString: waypoint.command]];
    
    // X
    label = (UILabel*)[cell.contentView viewWithTag:TAG_INDEX++];
    label.text = [NSString stringWithFormat:@"%f", waypoint.x];
    
    // Y
    label = (UILabel*)[cell.contentView viewWithTag:TAG_INDEX++];
    label.text = [NSString stringWithFormat:@"%f", waypoint.y];
    
    // Z
    label = (UILabel*)[cell.contentView viewWithTag:TAG_INDEX++];
    label.text = [NSString stringWithFormat:@"%f", waypoint.z];

    // param1
    label = (UILabel*)[cell.contentView viewWithTag:TAG_INDEX++];
    label.text = (waypoint.param1 == 0) ? @"0" : [NSString stringWithFormat:@"%f", waypoint.param1];
    
    // param2
    label = (UILabel*)[cell.contentView viewWithTag:TAG_INDEX++];
    label.text = (waypoint.param2 == 0) ? @"0" : [NSString stringWithFormat:@"%f", waypoint.param2];
    
    // param3
    label = (UILabel*)[cell.contentView viewWithTag:TAG_INDEX++];
    label.text = (waypoint.param3 == 0) ? @"0" : [NSString stringWithFormat:@"%f", waypoint.param3];
    
    // param4
    label = (UILabel*)[cell.contentView viewWithTag:TAG_INDEX++];
    label.text = (waypoint.param4 == 0) ? @"0" : [NSString stringWithFormat:@"%f", waypoint.param4];

    // autocontinue
    label = (UILabel*)[cell.contentView viewWithTag:TAG_INDEX++];
    label.text = [NSString stringWithFormat:@"%@", waypoint.autocontinue ? @"Yes" : @"No"];
    
/*
    // current
    label = (UILabel*)[cell.contentView viewWithTag:TAG_INDEX++];
    label.text = [NSString stringWithFormat:@"%d", waypoint.current];
*/
    return cell;
}

// Support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Support editing the table view.
- (void)tableView:(UITableView *)_tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        assert (indexPath.section == 0);
        
        // Delete the row from the data source
        [waypoints removeWaypoint:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    
    // Reset the map and table views
    [super resetWaypoints:waypoints];
    [tableView reloadData];
}

// Support rearranging the table view.
- (void)tableView:(UITableView *)_tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    assert (fromIndexPath.section == 0 && toIndexPath.section == 0);
    [waypoints swapWaypoints:fromIndexPath.row :toIndexPath.row];

    // Reset the map and table views
    [super resetWaypoints:waypoints];
    [tableView reloadData];
}

// Support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    // create the parent view that will hold header Label
    UIView* sectionHead = [[UIView alloc] initWithFrame:CGRectMake(0,0,1024,40)];
    sectionHead.tag = section;
    sectionHead.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
    sectionHead.userInteractionEnabled = YES;    
    
    unsigned int x = 0;
    for (unsigned int i = 0; i < sizeof(CELL_WIDTHS)/sizeof(unsigned int); i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x, 0, CELL_WIDTHS[i], 40)];
        x += CELL_WIDTHS[i];
        //
        label.text = CELL_HEADERS[i];
        //
        label.font = [UIFont boldSystemFontOfSize:TABLE_HEADER_FONT_SIZE];
        label.textAlignment = UITextAlignmentLeft;
        label.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
        //
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.shadowColor = [UIColor darkGrayColor];
        label.shadowOffset = CGSizeMake(0,1);
        //
        [sectionHead addSubview:label];
    }
    
    return sectionHead;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (void) resetWaypoints:(WaypointsHolder*)_waypoints {
    [super resetWaypoints:_waypoints];
    
    waypoints = _waypoints;
    [[self tableView] reloadData];
}

- (void) handlePacket:(mavlink_message_t*)msg {
}

- (void) waypointWithSeq:(int)waypointSeq wasMovedToLat:(double)latitude andLong:(double)longitude {
    int index = [waypoints getIndexOfWaypointWithSeq:waypointSeq];
    if (index != -1) {
        mavlink_mission_item_t waypoint = [waypoints getWaypoint:index];
        waypoint.x = latitude;
        waypoint.y = longitude;
        [waypoints replaceWaypoint:index with:waypoint];
        
        // Reset the map and table views
        [super resetWaypoints:waypoints]; // FIXME: this is a little heavy handed. Want more fine-grained
                                          // control here (like not resetting the map bounds in this case)
        [tableView reloadData];
    }
}

- (IBAction)editDoneClicked:(id)sender {
    bool isEditing = !tableView.editing;
    
    // Update the table and edit button styles
    [tableView setEditing:isEditing animated:true];
    editDoneButton.title = isEditing ? @"Done" : @"Edit";
    editDoneButton.style = isEditing ? UIBarButtonItemStyleDone : UIBarButtonItemStylePlain;

    int delta = isEditing ? TABLE_MAP_SLIDE_AMOUNT : -TABLE_MAP_SLIDE_AMOUNT;

    // Slide/grow/shrink the map and table views
    CGRect tableRect = tableView.frame;
    CGRect mapRect   = map.frame;

    tableRect.origin.y += delta;
    tableRect.size.height -= delta;
    mapRect.size.height += delta;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.75];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    tableView.frame = tableRect;
    map.frame = mapRect;
    [UIView commitAnimations];
    
    // Update the map view with non/editable waypoints
    [self makeWaypointsDraggable:isEditing];
}


@end
