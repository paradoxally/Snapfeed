//
//  NSDate+ShortTimeAgo.m
//  Snapfeed
//
//  Created by Nino Vitale on 12/27/13.
//
//

#import "NSDate+ShortTimeAgo.h"

@implementation NSDate (ShortTimeAgo)

- (NSString *)shortTimeAgo
{
    if (!self) {
        return nil;
    }
    
    NSDate *currentDate = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(kCFCalendarUnitYear
                                                         |kCFCalendarUnitMonth
                                                         |kCFCalendarUnitWeek
                                                         |kCFCalendarUnitDay
                                                         |kCFCalendarUnitHour
                                                         |kCFCalendarUnitMinute)
                                               fromDate:self
                                                 toDate:currentDate
                                                options:0];
    if (components.year == 0) {
        // same year
        if (components.month == 0) {
            // same month
            if (components.week == 0) {
                // same week
                if (components.day == 0) {
                    // same day
                    if (components.hour == 0) {
                        // same hour
                        if (components.minute < 1) {
                            // under 1 min
                            return @"now";
                        } else {
                            // >= 1 min age
                            return [NSString stringWithFormat:@"%dm", (int)(components.minute/1)];
                        }
                    } else {
                        // different hour
                        return [NSString stringWithFormat:@"%dh", components.hour];
                    }
                } else {
                    // different day
                    return [NSString stringWithFormat:@"%dd", components.day];
                }
            } else {
                // different week
                return [NSString stringWithFormat:@"%dw", components.week];
            }
        } else {
            // different month
            return [NSString stringWithFormat:@"%dm", components.month];
        }
    } else {
        // different year
        return [NSString stringWithFormat:@"%dy", components.year];
    }
}

@end
