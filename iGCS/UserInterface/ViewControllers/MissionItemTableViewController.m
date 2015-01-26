//
//  MissionItemTableViewController.m
//  iGCS
//
//  Created by Claudio Natoli on 4/05/13.
//
//

#import "MissionItemTableViewController.h"
#import "MissionItemEditViewController.h"

#import "MissionItemCell.h"

#import "MiscUtilities.h"
#import "MavLinkUtility.h"
#import "WaypointHelper.h"

@implementation HeaderSpec

- (instancetype) initWithWidth:(NSInteger)width alignment:(NSTextAlignment)align text:(NSString*)text tag:(NSInteger)tag {
    self = [super init];
    if (self) {
        _text =  text;
        _width = width;
        _align = align;
        _tag   = tag;
    }
    return self;
}

@end


@interface MissionItemTableViewController ()
@property (nonatomic, retain) UIView *sectionHeaderContainer;
@property (nonatomic, retain) NSIndexPath *lastIndexPath;
@end

@implementation MissionItemTableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [self unmarkSelectedRow];
}

- (void)viewWillDisappear:(BOOL)animated {
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 

    [self.tableView setAllowsSelection:YES];
    [self.tableView setAllowsSelectionDuringEditing:YES];
    [self setEditing:YES animated:NO];
    //CGRect r = [self.sectionHeaderContainer frame];
    //r.origin.x += 40;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (WaypointsViewController*) waypointsVC {
    return (WaypointsViewController*)self.parentViewController.parentViewController;
}

- (WaypointsHolder*) waypointsHolder {
    return [[self waypointsVC] waypoints];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) return [[self waypointsHolder] numWaypoints];
    return 0;
}


#define TABLE_HEADER_FONT_SIZE 14
#define HEADER_SPEC_EDIT_OFFSET 40

#define TAG_OFFSET 100

NSArray* headerSpecs = nil;
NSArray* headerWidths = nil;

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
                         [[HeaderSpec alloc] initWithWidth: 95 alignment:NSTextAlignmentRight  text:@"Param1" tag:GCSItemParam1 + TAG_OFFSET], // param1
                         [[HeaderSpec alloc] initWithWidth: 95 alignment:NSTextAlignmentRight  text:@"Param2" tag:GCSItemParam2 + TAG_OFFSET], // param2
                         [[HeaderSpec alloc] initWithWidth: 95 alignment:NSTextAlignmentRight  text:@"Param3" tag:GCSItemParam3 + TAG_OFFSET], // param3
                         [[HeaderSpec alloc] initWithWidth: 95 alignment:NSTextAlignmentRight  text:@"Param4" tag:GCSItemParam4 + TAG_OFFSET], // param4
                         //
                         [[HeaderSpec alloc] initWithWidth:100 alignment:NSTextAlignmentCenter text:@"Autocontinue" tag:0]
                       ];
        
        NSMutableArray* widths = [[NSMutableArray alloc] initWithCapacity:[headerSpecs count]];
        for (HeaderSpec *spec in headerSpecs) {
            [widths addObject:@([spec width])];
        }
        headerWidths = widths;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"MissionItemCell";
    
    MissionItemCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[MissionItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        [cell initializeLabels:headerWidths];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    
    // Prepare the cell
    NSUInteger idx = indexPath.row;
    mavlink_mission_item_t item = [[self waypointsHolder] getWaypoint:idx];

    cell.editingAccessoryType = [MavLinkUtility isSupportedMissionItemType:item.command] ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
    
    [cell configureFor:idx withItem:item];
    return cell;
}

// Support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSAssert(indexPath.section == 0, @"Expect table section to be zero");
        
        // Delete the row from the data source
        [[self waypointsHolder] removeWaypoint:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    
    // Reset the map and table views
    [[self waypointsVC] resetWaypoints];
}


// Support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    NSAssert(indexPath.section == 0, @"Expect table section to be zero");
    return indexPath.row != 0; // Prevent editing of the HOME/0 waypoint
}

