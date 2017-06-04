//
//  NGNDateFormatHelper.m
//  TODOList
//
//  Created by Alex on 04.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

#import "NGNDateFormatHelper.h"
#import "NGNConstants.h"

@implementation NGNDateFormatHelper

+ (NSDate *)dateFromString:(NSString *)dateFormattedString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:NGNControllerDateFormat];
    return [formatter dateFromString:dateFormattedString];
}

+ (NSString *)formattedStringFromDate:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:NGNControllerDateFormat];
    return [formatter stringFromDate:date];
}

@end
