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
#import "BundleUtils.h"

@interface AboutViewController ()

@property UITextView *textView;

@end

@implementation AboutViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.textView = [UITextView newAutoLayoutView];
    self.textView.backgroundColor = [GCSThemeManager sharedInstance].appSheetBackgroundColor;
    [self.view addSubview:self.textView];
    [self.textView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    [self populateTextViewWithAttributedString:[self buildAcknowledgementsData]];
}

- (NSAttributedString *) buildAcknowledgementsData {
    
    NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    if(!settingsBundle) {
        return nil;
    }

    NSDictionary *acknowlegementPlist = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:@"Acknowledgements.plist"]];
    NSArray *preferences = [acknowlegementPlist objectForKey:@"PreferenceSpecifiers"];
    NSString *htmlString = [NSString stringWithFormat:@"<h2> iDroneCtrl Version: %@ </h2><br><br><h3>3rd Party Libraries</h3>", [BundleUtils appVersionInfo]];

    for(NSDictionary *prefSpecification in preferences) {
        NSString *footerInfo = prefSpecification[@"FooterText"];
        if(footerInfo) {
            htmlString = [htmlString stringByAppendingString:[NSString stringWithFormat:@"<p style=\"font-size:120%%\"> %@ </p>", footerInfo]];
        }
    }
    
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];

    return attributedString;
}

- (void) populateTextViewWithAttributedString:(NSAttributedString *) attributedString {
    self.textView.attributedText = attributedString;
    self.textView.scrollEnabled = YES;
    self.textView.editable = NO;
    self.textView.backgroundColor = [GCSThemeManager sharedInstance].appSheetBackgroundColor;
    [self.textView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
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
