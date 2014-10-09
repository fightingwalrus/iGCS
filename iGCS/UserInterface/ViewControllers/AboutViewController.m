//
//  AboutViewController.m
//  iGCS
//
//  Created by Andrew Brown on 10/6/14.
//
//

#import "AboutViewController.h"

@interface AboutViewController ()
// Navigation bar items
@property (strong, nonatomic) UIBarButtonItem *doneBarButtonItem;
@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureNavigationBar];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)configureNavigationBar {
    [self setTitle:@"About iGCS by Fighting Walrus"];

    self.doneBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                           target:self action:@selector(done:)];

    self.navigationItem.leftBarButtonItem = self.doneBarButtonItem;
}

#pragma mark - UINavigationBar Button handlers

- (void)done:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
