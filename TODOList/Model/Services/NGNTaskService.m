//
//  NGNTaskService.m
//  TODOList
//
//  Created by Alex on 02.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

#import "NGNTaskService.h"
#import "NGNTask.h"

@interface NGNTaskService ()

@property (strong, nonatomic, readwrite) NSMutableArray<NGNTask *> *taskList;

@end

@implementation NGNTaskService

- (instancetype)init {
    if (self = [super init]) {
        _taskList = [[NSMutableArray alloc]init];
    }
    return self;
}

- (NGNTask *)taskById:(NSString *)taskId {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.taskId contains[cd] %@", taskId];
    return [[self.taskList filteredArrayUsingPredicate:predicate]firstObject];
}

- (NGNTask *)taskByName:(NSString *)taskName {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name contains %@", taskName];
    return [[self.taskList filteredArrayUsingPredicate:predicate]firstObject];
}

- (void)addTask:(NGNTask *)task {
    [(NSMutableArray *)self.taskList addObject:task];
}

- (void)removeTask:(NGNTask *)task {
    [(NSMutableArray *)self.taskList removeObject:task];
}

- (void)updateTask:(NGNTask *)task {
    NGNTask *oldTask = [self taskById:task.taskId];
    if (oldTask) {
        [(NSMutableArray *)self.taskList insertObject:task
                                              atIndex:[self.taskList indexOfObject:oldTask]];
    }
    else {
        [self addTask:task];
    }
}

- (void)removeTaskById:(NSString *)taskId {
    NGNTask *taskToRemove = [self taskById:taskId];
    [self removeTask:taskToRemove];
}

@end
