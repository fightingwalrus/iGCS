//
//  MissionItemTableViewController.m
//  iGCS
//
//  Created by Claudio Natoli on 4/05/13.
//
//

#import "MissionItemTableViewController.h"
#import "MissionItemEditViewController.h"

#import "WaypointHelper.h"

@interface HeaderSpec : NSObject
@property (nonatomic, assign) NSInteger *width;
@property (nonatomic, assign) UITextAlignment *align;
@property (nonatomic, retain) NSString *text;
@end


@implementation HeaderSpec

@synthesize width;
@synthesize align;
@synthesize text;

- (id) initWithWidth:(NSInteger)_width alignment:(UITextAlignment)_align text:(NSString*)_text {
    self = [super init];
    if (self) {
        self.text =  _text;
        self.width = _width;
        self.align = _align;
    }
    return self;
}

@end



@interface MissionItemTableViewController ()

@end

@implementation MissionItemTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [[[self getWaypointsVC] editDoneButton] setEnabled:YES]; // FIXME: ugh... nasty!
    [[self getWaypointsVC] maybeUpdateCurrentWaypoint:-1];
}

- (void)viewWillDisappear:(BOOL)animated {
    // Prevent the edit/done button being touched while editing a mission item
    [[[self getWaypointsVC] editDoneButton] setEnabled:NO]; // FIXME: more of the same
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    [self.tableView setAllowsSelection: false];
    [self.tableView setAllowsSelectionDuringEditing: true];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (WaypointsViewController*) getWaypointsVC {
    return (WaypointsViewController*)self.parentViewController.parentViewController;
}

- (WaypointsHolder*) getWaypointsHolder {
    return [[self getWaypointsVC] getWaypointsHolder];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) return [[self getWaypointsHolder] numWaypoints];
    return 0;
}


#define TABLE_HEADER_FONT_SIZE 14

#define TABLE_CELL_CMD_FONT_SIZE 16
#define TABLE_CELL_FONT_SIZE   12

#define DEBUG_SHOW_SEQ 0

NSArray* headerSpecs = nil;

+ (void) initialize {
    if (!headerSpecs) { 
        headerSpecs = @[ [[HeaderSpec alloc] initWithWidth:60  alignment:UITextAlignmentLeft   text:@" Seq #"], // row #
#if DEBUG_SHOW_SEQ
                         [[HeaderSpec alloc] initWithWidth:50  alignment:UITextAlignmentRight  text:@"Debug #"], // the real seq #
#endif
                         [[HeaderSpec alloc] initWithWidth:170 alignment:UITextAlignmentLeft   text:@"Command"], // command
                         //
                         [[HeaderSpec alloc] initWithWidth: 90 alignment:UITextAlignmentCenter text:@"Latitude"],  // x
                         [[HeaderSpec alloc] initWithWidth: 90 alignment:UITextAlignmentCenter text:@"Longitude"], // y
                         [[HeaderSpec alloc] initWithWidth: 65 alignment:UITextAlignmentCenter text:@"Altitude"],  // z
                         //
                         [[HeaderSpec alloc] initWithWidth: 85 alignment:UITextAlignmentRight  text:@"Param1"], // param1
                         [[HeaderSpec alloc] initWithWidth: 85 alignment:UITextAlignmentRight  text:@"Param2"], // param2
                         [[HeaderSpec alloc] initWithWidth: 85 alignment:UITextAlignmentRight  text:@"Param3"], // param3
                         [[HeaderSpec alloc] initWithWidth: 85 alignment:UITextAlignmentRight  text:@"Param4"], // param4
                         //
                         [[HeaderSpec alloc] initWithWidth:110 alignment:UITextAlignmentCenter text:@"Autocontinue"] 
                       ];
    }
}

// FIXME: move to utility file
- (NSString*) coordinateToNiceLatLong:(float)val isLat:(bool)isLat {
    char letter = (val > 0) ? 'E' : 'W';
    if (isLat) {
        letter = (val > 0) ? 'N' : 'S';
    }
    
    val = fabs(val);
    
    int deg = (int)val;
    val = (val - deg) * 60;
    
    int min = (int)val;
    float sec = (val - min) * 60;
    
    return [NSString stringWithFormat:@"%02d° %02d' %02.2f%c", deg, min, sec, letter];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MissionItemCellID";
    int TAG_INDEX = 100;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    // FIXME: outside the above "if (cell == nil)..." because it seems cells are already pre-created. Why? Precreated in nib?
    if ([cell viewWithTag:TAG_INDEX] == NULL) {
        unsigned int x = 0;
        for (unsigned int i = 0; i < [headerSpecs count]; i++) {
            int width = [((HeaderSpec*)[headerSpecs objectAtIndex:i]) width];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x, 0, width, tableView.rowHeight)];
            label.tag = TAG_INDEX+i;
            label.font = [UIFont systemFontOfSize:TABLE_CELL_FONT_SIZE];
            label.textAlignment = UITextAlignmentRight;
            label.textColor = [UIColor blackColor];
            label.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
            [cell.contentView addSubview:label];
            //
            x += width;
        }
    }
    
    mavlink_mission_item_t waypoint = [[self getWaypointsHolder] getWaypoint: indexPath.row];
    BOOL isNavCommand = [WaypointHelper isNavCommand:waypoint];
    
    // Row number (which masquerades as the seq #)
    UILabel *label = (UILabel*)[cell viewWithTag:TAG_INDEX++];
    label.text = [NSString stringWithFormat:@"   %d: ", indexPath.row];
    label.textAlignment = UITextAlignmentLeft;

