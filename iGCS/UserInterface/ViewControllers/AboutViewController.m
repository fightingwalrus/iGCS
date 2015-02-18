//
//  AboutViewController.m
//  iGCS
//
//  Created by David Leskowicz on 2/17/15.
//
//

#import "AboutViewController.h"
#import "GCSThemeManager.h"
#import "PureLayout.h"

#import "FileUtils.h"

@interface AboutViewController ()

@property UIScrollView *scrollView;
@property UITextView *textView;

@property (strong, nonatomic) UILabel *iDroneCtrlVersionLabel;
@property (strong, nonatomic) UILabel *iDroneCtrlVersion;

@end

@implementation AboutViewController




- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.scrollView = [UIScrollView newAutoLayoutView];
    self.scrollView.backgroundColor = [GCSThemeManager sharedInstance].appSheetBackgroundColor;
    [self.view addSubview:self.scrollView];
    [self.scrollView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    
    [self createVersionView];
    [self readPlistInfo];
}

- (void)viewWillAppear:(BOOL)animated {

}



- (void) createVersionView {
    
    self.iDroneCtrlVersionLabel = [UILabel newAutoLayoutView];
    [self.scrollView addSubview:self.iDroneCtrlVersionLabel];
    [self.iDroneCtrlVersionLabel setText:@"Version:"];
    self.iDroneCtrlVersionLabel.textAlignment = NSTextAlignmentRight;
    
    self.iDroneCtrlVersion = [UILabel newAutoLayoutView];
    [self.scrollView  addSubview:self.iDroneCtrlVersion];
    [self.iDroneCtrlVersion setText:@"Insert Version Here"];
    
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self.iDroneCtrlVersionLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:88.0f + 50.0f];
        [self.iDroneCtrlVersionLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:60.0f];
    } else {
        [self.iDroneCtrlVersionLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:44.0f + 25.0f];
        [self.iDroneCtrlVersionLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:60.0f];
    }
    
    [self.iDroneCtrlVersion autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.iDroneCtrlVersionLabel withOffset:30.0f];
    [self.iDroneCtrlVersion autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.iDroneCtrlVersionLabel withOffset:0.0f];
    
    
    
}

- (void) readPlistInfo {
    
    self.textView = [UITextView newAutoLayoutView];
    self.textView.text = @"HERE2 BLAH BLAH BLAH BLAH";
    self.textView.backgroundColor = [UIColor blueColor];
    [self.scrollView  addSubview:self.textView];

    NSString *htmlString = @"<h1>Header</h1><h2>Subheader</h2><p>Some <em>text</em></p><img src='http://blogs.babble.com/famecrawler/files/2010/11/mickey_mouse-1097.jpg' width=70 height=100 />";
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    
    NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    
    if(!settingsBundle) {
        NSLog(@"Could not find Settings.bundle");
        return;
    }


    NSDictionary *acks = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:@"Acknowledgements.plist"]];
    NSArray *preferences = [acks objectForKey:@"PreferenceSpecifiers"];

    NSMutableDictionary *defaultsToRegister = [[NSMutableDictionary alloc] initWithCapacity:[preferences count]];
    for(NSDictionary *prefSpecification in preferences) {
        NSString *key = prefSpecification[@"FooterText"];
        if(key) {
            NSLog(@"writing as default %@ to the key%@",prefSpecification[@"DefaultValue"],key);
        }
    }
    
    
    
    

    [self.textView autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.iDroneCtrlVersion withOffset:0.0f];
    [self.textView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.iDroneCtrlVersion withOffset:20.0f];

    


}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
