//
//  NGNTaskService.m
//  TODOList
//
//  Created by Alex on 02.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

#import "NGNTaskService.h"
#import "NGNTask.h"
#import "NGNTaskList.h"
#import "NSDate+NGNDateToStringConverter.h"

@interface NGNTaskService ()

@end

@implementation NGNTaskService

+ (instancetype)sharedInstance {
    static NGNTaskService *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
#warning hardcoded test datasource
        sharedInstance = [[NGNTaskService alloc] init];
        NGNTask *task1 = [NGNTask taskWithId:1 name:@"Make calculator 3.0"];
        NGNTask *task2 = [NGNTask taskWithId:2
                                        name:@"Make TODO List 0.1"
                                   startDate:[NSDate ngn_dateFromString:@"17/07/2009"]
                                       notes:@""];
        NGNTask *task3 = [NGNTask taskWithId:3 name:@"Make somthing useful"];
        NGNTaskList *taskList = [[NGNTaskList alloc]initWithId:1 name:@"Test list"];
        NGNTask *task4 = [NGNTask taskWithId:4
                                        name:@"Buy milk"
                                   startDate:[NSDate ngn_dateFromString:@"09/07/2017"]
                                       notes:@""];
        NGNTask *task5 = [NGNTask taskWithId:5 name:@"Buy bread"];
        NGNTaskList *taskList2 = [[NGNTaskList alloc]initWithId:2
                                                           name:@"Commodities"
                                                   creationDate:[NSDate dateWithTimeIntervalSinceNow:1000000]];
        [taskList addEntity:task1];
        [taskList addEntity:task2];
        [taskList addEntity:task3];
        [taskList2 addEntity:task4];
        [taskList2 addEntity:task5];
        [sharedInstance addEntity:taskList];
        [sharedInstance addEntity:taskList2];
        
    });
    return sharedInstance;
}

- (NSArray *)allTasks {
    NSArray *unitedArray = [self.entityCollection valueForKeyPath:@"@unionOfArrays.self.entityCollection"];
    return unitedArray;
}

- (NSArray *)allActiveTasks {
    NSArray *activeTasks = [[self allTasks] filteredArrayUsingPredicate:
                            [NSPredicate predicateWithFormat:@"SELF.isCompleted == NO"]];
    return activeTasks;
}

- (NSMutableArray *)allActiveTasksGroupedByStartDate {
    NSMutableArray *groupedByStartDateTasks = [[NSMutableArray alloc] init];
    NSArray *stringfiedDatesArray =
        [[self allActiveTasks] valueForKeyPath:@"@distinctUnionOfObjects.startedAt.description"];
    for (int i = 0; i < stringfiedDatesArray.count; i++) {
        NSPredicate *predicate =
            [NSPredicate predicateWithFormat:@"SELF.startedAt.description contains[cd] %@", stringfiedDatesArray[i]];
        NSArray<id<NGNStoreable>> *currentStartDateTasks =
            [[self allActiveTasks] filteredArrayUsingPredicate:predicate];
        [groupedByStartDateTasks addObject:[currentStartDateTasks mutableCopy]];
    }
    return [groupedByStartDateTasks mutableCopy];
}

- (void)removeTask:(NGNTask *)taskToRemove {
    for (NGNTaskList *list in self.entityCollection) {
        if ([list entityById:taskToRemove.entityId]) {
            [list removeEntity:taskToRemove];
        }
    }
}

@end
