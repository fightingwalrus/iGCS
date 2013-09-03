//
//  DateTimeUtils.m
//  iGCS
//
//  Created by Andrew Brown on 8/30/13.
//
//

#import "DateTimeUtils.h"
#import <mach/mach_time.h>

@implementation DateTimeUtils

-(NSString *)dateStringInUTCWithExtension:(NSString *) ext {
    NSString *name = [self dateStringWithTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
                      return [name stringByAppendingPathExtension:ext];
    return [name stringByAppendingPathExtension:ext];
}

-(NSString *)dateStringInDefaultTimeZoneWithExtension:(NSString *) ext {
    NSString *name = [self dateStringWithTimeZone:[NSTimeZone defaultTimeZone]];
    return [name stringByAppendingPathExtension:ext];
}

- (NSString *)dateStringWithTimeZone:(NSTimeZone *) timeZone {
    // use RFC 822 GMT format so we would get something like "-0800" for defaultTimeZone
    // and for UTC it would look like this: "+0000"
    // see http://www.unicode.org/reports/tr35/tr35-25.html#Time_Zone_Fallback
    return [self dateStringForDate:[NSDate date] withFormat:@"yyyy-MM-dd-HHmmssZZZZZ" andTimeZone:timeZone];
}

-(NSString *)dateStringForDate:(NSDate *)date
                    withFormat:(NSString *)formatString
                   andTimeZone:(NSTimeZone *)timeZone {
    
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    [dateFormater setDateFormat:formatString];
    [dateFormater setTimeZone:timeZone];
    NSString *dateString = [dateFormater stringFromDate:date];
    return dateString;
}

-(uint64_t) unixTimeInMicroseconds {
    uint64_t unixtime = (uint64_t)[[NSDate date] timeIntervalSince1970] * 1000000.0;
    return unixtime;
}

// TODO - I think this is still wrong...
-(uint64_t)systemTimeInMicroseconds {
    // see https://developer.apple.com/library/mac/qa/qa1398/
    static mach_timebase_info_data_t info;
    if (info.denom == 0) {
        (void) mach_timebase_info(&info);
    }
    
    uint64_t mach_time = mach_absolute_time();
    // should convert to microseconds
    uint64_t microseconds = (mach_time * info.numer) / (info.denom * 1000.0);
    return (uint64_t)microseconds;
}

@end
