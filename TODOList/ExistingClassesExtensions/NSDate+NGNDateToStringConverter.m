//
//  NSDate+NGNDateToStringConverter.m
//  TODOList
//
//  Created by Alex on 07.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

#import "NSDate+NGNDateToStringConverter.h"
#import "NGNConstants.h"

@implementation NSDate (NGNDateToStringConverter)

+ (NSDate *)ngn_dateFromString:(NSString *)dateFormattedString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:NGNControllerDateFormat];
    return [formatter dateFromString:dateFormattedString];
}

+ (NSString *)ngn_formattedStringFromDate:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:NGNControllerDateFormat];
    return [formatter stringFromDate:date];
}

@end
