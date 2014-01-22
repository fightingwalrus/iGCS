//
//  MissionItemTableViewController.m
//  iGCS
//
//  Created by Claudio Natoli on 4/05/13.
//
//

#import "MissionItemTableViewController.h"
#import "MissionItemEditViewController.h"

#import "MiscUtilities.h"
#import "MavLinkUtility.h"
#import "WaypointHelper.h"

@interface HeaderSpec : NSObject
@property (nonatomic, assign) NSInteger width;
@property (nonatomic, assign) NSTextAlignment align;
@property (nonatomic, retain) NSString *text;
@property (nonatomic, assign) NSInteger tag;
@end


@implementation HeaderSpec

@synthesize width;
@synthesize align;
@synthesize text;
@synthesize tag;

- (id) initWithWidth:(NSInteger)_width alignment:(UITextAlignment)_align text:(NSString*)_text tag:(NSInteger)_tag {
    self = [super init];
    if (self) {
        self.text =  _text;
        self.width = _width;
        self.align = _align;
        self.tag   = _tag;
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
    [self unmarkSelectedRow];
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

    [self.tableView setAllowsSelection: true];
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

#define HEADER_SPEC_EDIT_OFFSET 40

#define TAG_PARAM1 100
#define TAG_PARAM2 200
#define TAG_PARAM3 300
#define TAG_PARAM4 400

NSArray* headerSpecs = nil;

+ (void) initialize {
    if (!headerSpecs) { 
        headerSpecs = @[ [[HeaderSpec alloc] initWithWidth: 50 alignment:NSTextAlignmentLeft   text:@" Seq #"  tag:0], // row #
#if DEBUG_SHOW_SEQ
                         [[HeaderSpec alloc] initWithWidth: 50 alignment:NSTextAlignmentRight  text:@"Debug #" tag:0], // the real seq #
#endif
                         [[HeaderSpec alloc] initWithWidth:140 alignment:NSTextAlignmentLeft   text:@"Command" tag:0], // command
                         //
                         [[HeaderSpec alloc] initWithWidth: 90 alignment:NSTextAlignmentCenter text:@"Latitude"  tag:0], // x
                         [[HeaderSpec alloc] initWithWidth: 90 alignment:NSTextAlignmentCenter text:@"Longitude" tag:0], // y
                         [[HeaderSpec alloc] initWithWidth: 65 alignment:NSTextAlignmentCenter text:@"Altitude"  tag:0], // z
                         //
                         [[HeaderSpec alloc] initWithWidth: 95 alignment:NSTextAlignmentRight  text:@"Param1" tag:TAG_PARAM1], // param1
                         [[HeaderSpec alloc] initWithWidth: 95 alignment:NSTextAlignmentRight  text:@"Param2" tag:TAG_PARAM2], // param2
                         [[HeaderSpec alloc] initWithWidth: 95 alignment:NSTextAlignmentRight  text:@"Param3" tag:TAG_PARAM3], // param3
                         [[HeaderSpec alloc] initWithWidth: 95 alignment:NSTextAlignmentRight  text:@"Param4" tag:TAG_PARAM4], // param4
                         //
                         [[HeaderSpec alloc] initWithWidth:100 alignment:NSTextAlignmentCenter text:@"Autocontinue" tag:0]
                       ];
    }
}

- (NSString*) formatParam:(float)param {
    return param == 0 ? @"0" : [NSString stringWithFormat:@"%0.2f", param];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MissionItemCellID";
    int TAG_INDEX = 100;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    
    // FIXME: outside the above "if (cell == nil)..." because it seems cells are already pre-created. Why? Precreated in nib?
    if ([cell viewWithTag:TAG_INDEX] == NULL) {
        unsigned int x = 0;
        for (unsigned int i = 0; i < [headerSpecs count]; i++) {
            int width = [((HeaderSpec*)[headerSpecs objectAtIndex:i]) width];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x, 0, width, tableView.rowHeight)];
            label.tag = TAG_INDEX+i;
            label.font = [UIFont systemFontOfSize:TABLE_CELL_FONT_SIZE];
            label.textAlignment = NSTextAlignmentRight;
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
    label.text = [NSString stringWithFormat:@"%4d:", indexPath.row];
    label.textAlignment = NSTextAlignmentLeft;

#if DEBUG_SHOW_SEQ
    // Seq number
    label = (UILabel*)[cell viewWithTag:TAG_INDEX++];
    label.text = [NSString stringWithFormat:@"%d:", waypoint.seq];
    label.textAlignment = NSTextAlignmentLeft;
#endif
    
    // Command
    label = (UILabel*)[cell viewWithTag:TAG_INDEX++];
    label.font = [UIFont systemFontOfSize:TABLE_CELL_CMD_FONT_SIZE];
    label.text = [NSString stringWithFormat:@"%@", [WaypointHelper commandIDToString: waypoint.command]];
    label.textAlignment = NSTextAlignmentLeft;

    // X (Latitude)
    label = (UILabel*)[cell.contentView viewWithTag:TAG_INDEX++];
    label.text = isNavCommand ? [MiscUtilities coordinateToNiceLatLong: waypoint.x isLat:YES] : @"-";
    
    // Y (Longitude)
    label = (UILabel*)[cell.contentView viewWithTag:TAG_INDEX++];
    label.text = isNavCommand ? [MiscUtilities coordinateToNiceLatLong: waypoint.y isLat:NO] : @"-";

    // Z (Altitude)
    label = (UILabel*)[cell.contentView viewWithTag:TAG_INDEX++];
    label.text = isNavCommand ? [NSString stringWithFormat:@"%0.2f m", waypoint.z] : @"-";
    
    // Used to determine whether we have a named header for the respective param
    NSMutableDictionary *dict = [self headerTagToLabelDictWith: waypoint.command];
    
    // param1
    label = (UILabel*)[cell.contentView viewWithTag:TAG_INDEX++];
    label.text = (dict && dict[@(TAG_PARAM1)]) ? [self formatParam:waypoint.param1] : @"-";
    
    // param2
    label = (UILabel*)[cell.contentView viewWithTag:TAG_INDEX++];
    label.text = (dict && dict[@(TAG_PARAM2)]) ? [self formatParam:waypoint.param2] : @"-";
    
    // param3
    label = (UILabel*)[cell.contentView viewWithTag:TAG_INDEX++];
    label.text = (dict && dict[@(TAG_PARAM3)]) ? [self formatParam:waypoint.param3] : @"-";
    
    // param4
    label = (UILabel*)[cell.contentView viewWithTag:TAG_INDEX++];
    label.text = (dict && dict[@(TAG_PARAM4)]) ? [self formatParam:waypoint.param4] : @"-";
    
    // autocontinue
    label = (UILabel*)[cell.contentView viewWithTag:TAG_INDEX++];
    label.text = [NSString stringWithFormat:@"%@", waypoint.autocontinue ? @"Yes" : @"No"];
    label.textAlignment = NSTextAlignmentCenter;

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
    [[self getWaypointsHolder] moveWaypoint:fromIndexPath.row to:toIndexPath.row];
    
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
    // create the view that will hold the header labels
    UIView* headerContainer = [[UIView alloc] initWithFrame:CGRectMake([self isEditing] ? HEADER_SPEC_EDIT_OFFSET : 0, 0,1024,20)];
    unsigned int x = 0;
    for (HeaderSpec *spec in headerSpecs) {
        int width = [spec width];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x, 0, width, 20)];
        label.tag  = spec.tag;
        label.text = [spec text];
        label.font = [UIFont boldSystemFontOfSize:TABLE_HEADER_FONT_SIZE];
        label.textAlignment = [spec align];
        label.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.shadowColor = [UIColor darkGrayColor];
        label.shadowOffset = CGSizeMake(0,1);
        [headerContainer addSubview:label];
        //
        x += width;
    }
    
    // Create a parent section view (which will only hold the headerContainer)
    UIView* sectionHeader = [[UIView alloc] initWithFrame:CGRectMake(0,0,1024,400)];
    [sectionHeader addSubview:headerContainer];
    sectionHeader.backgroundColor = [UIColor colorWithWhite:0.75 alpha:0.75];
    sectionHeader.tag = section;

    _sectionHeaderContainer = headerContainer;
    
    return sectionHeader;
}

