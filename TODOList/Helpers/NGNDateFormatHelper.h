//
//  NGNDateFormatHelper.h
//  TODOList
//
//  Created by Alex on 04.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NGNDateFormatHelper : NSObject

+ (NSDate *)dateFromString:(NSString *)dateFormattedString;
+ (NSString *)formattedStringFromDate:(NSDate *)date;

@end
