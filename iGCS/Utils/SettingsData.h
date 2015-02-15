//
//  SettingsData.h
//  iGCS
//
//  Created by David Leskowicz on 2/14/15.
//
//

#import <Foundation/Foundation.h>

typedef enum {
    standard,
    metric
} Units;

@interface SettingsData : NSObject <NSCoding>

@property (assign, nonatomic) int altitude;
@property (assign, nonatomic) int radius;
@property (assign, nonatomic) int ceiling;
@property (assign, nonatomic) int unitType;

+(instancetype)sharedSettingsData;
-(void) resetDefaults;

+(NSString*)filePath;
+(instancetype)loadInstance;
-(void) save;


@end
