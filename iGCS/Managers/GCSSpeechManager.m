//
//  GCSSpeechManager.m
//  iGCS
//
//  Created by Andrew Brown on 1/12/15.
//
//

#import "GCSSpeechManager.h"
#import <AVFoundation/AVFoundation.h>

@interface GCSSpeechManager ()
@property (nonatomic, assign) float utteranceRate;
@property (nonatomic, strong) NSString *defaultLanguage;
@end

@implementation GCSSpeechManager

- (instancetype)init {
    if (self = [super init]) {
        // set speech defaults
        _utteranceRate = 0.2f;
        _defaultLanguage = @"en-US";

        // only register for notifications on iOS 7+
        if ([AVSpeechUtterance class] && [AVSpeechSynthesizer class]) {
            // register for notifications
        }
    }
    return self;
}


-(void)flyToPosition {
    // ensure availability on target device
    // text to speech works on IOS 7 and above
    if ([AVSpeechUtterance class] && [AVSpeechSynthesizer class]) {
        NSString *string = @"Flying to position";
        AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:string];
        utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:self.defaultLanguage];
        utterance.rate = self.utteranceRate;

        AVSpeechSynthesizer *synthesizer = [[AVSpeechSynthesizer alloc] init];
        [synthesizer speakUtterance:utterance];
    }
}

@end