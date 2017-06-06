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

@property (strong, nonatomic, readwrite) NSMutableArray<NGNTask *> *privateTaskList;

@end

@implementation NGNTaskService

- (instancetype)init {
    if (self = [super init]) {
        _privateTaskList = [[NSMutableArray alloc]init];
    }
    return self;
}

- (NSMutableArray *)taskList {
    return [self.privateTaskList mutableCopy];
}

- (NGNTask *)taskById:(NSString *)taskId {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.taskId contains[cd] %@", taskId];
    return [[self.taskList filteredArrayUsingPredicate:predicate]firstObject];
}

- (void)addTask:(NGNTask *)task {
    [self.privateTaskList addObject:task];
}

- (void)removeTask:(NGNTask *)task {
    [self.privateTaskList removeObject:task];
}

- (void)updateTask:(NGNTask *)task {
    NGNTask *oldTask = [self taskById:task.taskId];
    if (oldTask) {
        self.privateTaskList[[self.taskList indexOfObject:oldTask]] = task;
    }
    else {
        [self addTask:task];
    }
}

- (void)removeTaskById:(NSString *)taskId {
    NGNTask *taskToRemove = [self taskById:taskId];
    [self removeTask:taskToRemove];
}

- (NSArray *)activeTasksList {
    NSArray *activeTasks = [self.taskList filteredArrayUsingPredicate:
                            [NSPredicate predicateWithFormat:@"SELF.isCompleted == NO"]];
    return activeTasks;
}

@end
