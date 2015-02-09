//
//  GCSSpeechManager.m
//  iGCS
//
//  Created by Andrew Brown on 1/12/15.
//
//

#import "GCSSpeechManager.h"
#import <AVFoundation/AVFoundation.h>
#import "GCSDataManager.h"

@interface GCSSpeechManager ()
@property (nonatomic, assign) float utteranceRate;
@property (nonatomic, strong) NSString *defaultLanguage;
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
        _utteranceRate = 0.2f;
        _defaultLanguage = @"en-US";

        // only register for notifications on iOS 7+
        if ([AVSpeechUtterance class] && [AVSpeechSynthesizer class]) {
            // register for notifications

            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(craftNavModeDidChange)
                                                         name:GCSCraftNotificationsCraftCustomModeDidChange object:nil];
        }
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - handle craft related notification

- (void)craftNavModeDidChange {
    [self speakWithText:[GCSDataManager sharedInstance].craft.currentModeName];
}

#pragma mark - public methods

- (void)sayflyToPosition {
    [self speakWithText:@"Flying to position"];
}

#pragma mark - helpers

-(NSString *) cleanTextForSpeechWithText:(NSString *) text {
     // remove characters that won't sound great when spoken
     // by creating a whitelist of acceptable characters
    __block NSMutableCharacterSet *characterSet = [NSMutableCharacterSet alphanumericCharacterSet];
    [characterSet formUnionWithCharacterSet:[NSCharacterSet characterSetWithCharactersInString:@"#-"]];
    __block NSMutableString *cleanedString = [[NSMutableString alloc] init];

    [text enumerateSubstringsInRange:NSMakeRange(0, text.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {

        unichar *buffer = calloc(enclosingRange.length, sizeof(unichar));
        [substring getCharacters:buffer range:NSMakeRange(0, substring.length)];
        if ([characterSet characterIsMember:*buffer]) {
            [cleanedString appendString:substring];
        } else {
            [cleanedString appendString:@" "];
        }
    }];

    // remove any duplicate whitespace
    NSString *string = [cleanedString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSArray *components = [string componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    components = [components filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self <> ''"]];

    string = [components componentsJoinedByString:@" "];

    return string;
}

- (void)speakWithText:(NSString *) text {
    // ensure availability on target device
    // text to speech works on IOS 7 and above
    if ([AVSpeechUtterance class] && [AVSpeechSynthesizer class]) {
        NSString *cleanText = [self cleanTextForSpeechWithText:text];
        AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:cleanText];
        utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:self.defaultLanguage];
        utterance.rate = self.utteranceRate;

        AVSpeechSynthesizer *synthesizer = [[AVSpeechSynthesizer alloc] init];
        [synthesizer speakUtterance:utterance];
    }
}

@end