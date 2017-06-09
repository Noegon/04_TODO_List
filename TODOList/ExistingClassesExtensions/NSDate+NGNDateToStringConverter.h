//
//  NSDate+NGNDateToStringConverter.h
//  TODOList
//
//  Created by Alex on 07.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (NGNDateToStringConverter)

+ (NSDate *)ngn_dateFromString:(NSString *)dateFormattedString;
+ (NSString *)ngn_formattedStringFromDate:(NSDate *)date;

@end
