//
//  NGNTask.h
//  TODOList
//
//  Created by Alex on 02.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NGNStoredEntity.h"

@interface NGNTask : NGNStoredEntity <NGNStoreable>

@property (strong, nonatomic) NSDate *startedAt;
@property (strong, nonatomic) NSDate *finishedAt;
@property (copy, nonatomic) NSString *notes;
@property (assign, nonatomic) BOOL shouldRemindOnDay;
@property (assign, nonatomic) NSInteger priority;
@property (assign, nonatomic, getter=isCompleted) BOOL completed;

+ (instancetype)taskWithId:(NSInteger)taskId name:(NSString *)name;
+ (instancetype)taskWithId:(NSInteger)taskId
                      name:(NSString *)name
                 startDate:(NSDate *)startDate
                     notes:(NSString *)notes;

- (instancetype)initWithId:(NSInteger)taskId name:(NSString *)name;
- (instancetype)initWithId:(NSInteger)taskId
                      name:(NSString *)name
                 startDate:(NSDate *)startDate
                     notes:(NSString *)notes;

@end