- (NSMutableDictionary*) headerTagToLabelDictWith:(uint16_t)command {
    NSArray* fields = [MavLinkUtility missionItemMetadataWith: command];
    if (!fields) return nil;
    
    NSDictionary *fieldTypeToHeaderTag = @{
                                           @(GCSItemParam1) : @(TAG_PARAM1),
                                           @(GCSItemParam2) : @(TAG_PARAM2),
                                           @(GCSItemParam3) : @(TAG_PARAM3),
                                           @(GCSItemParam4) : @(TAG_PARAM4)
                                           };
    
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    for (MissionItemField* field in fields) {
        NSNumber *tag = fieldTypeToHeaderTag[@(field.fieldType)];
        if (tag) {
            dict[tag] = field.label;
        }
    }
    return dict;
}

- (void)modifyHeadersForSelectedRow:(NSInteger)row {
    mavlink_mission_item_t waypoint = [[self getWaypointsHolder] getWaypoint:row];
    NSMutableDictionary *dict = [self headerTagToLabelDictWith:waypoint.command];
    
    // If we recognise this mission item type, then populate the fields (default is ""),
    // otherwise, fallback to "ParamX"
    ((UILabel*)[_sectionHeaderContainer viewWithTag: TAG_PARAM1]).text = dict ? (dict[@(TAG_PARAM1)] ?: @"") : @"Param1";
    ((UILabel*)[_sectionHeaderContainer viewWithTag: TAG_PARAM2]).text = dict ? (dict[@(TAG_PARAM2)] ?: @"") : @"Param2";
    ((UILabel*)[_sectionHeaderContainer viewWithTag: TAG_PARAM3]).text = dict ? (dict[@(TAG_PARAM3)] ?: @"") : @"Param3";
    ((UILabel*)[_sectionHeaderContainer viewWithTag: TAG_PARAM4]).text = dict ? (dict[@(TAG_PARAM4)] ?: @"") : @"Param4";
}

