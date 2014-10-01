//
//  SoundUtils.m
//  iGCS
//
//  Created by Andrew Brown on 9/30/14.
//
//

#import "SoundUtils.h"
#import <AudioToolbox/AudioToolbox.h>

@implementation SoundUtils

+(void)vibrateOrBeepBeep {
    // vibrate for iPhone only
    if([[UIDevice currentDevice].model isEqualToString:@"iPhone"]) {
        AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
    } else {
        // fall back to beep-beep.caf system sound
        // (accessory connect sound)
        AudioServicesPlaySystemSound (1106);
    }
}

@end
