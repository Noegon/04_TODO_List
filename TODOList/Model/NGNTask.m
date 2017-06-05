//
//  NGNTask.m
//  TODOList
//
//  Created by Alex on 02.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

#import "NGNTask.h"

@implementation NGNTask

+ (instancetype)taskWithId:(NSString *)taskId name:(NSString *)name {
    return [[self alloc]initWithId:taskId name:name];
}

+ (instancetype)taskWithId:(NSString *)taskId name:(NSString *)name startDate:(NSDate *)startDate notes:(NSString *)notes {
    return [[self alloc]initWithId:taskId name:name startDate:startDate notes:notes];
}

- (instancetype)initWithId:(NSString *)taskId name:(NSString *)name {
    return [self initWithId:taskId name:name startDate:[NSDate date] notes:@""];
}

- (instancetype)initWithId:(NSString *)taskId name:(NSString *)name startDate:(NSDate *)startDate notes:(NSString *)notes {
    if (self = [super init]) {
        _taskId = taskId;
        _name = name;
        _startedAt = startDate;
        _notes = notes;
    }
    return self;
}

- (BOOL)isEqual:(id)other
{
    NGNTask *tmpOther = (NGNTask *)other;
    if (other == self) {
        return YES;
    } else if (![super isEqual:other]) {
        return NO;
    } else {
        return [self.taskId isEqualToString:tmpOther.taskId];
    }
}

- (NSUInteger)hash
{
    return [self.taskId hash];
}

@end
