//
//  GCSRadioSettings.h
//  iGCS
//
//  Created by Andrew Brown on 5/7/14.
//
//

#import <Foundation/Foundation.h>

@interface GCSRadioSettings : NSObject

@property(nonatomic, strong) NSString *radioVersion;
@property(nonatomic, strong) NSString *boardType;
@property(nonatomic, strong) NSString *boardFrequency;
@property(nonatomic, strong) NSString *boardVersion;
@property(nonatomic, strong) NSString *tdmTimingReport;
@property(nonatomic, strong) NSString *RSSIReport;
@property(nonatomic, readwrite) NSInteger serialSpeed;
@property(nonatomic, readwrite) NSInteger airSpeed;
@property(nonatomic, readwrite) NSInteger netId;
@property(nonatomic, readwrite) NSInteger transmitterPower;
@property(nonatomic, readwrite) BOOL isECCenabled;
@property(nonatomic, readwrite) BOOL isMavlinkEnabled;
@property(nonatomic, readwrite) BOOL isOppResendEnabled;
@property(nonatomic, readwrite) NSInteger minFrequency;
@property(nonatomic, readwrite) NSInteger maxFrequency;
@property(nonatomic, readwrite) NSInteger numberOfChannels;
@property(nonatomic, readwrite) NSInteger dutyCycle;
@property(nonatomic, readwrite) BOOL isListenBeforeTalkRSSIEnabled;

@end