- (void)unmarkSelectedRow {
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:true];
    [[self getWaypointsVC] maybeUpdateCurrentWaypoint:-1];
    self.lastIndexPath = nil;
}

- (void) markSelectedRow:(NSInteger)idx {
    NSIndexPath *path = [NSIndexPath indexPathForRow:idx inSection:0];
    [self.tableView selectRowAtIndexPath:path animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    [[self getWaypointsVC] maybeUpdateCurrentWaypoint:[[self getWaypointsHolder] getWaypoint:idx].seq]; // mark the selected waypoint
}

- (bool) toggleEditing {
    bool isEditing = ![self isEditing];
    
    // Toggle the table editing state
    [self setEditing:isEditing animated:true];
    
    // Slide the section header along to match the table cells
    CGRect r = [_sectionHeaderContainer frame];
    r.origin.x += isEditing ? HEADER_SPEC_EDIT_OFFSET : -HEADER_SPEC_EDIT_OFFSET;
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [_sectionHeaderContainer setFrame:r];
                     }
                     completion:nil];
    
    return isEditing; // return the current editing state
}

- (void) resetWaypoints {
    [self.tableView reloadData];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger idx = indexPath.row;
    
    if (tableView.isEditing) {
        [self unmarkSelectedRow];
        [[self getWaypointsVC] maybeUpdateCurrentWaypoint:[[self getWaypointsHolder] getWaypoint:idx].seq]; // mark the selected waypoint
        [self performSegueWithIdentifier:@"editItemVC_segue"
                                  sender:[NSNumber numberWithInteger:idx]];
    } else {
        [self modifyHeadersForSelectedRow:idx];
        if ([self.lastIndexPath isEqual:indexPath]) {
            [self unmarkSelectedRow];
        } else {
            self.lastIndexPath = indexPath;
            [[self getWaypointsVC] maybeUpdateCurrentWaypoint:[[self getWaypointsHolder] getWaypoint:idx].seq]; // mark the selected waypoint
        }
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