// Support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    NSAssert((fromIndexPath.section == 0 && toIndexPath.section == 0), @"Expect to and from table sections to be zero");
    [[self waypointsHolder] moveWaypoint:fromIndexPath.row to:toIndexPath.row];
    
    // Reset the map and table views
    [[self waypointsVC] resetWaypoints];
}

// Support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    NSAssert(indexPath.section == 0, @"Expect table section to be zero");
    return indexPath.row != 0; // Prevent editing of the HOME/0 waypoint
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    // create the view that will hold the header labels
    UIView* headerContainer = [[UIView alloc] initWithFrame:CGRectMake(self.isEditing ? HEADER_SPEC_EDIT_OFFSET : 0, 0,1024,20)];
    NSUInteger x = 0;
    for (HeaderSpec *spec in headerSpecs) {
        NSInteger width = [spec width];
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

    self.sectionHeaderContainer = headerContainer;
    
    return sectionHeader;
}

+ (NSDictionary*) paramEnumToLabelDictWith:(uint16_t)command {
    NSArray* fields = [MavLinkUtility missionItemMetadataWith: command];
    if (!fields) return nil;
    
    NSSet *paramTypes = [[NSSet alloc] initWithObjects:
                         @(GCSItemParam1),
                         @(GCSItemParam2),
                         @(GCSItemParam3),
                         @(GCSItemParam4),
                         nil];
    
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    for (MissionItemField* field in fields) {
        if ([paramTypes containsObject:@(field.fieldType)]) {
            dict[@(field.fieldType)] = field.label;
        }
    }
    return dict;
}

- (void)modifyHeadersForSelectedRow:(NSInteger)row {
    mavlink_mission_item_t waypoint = [[self waypointsHolder] getWaypoint:row];
    NSDictionary *dict = [MissionItemTableViewController paramEnumToLabelDictWith:waypoint.command];
    
    // If we recognise this mission item type, then populate the fields (default is ""),
    // otherwise, fallback to "ParamX"
    ((UILabel*)[self.sectionHeaderContainer viewWithTag:GCSItemParam1 + TAG_OFFSET]).text = dict ? (dict[@(GCSItemParam1)] ?: @"") : @"Param1";
    ((UILabel*)[self.sectionHeaderContainer viewWithTag:GCSItemParam2 + TAG_OFFSET]).text = dict ? (dict[@(GCSItemParam2)] ?: @"") : @"Param2";
    ((UILabel*)[self.sectionHeaderContainer viewWithTag:GCSItemParam3 + TAG_OFFSET]).text = dict ? (dict[@(GCSItemParam3)] ?: @"") : @"Param3";
    ((UILabel*)[self.sectionHeaderContainer viewWithTag:GCSItemParam4 + TAG_OFFSET]).text = dict ? (dict[@(GCSItemParam4)] ?: @"") : @"Param4";
}

- (void)unmarkSelectedRow {
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    [[self waypointsVC] maybeUpdateCurrentWaypoint:WAYPOINTSEQ_NONE];
    self.lastIndexPath = nil;
}

- (void) markSelectedRow:(NSInteger)idx {
    NSIndexPath *path = [NSIndexPath indexPathForRow:idx inSection:0];
    [self.tableView selectRowAtIndexPath:path animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    [self modifyHeadersForSelectedRow:idx];
    [[self waypointsVC] maybeUpdateCurrentWaypoint:[[self waypointsHolder] getWaypoint:idx].seq]; // mark the selected waypoint
}

- (void) refreshTableView {
    [self.tableView reloadData];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
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
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString * segueName = segue.identifier;    
    if ([segueName isEqualToString: @"editItemVC_segue"]) {
        NSNumber *rowNum = (NSNumber*)sender;
        NSUInteger row = [rowNum unsignedIntValue];
        [((MissionItemEditViewController*)[segue destinationViewController]) initInstance:row with:[self waypointsVC]];
    }
}

@end
