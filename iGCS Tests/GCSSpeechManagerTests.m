//
//  GCSSpeechManagerTests.m
//  iGCS
//
//  Created by Andrew Brown on 2/8/15.
//
//

#import <XCTest/XCTest.h>
#import "GCSSpeechManager.h"


@interface GCSSpeechManagerTests : XCTestCase

@end

// expose methods not declared on the interface to the
// so they can be called from the test harness
@interface GCSSpeechManager (tests)
- (NSString *) cleanTextForSpeechWithText:(NSString *) text;
@end

@implementation GCSSpeechManagerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testCleanTextForSpeechWithText {
    XCTAssertEqualObjects([[GCSSpeechManager sharedInstance] cleanTextForSpeechWithText:@"FBW_A"],
                          @"FBW A", @"cleanTextForSpeechWithText Failed");

    XCTAssertEqualObjects([[GCSSpeechManager sharedInstance] cleanTextForSpeechWithText:@"FBW_B "],
                          @"FBW B", @"cleanTextForSpeechWithText Failed");

    XCTAssertEqualObjects([[GCSSpeechManager sharedInstance] cleanTextForSpeechWithText:@"CUSTOM_MODE (7)"],
                          @"CUSTOM MODE 7", @"cleanTextForSpeechWithText Failed");

    XCTAssertEqualObjects([[GCSSpeechManager sharedInstance] cleanTextForSpeechWithText:@"Relay #"],
                          @"Relay #", @"cleanTextForSpeechWithText Failed");

    XCTAssertEqualObjects([[GCSSpeechManager sharedInstance] cleanTextForSpeechWithText:@"Servo # (5-8)"],
                          @"Servo # 5-8", @"cleanTextForSpeechWithText Failed");

}

@end
