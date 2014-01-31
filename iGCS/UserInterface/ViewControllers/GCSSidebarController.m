//
//  GCSSidebarController.m
//  iGCS
//
//  Created by Claudio Natoli on 31/01/2014.
//
//

#import "GCSSidebarController.h"

@interface GCSSidebarController ()

@end

@implementation GCSSidebarController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

// Forced clear background as per suggestion: http://stackoverflow.com/questions/18878258/uitableviewcell-show-white-background-and-cannot-be-modified-on-ios7
// Unclear why the cell clear color set in IB is not respected.
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell setBackgroundColor:[UIColor clearColor]];
}

@end
