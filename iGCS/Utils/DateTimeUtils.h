//
//  DateTimeUtils.h
//  iGCS
//
//  Created by Andrew Brown on 8/30/13.
//
//

#import <Foundation/Foundation.h>

@interface DateTimeUtils : NSObject

// Convenience method to return current date and time
// as a string in the format yyyy-MM-dd-HHmmss in UTC
-(NSString *)dateStringInUTCWithExtension:(NSString *) ext;

// Convenience method to return current date and time
// as a string in the format yyyy-MM-dd-HHmmss in the apps defaultTimeZone
-(NSString *)dateStringInDefaultTimeZoneWithExtension:(NSString *) ext;

-(NSString *)dateStringForDate:(NSDate *)date
                    withFormat:(NSString *)formatString
                   andTimeZone:(NSTimeZone *)timeZone;

-(uint64_t) unixTimeInMicroseconds;
-(uint64_t) systemTimeInMicroseconds;

@end