#if DEBUG_SHOW_SEQ
    // Seq number
    label = (UILabel*)[cell viewWithTag:TAG_INDEX++];
    label.text = [NSString stringWithFormat:@"  %d:", waypoint.seq];
    label.textAlignment = UITextAlignmentLeft;
#endif
    
    // Command
    label = (UILabel*)[cell viewWithTag:TAG_INDEX++];
    label.font = [UIFont systemFontOfSize:TABLE_CELL_CMD_FONT_SIZE];
    label.text = [NSString stringWithFormat:@"%@", [WaypointHelper commandIDToString: waypoint.command]];
    label.textAlignment = UITextAlignmentLeft;

    // X (Latitude)
    label = (UILabel*)[cell.contentView viewWithTag:TAG_INDEX++];
    label.text = isNavCommand ? [self coordinateToNiceLatLong: waypoint.x isLat:YES] : @"-";
    
    // Y (Longitude)
    label = (UILabel*)[cell.contentView viewWithTag:TAG_INDEX++];
    label.text = isNavCommand ? [self coordinateToNiceLatLong: waypoint.y isLat:NO] : @"-";

    // Z (Altitude)
    label = (UILabel*)[cell.contentView viewWithTag:TAG_INDEX++];
    label.text = isNavCommand ? [NSString stringWithFormat:@"%0.3f", waypoint.z] : @"-";
    
    // param1
    label = (UILabel*)[cell.contentView viewWithTag:TAG_INDEX++];
    label.text = (waypoint.param1 == 0) ? @"0" : [NSString stringWithFormat:@"%0.3f", waypoint.param1];
    
    // param2
    label = (UILabel*)[cell.contentView viewWithTag:TAG_INDEX++];
    label.text = (waypoint.param2 == 0) ? @"0" : [NSString stringWithFormat:@"%0.3f", waypoint.param2];
    
    // param3
    label = (UILabel*)[cell.contentView viewWithTag:TAG_INDEX++];
    label.text = (waypoint.param3 == 0) ? @"0" : [NSString stringWithFormat:@"%0.3f", waypoint.param3];
    
    // param4
    label = (UILabel*)[cell.contentView viewWithTag:TAG_INDEX++];
    label.text = (waypoint.param4 == 0) ? @"0" : [NSString stringWithFormat:@"%0.3f", waypoint.param4];
    
    // autocontinue
    label = (UILabel*)[cell.contentView viewWithTag:TAG_INDEX++];
    label.text = [NSString stringWithFormat:@"%@", waypoint.autocontinue ? @"Yes" : @"No"];
    label.textAlignment = UITextAlignmentCenter;

    return cell;
}

// Support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        assert (indexPath.section == 0);
        
        // Delete the row from the data source
        [[self getWaypointsHolder] removeWaypoint:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    
    // Reset the map and table views
    [[self getWaypointsVC] resetWaypoints];
}


// Support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    assert (fromIndexPath.section == 0 && toIndexPath.section == 0);
    [[self getWaypointsHolder] swapWaypoints:fromIndexPath.row :toIndexPath.row];
    
    // Reset the map and table views
    [[self getWaypointsVC] resetWaypoints];
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
    for (HeaderSpec *spec in headerSpecs) {
        int width = [spec width];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x, 0, width, 40)];
        label.text = [spec text];
        label.font = [UIFont boldSystemFontOfSize:TABLE_HEADER_FONT_SIZE];
        label.textAlignment = [spec align];
        label.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.shadowColor = [UIColor darkGrayColor];
        label.shadowOffset = CGSizeMake(0,1);
        [sectionHead addSubview:label];
        //
        x += width;
    }
    
    return sectionHead;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.isEditing) {
        int idx = indexPath.row;
        [[self getWaypointsVC] maybeUpdateCurrentWaypoint:[[self getWaypointsHolder] getWaypoint:idx].seq]; // mark the selected waypoint
        [self performSegueWithIdentifier:@"editItemVC_segue"
                                  sender:[NSNumber numberWithInteger:idx]];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString * segueName = segue.identifier;
    NSLog(@"prepareForSeque %@", segueName);
    
    if ([segueName isEqualToString: @"editItemVC_segue"]) {
        NSNumber *rowNum = (NSNumber*)sender;
        unsigned int row = [rowNum unsignedIntValue];
        [((MissionItemEditViewController*)[segue destinationViewController]) initInstance:row with:[self getWaypointsVC]];
    }
}

@end
