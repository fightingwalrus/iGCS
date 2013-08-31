//
//  DateTimeUtils.h
//  iGCS
//
//  Created by Andrew Brown on 8/30/13.
//
//

#import <Foundation/Foundation.h>

@interface DateTimeUtils : NSObject

// YYYY-MM-DD-HHMMSS
-(NSString *)logNameForCurrentDateTimeInGMTWithExtention:(NSString *) ext;
-(NSString *)logNameForCurrentDateTimeInDefaultTimeZoneWithExtention:(NSString *) ext;
-(uint64_t) unixTimeInMicroseconds;
-(uint64_t) systemTimeInUSecs;

@end
