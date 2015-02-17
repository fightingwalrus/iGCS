//
//  GCSSpeechManager.m
//  iGCS
//
//  Created by Andrew Brown on 1/12/15.
//
//

#import "GCSSpeechManager.h"
#import "GCSDataManager.h"

@interface GCSSpeechManager ()
@property (nonatomic, assign) float utteranceRate;
@property (nonatomic, strong) NSString *defaultLanguage;
@property (nonatomic, strong) AVSpeechSynthesizer *speechSynthesizer;
@property (nonatomic, strong) NSNotificationCenter *notificationCenter;
@property (nonatomic, strong) NSOperationQueue *speakerQueue;
@end

@implementation GCSSpeechManager

+ (instancetype) sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        // set speech defaults
        _utteranceRate = 0.1f;
        _defaultLanguage = @"en-US";
        _notificationCenter = [NSNotificationCenter defaultCenter];
        _speakerQueue = [[NSOperationQueue alloc] init];

        _speechSynthesizer = [[AVSpeechSynthesizer alloc] init];

        __weak GCSSpeechManager *weakSelf = self;
        // only register for notifications on iOS 7+
        if ([AVSpeechUtterance class] && [AVSpeechSynthesizer class]) {
            // register for notifications

            [self.notificationCenter addObserverForName:GCSCraftNotificationsCraftCustomModeDidChange
                                                 object:nil queue:self.speakerQueue
                                             usingBlock:^(NSNotification *note) {
                                                 [weakSelf craftNavModeDidChange];
            }];

            [self.notificationCenter addObserverForName:GCSCraftNotificationsCraftMavModeDidChange
                                                 object:nil queue:self.speakerQueue
                                             usingBlock:^(NSNotification *note) {
                                                 [weakSelf craftMavModeDidChange];
                                             }];

        }
    }
    return self;
}

- (void)dealloc {
    [self.notificationCenter removeObserver:self];
}

#pragma mark - handle craft related notification

- (void)craftNavModeDidChange {
    [self speakWithText:[GCSDataManager sharedInstance].craft.currentModeName];
}

- (void)craftMavModeDidChange {
    [self speakWithText:([GCSDataManager sharedInstance].craft.isArmed) ? @"Armed" : @"Disarmed"];
}

#pragma mark - public methods

- (void)sayflyToPosition {
    [self speakWithText:@"Flying to position"];
}

#pragma mark - helpers

-(NSString *) cleanTextForSpeechWithText:(NSString *) text {
     // remove characters that won't sound great when spoken
    NSMutableCharacterSet *characterSet = [NSMutableCharacterSet alphanumericCharacterSet];
    [characterSet formUnionWithCharacterSet:[NSCharacterSet characterSetWithCharactersInString:@"#-"]];

    return [[[text componentsSeparatedByCharactersInSet:[characterSet invertedSet]]
             filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self <> ''"]] componentsJoinedByString:@" "];
}

- (void)speakWithText:(NSString *) text {
    // ensure availability on target device
    // text to speech works on IOS 7 and above
    if ([AVSpeechUtterance class] && [AVSpeechSynthesizer class]) {
        NSString *cleanText = [self cleanTextForSpeechWithText:text];
        AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:cleanText];
        utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:self.defaultLanguage];
        utterance.rate = self.utteranceRate;

        [self.speechSynthesizer speakUtterance:utterance];
    }
}

@end