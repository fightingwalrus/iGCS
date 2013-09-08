//
//  DateTimeUtils.h
//  iGCS
//
//  Created by Andrew Brown on 8/30/13.
//
//

#import <Foundation/Foundation.h>

@interface DateTimeUtils : NSObject

// Return current date and time as a string in the format
// yyyy-MM-dd-HHmmssZ in UTC with the given file extension.
// This method is appropriate for log files names.
-(NSString *)dateStringInUTCWithExtension:(NSString *) ext;

// Return current date and time as a string in the format
// yyyy-MM-dd-HHmmssZ in the apps defaultTimeZone.
// This method is appropriate for log file names.
-(NSString *)dateStringInDefaultTimeZoneWithExtension:(NSString *) ext;

// Return the current date and time as a string in the format
// yyyy-MM-dd-HHmmssZ using the provided time zone
-(NSString *)dateStringWithTimeZone:(NSTimeZone *) timeZone;

-(NSString *)dateStringForDate:(NSDate *)date
                    withFormat:(NSString *)formatString
                   andTimeZone:(NSTimeZone *)timeZone;

-(uint64_t) unixTimeInMicroseconds;
-(uint64_t) systemTimeInMicroseconds;

@end
